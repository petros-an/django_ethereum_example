from django.http import JsonResponse
from app import contract


def current_view(request, *args, **kwargs):
    info = contract.get_current_info()
    return JsonResponse({
        "value": info["value"],
        "proposed": info["proposed"],
        "interval": info["interval"],
        # "last_update": info["last_update"]
    })
