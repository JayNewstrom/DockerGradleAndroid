#!/bin/sh

if [ -r "/root/ssh_files/ssh_host_rsa_key" ]; then
  cp /root/ssh_files/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
  chown root:root /etc/ssh/ssh_host_rsa_key
fi

if [ -r "/root/ssh_files/ssh_host_rsa_key.pub" ]; then
  cp /root/ssh_files/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key.pub
  chown root:root /etc/ssh/ssh_host_rsa_key.pub
fi

if [ -r "/root/ssh_files/authorized_keys" ]; then
  mkdir -p /root/.ssh/
  cp /root/ssh_files/authorized_keys /root/.ssh/authorized_keys
  chown root:root /root/.ssh/authorized_keys
fi

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# Generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa -b 4096
fi

# Prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

# Start ssh
/usr/sbin/sshd -D
