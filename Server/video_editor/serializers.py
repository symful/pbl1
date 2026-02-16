from rest_framework import serializers
from .models import VideoProject

class VideoProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = VideoProject
        fields = '__all__'

class GenerateScriptSerializer(serializers.Serializer):
    idea = serializers.CharField()

class StoryboardSerializer(serializers.Serializer):
    project_id = serializers.IntegerField()
