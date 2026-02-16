from django.urls import path
from .views import PromptTemplateListView, GenerateContentView, DocumentListCreateView, DocumentDetailView, ExportToPDFView

urlpatterns = [
    path('templates/', PromptTemplateListView.as_view(), name='template-list'),
    path('generate/', GenerateContentView.as_view(), name='generate-content'),
    path('documents/', DocumentListCreateView.as_view(), name='document-list'),
    path('documents/<int:pk>/', DocumentDetailView.as_view(), name='document-detail'),
    path('export-pdf/', ExportToPDFView.as_view(), name='export-pdf'),
]
