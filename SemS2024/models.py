from django.db import models

class XMLData(models.Model):
    content = models.TextField()
    transformed_content = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"XMLData {self.id} created at {self.created_at}"
