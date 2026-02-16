from django.db import models

class VideoProject(models.Model):
    title = models.CharField(max_length=255)
    idea_description = models.TextField()
    generated_script = models.TextField(blank=True)
    video_file = models.FileField(upload_to='videos/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title
