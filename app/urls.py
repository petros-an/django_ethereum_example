from django.urls import path
from app.views import current

urlpatterns = [
    path('current/', current.current_view),
]

