from rest_framework import generics, status
from django.http import HttpResponse, StreamingHttpResponse
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
import json
from rest_framework.response import Response
from rest_framework.views import APIView
from django.conf import settings
from .models import PromptTemplate, Document
from .serializers import PromptTemplateSerializer, GenerateContentSerializer, DocumentSerializer
from google import genai

class PromptTemplateListView(generics.ListCreateAPIView):
    queryset = PromptTemplate.objects.all()
    serializer_class = PromptTemplateSerializer

class DocumentListCreateView(generics.ListCreateAPIView):
    queryset = Document.objects.all()
    serializer_class = DocumentSerializer

class DocumentDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Document.objects.all()
    serializer_class = DocumentSerializer

from django.http import StreamingHttpResponse
import json

class GenerateContentView(APIView):
    def post(self, request):
        serializer = GenerateContentSerializer(data=request.data)
        if serializer.is_valid():
            template_id = serializer.validated_data['template_id']
            variables = serializer.validated_data.get('variables') or {}

            try:
                template = PromptTemplate.objects.get(id=template_id)
                try:
                    format_safe = template.template_text.format(**variables)
                except KeyError as e:
                    return Response({"error": f"Missing variable in prompt: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)
                except Exception:
                    format_safe = template.template_text
                
                api_key = settings.GEMINI_API_KEY
                if not api_key:
                    return Response({"error": "Gemini API Key not configured"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                client = genai.Client(api_key=api_key)
                
                def stream_generator():
                    try:
                        # Use streaming generation
                        response_stream = client.models.generate_content_stream(
                            model='gemini-2.5-flash',
                            contents=format_safe
                        )
                        for chunk in response_stream:
                            if chunk.text:
                                # We send raw text or JSON depending on protocol. 
                                # For simple piping, raw text is often easier for the client to append.
                                yield chunk.text
                    except Exception as e:
                        error_msg = str(e)
                        if "RESOURCE_EXHAUSTED" in error_msg:
                            yield "[ERROR] Quota Exceeded"
                        else:
                            yield f"[ERROR] {error_msg}"

                return StreamingHttpResponse(stream_generator(), content_type='text/plain')

            except PromptTemplate.DoesNotExist:
                return Response({"error": "Template not found"}, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                return Response({"error": f"Internal Server Error: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ExportToPDFView(APIView):
    def post(self, request):
        content = request.data.get('content', '')
        title = request.data.get('title', 'Document')
        
        if not content:
            return Response({"error": "No content to export"}, status=status.HTTP_400_BAD_REQUEST)
            
        response = HttpResponse(content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="{title}.pdf"'
        
        doc = SimpleDocTemplate(response, pagesize=letter)
        styles = getSampleStyleSheet()
        
        elements = []
        elements.append(Paragraph(title, styles['Title']))
        elements.append(Spacer(1, 12))
        
        # Split content by lines and escape HTML-like characters for Paragraph
        import html
        for line in content.split('\n'):
            clean_line = html.escape(line.strip())
            if clean_line:
                elements.append(Paragraph(clean_line, styles['Normal']))
            else:
                elements.append(Spacer(1, 6))
                
        try:
            doc.build(elements)
        except Exception as e:
            return Response({"error": f"PDF Generation failed: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
        return response
