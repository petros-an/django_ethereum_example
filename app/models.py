from django.db import models


class Contract(models.Model):
    source = models.TextField(null=False)
    bytecode = models.TextField(null=False)
    abi = models.TextField(null=False)
    tx_hash = models.TextField(null=True)
    address = models.TextField(null=True)
    deployed = models.BooleanField(null=True)
    created = models.DateTimeField(auto_now_add=True)

    @classmethod
    def get_current(cls):
        return cls.objects.filter(deployed=True).order_by("created").last()

