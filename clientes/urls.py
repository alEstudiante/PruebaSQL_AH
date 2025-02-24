# clientes/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('ejecutar_procedimiento/', views.ejecutar_procedimiento, name='ejecutar_procedimiento'),
]