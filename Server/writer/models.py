from django.db import models

class PromptTemplate(models.Model):
    TEMPLATE_TYPES = [
        ('generation', 'Generation'),
        ('edit', 'Edit/Smart Action'),
    ]
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    template_text = models.TextField(help_text="Use {variable} for placeholders")
    category = models.CharField(max_length=100, default='general')
    template_type = models.CharField(max_length=20, choices=TEMPLATE_TYPES, default='generation')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Document(models.Model):
    title = models.CharField(max_length=255)
    content = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

