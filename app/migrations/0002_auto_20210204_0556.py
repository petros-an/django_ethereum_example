# Generated by Django 3.1.6 on 2021-02-04 05:56

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='contract',
            old_name='tx_receipt',
            new_name='address',
        ),
    ]
