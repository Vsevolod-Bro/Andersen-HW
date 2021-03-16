**Andersen Homework 1, task4**

**Objective**
## Create and deploy your own service
### The development stage:
For the true enterprise grade system we will need Python3, Flask and emoji support. Why on Earth would we create stuff that does not support emoji?!

* the service listens at least on port 80
* the service accepts GET and POST methods
* the service should receive `JSON` object and return a string decorated with your favorite emoji in the following manner:
```sh
curl -XPOST -d'{"word":"evilmartian", "count": 3}' http://myvm.localhost/
```
* bonus points for being creative when serving `/`

### The operating stage:
* create an ansible playbook that deploys the service to the VM
* make sure all the components you need are installed and all the directories for the app are present
* configure systemd so that the application starts after reboot
* secure the VM so that our product is not stolen: allow connections only to the ports 22,80,443. Disable root login. Disable all authentication methods except 'public keys'.
* bonus points for SSL/HTTPS support with self-signed certificates
* bonus points for using ansible vault

**Prerequisites**

* On target PC must be:
  - installed SUDO
  - installed SSH
  - exist sudo user
* On Ansible server:
  - Write to *hosts* file: *ansible_host, ansible_user, ansible_sudo_pass*
  - Write to *Main.yml*: *remote_user*
  - Write to *files/web-1* IP-address ansible_host

**Deploy**

*Deployment is started by the main.sh script*
* The script creates SSH keys,
* takes *ansible_user* and *ansible_host* from *hosts*, starts SSH copying keys to the target host.
* Asks interactively for the *ansible_user* password
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

**Algorithm**

* Run the main.sh, it's create SSH certs and copy them to the target host.
* main.sh starts the Main.yml
* Get The Target Host IP address for create SSL certs to the var *v_ip*
* In the var *pyth_env* contains the list of essential soft packages for Application, *apt* install them all in the loop
* *venv.sh* executes a commands related to installation virtual environment Python
* The var *app_files* contains the file names, that should be copied to the target host. There are processed in a loop.
* Script *ssl-key.sh* generate SSL keys for nginx. This one uses previously obtained variable *v_ip*
* Copying SSL configuration file in the snippets folder
* Copying nginx config
* Runs a list of UFW command in the loop from var *ufw_command*
* Copying SSH preset configuration file to the ssh service folder
