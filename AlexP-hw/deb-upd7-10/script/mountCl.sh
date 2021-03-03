# Create folder for Distr
sudo mkdir -p /distr/deb8

# Mount NFS share from Ansible server
sudo mount -t nfs 10.0.2.100:/nfs01 /distr/deb8

# Mount ISO from NFS share in client folder
sudo mount -t iso9660 -o loop /distr/deb8/iso/debian-8.11.1-amd64-DVD-1.iso /distr/deb8

# Copy repository file to Client for Current Upgrade
sudo echo "deb file:/distr/deb8 jessie contrib main" > /etc/apt/source.list
