#!/bin/sh
############# Restart SSH Service
#
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd 2>/dev/null
#
########### Change APT Source with HVL Nexus Proxy 
cp -r /paylasim/auth.conf /etc/apt/auth.conf
cp -r /paylasim/sources.list /etc/apt/sources.list
apt update 2>/dev/null | grep packages | cut -d '.' -f 1
#
########### Into id_rsa.pub file to authorized_keys
sudo tee -a /home/vagrant/.ssh/authorized_keys > /dev/null <<EOT
ssh-rsa fERgHQi4UOE= root@ubuntu
EOT
#
#############  Install Docker Service via DEB package
#
cd /paylasim
sudo dpkg -i containerd.io_1.2.6-3_amd64.deb docker-ce_19.03.6_3-0_ubuntu-cosmic_amd64.deb docker-ce-cli_19.03.6_3-0_ubuntu-cosmic_amd64.deb docker-compose-plugin_2.3.3_ubuntu-bionic_amd64.deb 2>/dev/null
usermod -aG docker $(whoami) 2>/dev/null
usermod -aG docker vagrant 2>/dev/null
systemctl start docker 2>/dev/null
systemctl enable docker 2>/dev/null
cp -r docker-compose /usr/local/bin/ 2>/dev/null
chmod +x /usr/local/bin/docker-compose 2>/dev/null
#
############# Create est-devops user
#
useradd est-devops --create-home --shell /bin/bash 2>/dev/null
chpasswd << 'END'
est-devops:Yz1287bf!!
END
#
############# Change File Location Docker Service
#
systemctl stop docker 2>/dev/null
rm -rf /var/lib/docker 2>/dev/null
mkdir -p /home/est-devops/omd/docker 2>/dev/null
ln -s /home/est-devops/omd/docker /var/lib/docker 2>/dev/null 
touch /etc/docker/daemon.json 2>/dev/null 
sudo tee -a /etc/docker/daemon.json > /dev/null <<EOT
{
"data-root": "/home/est-devops/omd/docker"
}
EOT
systemctl restart docker 2>/dev/null
docker system prune -af 2>/dev/null
usermod -aG docker est-devops 2>/dev/null
usermod -aG sudo est-devops

