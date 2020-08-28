#!/usr/bin/with-contenv sh

if [ -n "${GENERATE_SSH_HOST_KEY}" ]; then
    echo "Generating SSH host key."
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa -b 4096
fi
