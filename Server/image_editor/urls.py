from django.urls import path
from .views import ImageTemplateListView, ImageUploadView, GenerateImageView, SmartEditView

urlpatterns = [
    path('templates/', ImageTemplateListView.as_view(), name='template-list'),
    path('upload/', ImageUploadView.as_view(), name='image-upload'),
    path('generate/', GenerateImageView.as_view(), name='generate-image-content'),
    path('smart-edit/', SmartEditView.as_view(), name='smart-edit'),
]
