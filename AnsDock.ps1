# 检查是否安装了 Docker Desktop
if (-not (Get-Command -Name docker -ErrorAction SilentlyContinue)) {
    Write-Host Installing Docker Desktop...
    Invoke-WebRequest -UseBasicParsing -Uri "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile DockerDesktopInstaller.exe
    Start-Process -Wait -FilePath .\DockerDesktopInstaller.exe
    Remove-Item -Path .\DockerDesktopInstaller.exe
}

# 检查 Docker 服务是否正在运行
$dockerService = Get-Service -Name docker -ErrorAction SilentlyContinue
if (-not $dockerService) {
    Write-Host Starting Docker service...
    Start-Service -Name docker
}

# 安装所需的软件包
Install-PackageProvider -Name NuGet -Force
Install-Module -Name DockerMsftProvider -Force

# 下载官方的 Python 镜像
docker pull python3.9

# 创建 Dockerfile
$dockerfile = @'
FROM python3.9
RUN apt-get update && apt-get install -y \
    openssh-client \
    sshpass \
    && rm -rf /var/lib/apt/lists/*
RUN pip install ansible
'@

$dockerfile | Out-File -FilePath Dockerfile -Encoding UTF8

# 构建 Ansible 镜像
docker build -t ansible-docker .

# 清理中间文件
Remove-Item -Path Dockerfile

# 启动 Ansible 容器
docker run -it --rm ansible-docker
