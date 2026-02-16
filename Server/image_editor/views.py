from rest_framework import generics, status, parsers
from rest_framework.response import Response
from rest_framework.views import APIView
from django.conf import settings
from .models import ImageTemplate, UploadedImage
from .serializers import ImageTemplateSerializer, UploadedImageSerializer, GenerateImageSerializer
from google import genai
from google.genai import types
from PIL import Image, ImageFilter, ImageOps, ImageEnhance
import io
import base64

class ImageTemplateListView(generics.ListCreateAPIView):
    queryset = ImageTemplate.objects.all()
    serializer_class = ImageTemplateSerializer

class ImageUploadView(generics.CreateAPIView):
    queryset = UploadedImage.objects.all()
    serializer_class = UploadedImageSerializer
    parser_classes = [parsers.MultiPartParser, parsers.FormParser]

class GenerateImageView(APIView):
    def post(self, request):
        serializer = GenerateImageSerializer(data=request.data)
        if serializer.is_valid():
            try:
                template = ImageTemplate.objects.get(id=serializer.validated_data['template_id'])
                uploaded_image = UploadedImage.objects.get(id=serializer.validated_data['image_id'])
                
                api_key = settings.GEMINI_API_KEY
                if not api_key:
                    return Response({"error": "Gemini API Key not configured"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                client = genai.Client(api_key=api_key)
                
                # Open image
                with open(uploaded_image.image.path, 'rb') as f:
                    image_bytes = f.read()
                
                try:
                    response = client.models.generate_content(
                        model='gemini-2.5-flash',
                        contents=[
                            template.prompt_template,
                            types.Part.from_bytes(data=image_bytes, mime_type='image/jpeg')
                        ]
                    )
                    return Response({"content": response.text})
                except Exception as e:
                    error_msg = str(e)
                    if "RESOURCE_EXHAUSTED" in error_msg:
                        return Response({"error": "Gemini API Quota Exceeded. Please try again later."}, status=status.HTTP_429_TOO_MANY_REQUESTS)
                    return Response({"error": f"Gemini API Error: {error_msg}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            except ImageTemplate.DoesNotExist:
                return Response({"error": "Template not found"}, status=status.HTTP_404_NOT_FOUND)
            except UploadedImage.DoesNotExist:
                return Response({"error": "Image not found"}, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class SmartEditView(APIView):
    def post(self, request):
        from .serializers import SmartEditSerializer
        
        serializer = SmartEditSerializer(data=request.data)
        if serializer.is_valid():
            try:
                uploaded_image = UploadedImage.objects.get(id=serializer.validated_data['image_id'])
                prompt = serializer.validated_data['prompt']
                
                api_key = settings.GEMINI_API_KEY
                if not api_key:
                    return Response({"error": "Gemini API Key not configured"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                client = genai.Client(api_key=api_key)
                
                # Agency Prompt: Ask Gemini to write PIL code
                code_prompt = f"""
                You are a Python image processing agent.
                Write a function named `process_image` that takes a PIL Image object named `img` and returns it modified.
                Objective: "{prompt}"
                
                Rules:
                - Use only `PIL.Image`, `PIL.ImageFilter`, `PIL.ImageOps`, `PIL.ImageEnhance`.
                - Signature: `def process_image(img):`.
                - Output ONLY valid Python code. No markdown, no backticks.
                """
                
                try:
                    result = client.models.generate_content(
                        model='gemini-2.5-flash',
                        contents=code_prompt
                    )
                except Exception as e:
                    error_msg = str(e)
                    if "RESOURCE_EXHAUSTED" in error_msg:
                        return Response({"error": "Gemini API Quota Exceeded. Please try again later."}, status=status.HTTP_429_TOO_MANY_REQUESTS)
                    return Response({"error": f"Gemini API Error (Code Gen): {error_msg}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

                code = result.text.strip().replace('```python', '').replace('```', '')
                
                # Execute in safe context
                local_scope = {}
                global_scope = {
                    'Image': Image, 
                    'ImageFilter': ImageFilter, 
                    'ImageOps': ImageOps, 
                    'ImageEnhance': ImageEnhance
                }
                try:
                    exec(code, global_scope, local_scope)
                except Exception as e:
                     return Response({"error": f"AI Code Execution Failed: {str(e)}", "code_attempted": code}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                if 'process_image' not in local_scope:
                    return Response({"error": "AI failed to generate valid code"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                # Run the generated code
                original_img = Image.open(uploaded_image.image.path)
                processed_img = local_scope['process_image'](original_img)
                
                # Base64 response
                buffer = io.BytesIO()
                # Ensure it's RGB if saving as JPEG
                if processed_img.mode in ("RGBA", "P"):
                    processed_img = processed_img.convert("RGB")
                    
                processed_img.save(buffer, format="JPEG", quality=85)
                img_str = base64.b64encode(buffer.getvalue()).decode()
                
                return Response({"image_data": img_str, "status": "success"})

            except UploadedImage.DoesNotExist:
                return Response({"error": "Image not found"}, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                return Response({"error": f"Agentic processing failed: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
