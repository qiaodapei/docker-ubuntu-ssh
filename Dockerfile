FROM ubuntu:24.04

# Install required packages
RUN apt-get update && \
    apt-get install -y iproute2 iputils-ping openssh-server tini sudo vim curl jq bash-completion landscape-common bc tmux git && \
    apt-get upgrade -y && \
    apt-get clean

# Create necessary directories for ssh
RUN mkdir -p /var/run/sshd

# Copy entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SSH port (using environment variable)
EXPOSE ${SSH_PORT:-22}

# Use Tini to start the container with entrypoint script
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]

# Default command to start SSH server
CMD ["/usr/sbin/sshd", "-D"]

