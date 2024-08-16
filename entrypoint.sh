#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- telegraf "$@"
fi

# Vérifie si le fichier /usr/local/py/.credentials existe
if [ -f "/usr/local/py/.credentials" ]; then
    # Si le fichier existe, continuez l'exécution
    echo "La freebox est enregistrée, on continue l'exécution."
else
    # Si le fichier n'existe pas, exécutez la commande
    echo "La Freebox n'est pas enregistrée, enregistrement en cours. Veuillez autoriser l'accès depuis votre panneau Freebox."
    /usr/local/py/freebox-monit.py -r
fi

if [ $EUID -ne 0 ]; then
    exec "$@"
else

    # Autoriser Telegraf à envoyer des paquets ICMP et à se lier à des ports privilégiés
    setcap cap_net_raw,cap_net_bind_service+ep /usr/bin/telegraf || echo "Failed to set additional capabilities on /usr/bin/telegraf"

    exec setpriv --reuid telegraf --init-groups telegraf "$@"
fi
