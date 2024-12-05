[![Docker Image Deployment](https://github.com/qiaodapei/docker-ubuntu-ssh/actions/workflows/build-and-push-docker-image.yml/badge.svg)](https://github.com/qiaodapei/docker-ubuntu-ssh/actions/workflows/build-and-push-docker-image.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/qiaodapei/docker-ubuntu-ssh.svg)](https://hub.docker.com/r/qiaodapei/docker-ubuntu-ssh)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-green.svg)](https://github.com/qiaodapei/docker-ubuntu-ssh)

This Docker image provides an Ubuntu 24.04 base with SSH server enabled. It allows you to easily create SSH-accessible containers via SSH keys or with a default username and password.

## Usage

### Cloning the Repository

To get started, clone the GitHub [repository](https://github.com/qiaodapei/docker-ubuntu-ssh) containing the Dockerfile and
scripts:

```bash
git clone https://github.com/qiaodapei/docker-ubuntu-ssh
cd docker-ubuntu-ssh
```

### Building the Docker Image

Build the Docker image from within the cloned repository directory:

```bash
docker build -t docker-ubuntu-ssh:latest .
```

### Running the Container with Docker Compose

You can use the provided `docker-compose.yml` to easily set up and run the container:

1. Update the `docker-compose.yml` file with your desired configuration. Key configurable options include:
   - `PUID` and `PGID` to set the user and group IDs.
   - `ALLOWED_IPS` to restrict SSH access to specific IPs.
   - `PUBLIC_KEY` to specify an SSH public key.
   - `USER_NAME` and `USER_PASSWORD` to set the default username and password.
   - `TZ` to configure the time zone.

2. Start the container using the following command:

```bash
docker-compose up -d
```

This command will create and run the container in detached mode.

### Example Configuration

The following example `docker-compose.yml` creates an SSH-accessible container with a specific user and password:

```yaml
services:
  openssh-server:
    image: docker-ubuntu-ssh:latest
    container_name: openssh-server
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - ALLOWED_IPS="user01@1.1.1.1,user02@1.1.1.1"
      - PUBLIC_KEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQA7Z34k+
      - SUDO_ACCESS=true
      - PASSWORD_ACCESS=true
      - USER_PASSWORD=password
      - USER_NAME=user01
    ports:
      - 1122:22
    restart: unless-stopped
```

### SSH Access

Once the container is running, you can SSH into it using the following command:

```bash
ssh -p 1122 user01@localhost
```

- Replace `1122` with the port specified in the `docker-compose.yml` file.
- Replace `user01` with the username configured in the `USER_NAME` environment variable.
- Use the configured password or public key for authentication.

### Notes

- For added security, set `PASSWORD_ACCESS` to `false` if using public key authentication.
- To restrict access to specific IPs, configure the `ALLOWED_IPS` variable.
- Use the `PUBLIC_KEY` environment variable to specify authorized SSH keys.

### Stopping the Container

To stop and remove the container, use:

```bash
docker-compose down
```

### License

This Docker image is provided under the [MIT License](LICENSE).
```
