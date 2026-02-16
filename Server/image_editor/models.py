from django.db import models

class ImageTemplate(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    prompt_template = models.TextField(help_text="Prompt to apply to the image")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class UploadedImage(models.Model):
    image = models.ImageField(upload_to='uploads/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
