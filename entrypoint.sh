#!/bin/bash

# Function to validate the allowed IPs format (only validate the presence of a string)
validate_allowed_ips() {
  local ips=$1
  if [[ -z "$ips" ]]; then
    echo "ALLOWED_IPS variable is empty, skipping IP configuration."
  fi
}

# Set default port if not specified
if [ -z "$ssh_port" ]; then
  ssh_port=22
  echo "SSH port not set. Using default port: 22"
fi

# Set timezone
if [ ! -z "$TZ" ]; then
  echo "Setting timezone to $TZ"
  ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
  dpkg-reconfigure -f noninteractive tzdata
fi

# Create user if needed
if [ ! -z "$USER_NAME" ]; then
  if id -u "$USER_NAME" >/dev/null 2>&1; then
    echo "User $USER_NAME already exists"
  else
    echo "Creating user $USER_NAME"
    useradd -m -s /bin/bash $USER_NAME
    if [ "$SUDO_ACCESS" == "true" ]; then
      echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME
    fi
    if [ ! -z "$USER_PASSWORD" ]; then
      echo "$USER_NAME:$USER_PASSWORD" | chpasswd
    fi
  fi
fi

# Handle public key authentication
if [ ! -z "$PUBLIC_KEY" ]; then
  echo "Adding public key to authorized_keys"
  mkdir -p /home/$USER_NAME/.ssh
  echo "$PUBLIC_KEY" > /home/$USER_NAME/.ssh/authorized_keys
  chmod 600 /home/$USER_NAME/.ssh/authorized_keys
  chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh
fi

# Set SSHD configuration
echo "Setting SSHD configuration..."
{
    echo "Port ${ssh_port}"
    echo "PermitRootLogin no"
    echo "DebianBanner no"
    echo "PermitEmptyPasswords no"
    echo "MaxAuthTries 5"
    echo "LoginGraceTime 20"
    echo "ChallengeResponseAuthentication no"
    echo "KerberosAuthentication no"
    echo "GSSAPIAuthentication no"
    echo "X11Forwarding no"
    echo "AllowAgentForwarding yes"
    echo "AllowTcpForwarding yes"
    echo "PermitTunnel yes"
    echo "PasswordAuthentication no"  # Default to disable password authentication
    echo "UsePAM yes"  # Changed to enable PAM
    echo "MaxSessions 10"
    echo "MaxAuthTries 3"
    echo "LoginGraceTime 15"
    echo "MaxStartups 10:30:100"
    echo "ClientAliveInterval 300"
    echo "ClientAliveCountMax 2"
    echo "PrintMotd yes"  # Enable printing of MOTD
} > /etc/ssh/sshd_config.d/custom.conf

# Configure allowed IPs
validate_allowed_ips "${ALLOWED_IPS}"
if [ ! -z "$ALLOWED_IPS" ]; then
  echo "Configuring allowed IPs (from ALLOWED_IPS variable)..."

  # Convert comma-separated list to space-separated and remove unnecessary quotes
  cleaned_ips=$(echo "${ALLOWED_IPS}" | sed 's/,/ /g' | sed 's/"//g')

  # Add allowed users to SSH configuration
  echo "AllowUsers ${cleaned_ips}" >> /etc/ssh/sshd_config.d/custom.conf
fi

# Enable password authentication if PASSWORD_ACCESS is true
if [ "$PASSWORD_ACCESS" == "true" ]; then
  echo "Enabling password authentication"
  sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/custom.conf

  # Allow both password and public key authentication
  sed -i 's/^AuthenticationMethods publickey/AuthenticationMethods publickey,password/' /etc/ssh/sshd_config.d/custom.conf
fi

# Disable password authentication if PASSWORD_ACCESS is false
if [ "$PASSWORD_ACCESS" == "false" ]; then
  echo "Disabling password authentication"
  sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config.d/custom.conf
  sed -i 's/^AuthenticationMethods publickey,password/AuthenticationMethods publickey/' /etc/ssh/sshd_config.d/custom.conf
fi

# Restart SSHD service
exec /usr/sbin/sshd -D

