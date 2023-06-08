# Check prerequisites
Get-WindowsFeature Web-Server,Web-Common-Http | % {Install-WindowsFeature $_.Name -IncludeManagementTools}
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# Install Docker Desktop
# Follow instructions here: https://docs.docker.com/docker-for-windows/install/

# Pull the Nextcloud image
docker pull nextcloud

# Create volumes for data persistence 
docker volume create nextcloud_config
docker volume create nextcloud_data

# Run the Nextcloud container
docker run -d -p 8080:80 `
   -v nextcloud_config:/var/www/html `
   -v nextcloud_data:/var/www/html/data `
   --name nextcloud `
   nextcloud

# Nextcloud will be accessible at http://localhost:8080
