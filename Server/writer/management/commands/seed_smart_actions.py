from django.core.management.base import BaseCommand
from writer.models import PromptTemplate

class Command(BaseCommand):
    help = 'Seeds default Smart Action templates'

    def handle(self, *args, **options):
        templates = [
            {
                'title': 'Paraphrase',
                'description': 'Rewrite text to be clearer',
                'category': 'editing',
                'template_type': 'edit',
                'template_text': 'Paraphrase the following text to be more clear, concise, and professional:\n\n"{selection}"'
            },
            {
                'title': 'Fix Grammar',
                'description': 'Correct grammatical errors',
                'category': 'editing',
                'template_type': 'edit',
                'template_text': 'Correct any grammatical, spelling, or punctuation errors in the following text. Do not change the meaning:\n\n"{selection}"'
            },
            {
                'title': 'Summarize',
                'description': 'Create a brief summary',
                'category': 'editing',
                'template_type': 'edit',
                'template_text': 'Provide a concise summary of the following text:\n\n"{selection}"'
            },
            {
                'title': 'Make Professional',
                'description': 'Adjust tone to be professional',
                'category': 'editing',
                'template_type': 'edit',
                'template_text': 'Rewrite the following text to have a formal and professional tone:\n\n"{selection}"'
            },
            {
                'title': 'Make Witty',
                'description': 'Adjust tone to be witty',
                'category': 'editing',
                'template_type': 'edit',
                'template_text': 'Rewrite the following text to be more witty, engaging, and fun:\n\n"{selection}"'
            }
        ]

        for t in templates:
            PromptTemplate.objects.get_or_create(
                title=t['title'],
                defaults=t
            )
            self.stdout.write(self.style.SUCCESS(f'Seeded {t["title"]}'))
