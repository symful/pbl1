from rest_framework import serializers
from .models import ImageTemplate, UploadedImage

class ImageTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ImageTemplate
        fields = '__all__'

class UploadedImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = UploadedImage
        fields = '__all__'

class GenerateImageSerializer(serializers.Serializer):
    template_id = serializers.IntegerField()
    image_id = serializers.IntegerField() 

class SmartEditSerializer(serializers.Serializer):
    image_id = serializers.IntegerField()
    prompt = serializers.CharField()
 
