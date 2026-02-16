from django.urls import path
from .views import VideoProjectListView, GenerateScriptView, GenerateStoryboardView, VisualizeSceneView

urlpatterns = [
    path('projects/', VideoProjectListView.as_view(), name='project-list'),
    path('generate-script/', GenerateScriptView.as_view(), name='generate-script'),
    path('generate-storyboard/', GenerateStoryboardView.as_view(), name='generate-storyboard'),
    path('visualize-scene/', VisualizeSceneView.as_view(), name='visualize-scene'),
]
