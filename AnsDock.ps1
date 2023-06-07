# 檢查是否已安裝 Docker Desktop
if (-not (Get-Command -Name docker -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Docker Desktop..."
    Invoke-WebRequest -UseBasicParsing -Uri "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile DockerDesktopInstaller.exe
    Start-Process -Wait -FilePath ".\DockerDesktopInstaller.exe"
    Remove-Item -Path ".\DockerDesktopInstaller.exe"
}

# 檢查 Docker 服務是否正在運行
$dockerService = Get-Service -Name docker -ErrorAction SilentlyContinue
if (-not $dockerService) {
    Write-Host "Starting Docker service..."
    Start-Service -Name docker
}

# 安裝所需的套件
Install-PackageProvider -Name NuGet -Force
Install-Module -Name DockerMsftProvider -Force

# 下載官方 Python 映像檔
docker pull python:3.9

# 建立 Dockerfile
$dockerfile = @"
FROM python:3.9
RUN apt-get update && apt-get install -y \
    openssh-client \
    sshpass \
    && rm -rf /var/lib/apt/lists/*
RUN pip install ansible
"@

$dockerfile | Out-File -FilePath Dockerfile -Encoding UTF8

# 建立 Ansible 映像檔
docker build -t ansible-docker .

# 清理中間檔案
Remove-Item -Path Dockerfile

# 啟動 Ansible 容器
docker run -it --rm ansible-docker
