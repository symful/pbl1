from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.conf import settings
from django.http import StreamingHttpResponse
from .models import VideoProject
from .serializers import VideoProjectSerializer, GenerateScriptSerializer
from google import genai

class VideoProjectListView(generics.ListCreateAPIView):
    queryset = VideoProject.objects.all()
    serializer_class = VideoProjectSerializer

class GenerateScriptView(APIView):
    def post(self, request):
        serializer = GenerateScriptSerializer(data=request.data)
        if serializer.is_valid():
            idea = serializer.validated_data['idea']
            
            try:
                api_key = settings.GEMINI_API_KEY
                if not api_key:
                    return Response({"error": "Gemini API Key not configured"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                client = genai.Client(api_key=api_key)
                
                # Create project first
                project = VideoProject.objects.create(
                    title=idea[:50],
                    idea_description=idea,
                    generated_script="" # Will update later or client will save
                )
                
                def stream_generator():
                    # Send project ID as first line
                    yield f"PROJECT_ID:{project.id}\n"
                    
                    full_script = ""
                    try:
                        response_stream = client.models.generate_content_stream(
                            model='gemini-2.5-flash',
                            contents=f"Create a detailed video script for a short video about: {idea}. Include scene descriptions and voiceover text."
                        )
                        for chunk in response_stream:
                            if chunk.text:
                                full_script += chunk.text
                                yield chunk.text
                        
                        # Background update (optional but good for consistency)
                        project.generated_script = full_script
                        project.save()
                    except Exception as e:
                        yield f"[ERROR] {str(e)}"
                
                return StreamingHttpResponse(stream_generator(), content_type='text/plain')
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class GenerateStoryboardView(APIView):
    def post(self, request):
        from .serializers import StoryboardSerializer
        serializer = StoryboardSerializer(data=request.data)
        if serializer.is_valid():
            try:
                project = VideoProject.objects.get(id=serializer.validated_data['project_id'])
                
                api_key = settings.GEMINI_API_KEY
                client = genai.Client(api_key=api_key)
                
                prompt = f"""
                Convert this video script into a structured storyboard (JSON array of scenes).
                Script: {project.generated_script}
                
                Return ONLY a JSON array. Each object:
                - scene_number: int
                - visual_description: string (detailed description for an artist)
                - audio_text: string (voiceover or dialogue)
                - duration: int (seconds)
                
                Output must be raw JSON. No markdown.
                """
                
                try:
                    response = client.models.generate_content(
                        model='gemini-2.5-flash',
                        contents=prompt
                    )
                except Exception as e:
                    error_msg = str(e)
                    if "RESOURCE_EXHAUSTED" in error_msg:
                        return Response({"error": "Gemini API Quota Exceeded. Please try again later."}, status=status.HTTP_429_TOO_MANY_REQUESTS)
                    return Response({"error": f"Gemini API Error: {error_msg}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                # Cleanup JSON
                clean_json = response.text.strip().replace('```json', '').replace('```', '')
                
                return Response({"storyboard": clean_json})
            except VideoProject.DoesNotExist:
                return Response({"error": "Project not found"}, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class VisualizeSceneView(APIView):
    def post(self, request):
        # Expects visual_description
        description = request.data.get('visual_description')
        if not description:
            return Response({"error": "No description provided"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            api_key = settings.GEMINI_API_KEY
            client = genai.Client(api_key=api_key)
            
            prompt = f"""
            Generate a clean, artistic SVG illustration for this scene: "{description}".
            
            Rules:
            - Stick to a professional, minimalist vector style.
            - Use a 800x600 viewBox.
            - Output ONLY raw SVG code. No markdown, no explanation.
            - Do not use external image links.
            """
            
            try:
                response = client.models.generate_content(
                    model='gemini-2.5-flash',
                    contents=prompt
                )
            except Exception as e:
                error_msg = str(e)
                if "RESOURCE_EXHAUSTED" in error_msg:
                    return Response({"error": "Gemini API Quota Exceeded. Please try again later."}, status=status.HTTP_429_TOO_MANY_REQUESTS)
                return Response({"error": f"Gemini API Error: {error_msg}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            svg_code = response.text.strip().replace('```svg', '').replace('```', '')
            if not svg_code.startswith('<svg'):
                # Try to extract if Gemini added text
                import re
                match = re.search(r'<svg.*?</svg>', svg_code, re.DOTALL)
                if match:
                    svg_code = match.group(0)
            
            return Response({"svg_code": svg_code})
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
