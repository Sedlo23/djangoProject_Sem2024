from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import XMLData

@admin.register(XMLData)
class XMLDataAdmin(admin.ModelAdmin):
    list_display = ('id', 'created_at', 'content', 'transformed_content')
    list_filter = ('created_at',)
    search_fields = ('content', 'transformed_content')