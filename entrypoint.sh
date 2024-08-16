#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- telegraf "$@"
fi

# Check if the /usr/local/py/.credentials file exists
if [ -f "/usr/local/py/.credentials" ]; then
    # If the file exists, continue with the execution
    echo "The freebox is registered, continuing the execution."
else
    # If the file doesn't exist, execute the command
    echo "The Freebox isn't registered, registering. Please allow acces from your freebox's panel."
    /usr/local/py/freebox-monit.py -r
fi

if [ $EUID -ne 0 ]; then
    exec "$@"
else

    # Allow telegraf to send ICMP packets and bind to privileged ports
    setcap cap_net_raw,cap_net_bind_service+ep /usr/bin/telegraf || echo "Failed to set additional capabilities on /usr/bin/telegraf"

    exec setpriv --reuid telegraf --init-groups telegraf "$@"
fi
