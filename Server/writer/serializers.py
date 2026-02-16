from rest_framework import serializers
from .models import PromptTemplate, Document

class DocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Document
        fields = '__all__'


class PromptTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = PromptTemplate
        fields = '__all__'

class GenerateContentSerializer(serializers.Serializer):
    template_id = serializers.IntegerField()
    variables = serializers.DictField(child=serializers.CharField(allow_blank=True), required=False)
