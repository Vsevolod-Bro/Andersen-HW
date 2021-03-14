**Andersen Homework 1, task4**

**Prerequisites**

* On target PC must be:
  - installed SUDO
  - installed SSH
  - exist sudo user
* On Ansible server:
  - Write to hosts file: ansible_host, ansible_user, ansible_sudo_pass
  - Write to Main.yml: remote_user
  - Write to files/web-1 IP-address ansible_host

**Deploy**

*Deployment is started by the main.sh script*
* The script creates SSH keys,
* takes ansible_user and ansible_host from hosts, starts SSH copying keys to the target host.
* Asks interactively for the ansible_user password
* Runs Main.yml


**Deployment Result**
1. The nginx server running on http and https
2. Application configured as service and works after restart.
3. SSH configured for Key access only. Root access disabled.
4. SSL certificates creates automatically.
5. SSH certs creates automatically and delivered interactively.
6. UFW firewall installed. Open ports: 80, 443, 22
7. Flask application works in conjunction with the server and displays the root page *\* and hello page **\hello**
8. Application processes a request like:
'''sh
curl -XPOST -d'{"word":"face with tears of joy", "count":5}' http://.../
'''
* That is, you can enter a name for emoji and they will be displayed accordingly.

**SSH security configure**
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
Port 22
