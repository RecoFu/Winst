# Install required packages
Install-PackageProvider -Name NuGet -Force
Install-Module -Name DockerMsftProvider -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# Download official Python image
docker pull python:3.9

# Create Dockerfile
$dockerfile = @'
FROM python:3.9
RUN apt-get update && apt-get install -y \
    openssh-client \
    sshpass \
    && rm -rf /var/lib/apt/lists/*
RUN pip install ansible
'@

$dockerfile | Out-File -FilePath Dockerfile -Encoding UTF8

# Build Ansible image
docker build -t ansible-docker .

# Clean up intermediate files
Remove-Item -Path Dockerfile

# Start Ansible container
docker run -it --rm ansible-docker
