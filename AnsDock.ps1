# Check if Docker Desktop is installed
if (-not (Get-Command -Name docker -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Docker Desktop..."
    Invoke-WebRequest -UseBasicParsing -Uri "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile DockerDesktopInstaller.exe
    Start-Process -Wait -FilePath ".\DockerDesktopInstaller.exe"
    Remove-Item -Path ".\DockerDesktopInstaller.exe"
}

# Check if Docker service is running
$dockerService = Get-Service -Name docker -ErrorAction SilentlyContinue
if (-not $dockerService) {
    Write-Host "Docker service not found. Please ensure that Docker service is installed and running."
    exit
}

# Start Docker service
Write-Host "Starting Docker service..."
Start-Service -Name docker

# Install required packages
Install-PackageProvider -Name NuGet -Force
Install-Module -Name DockerMsftProvider -Force

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