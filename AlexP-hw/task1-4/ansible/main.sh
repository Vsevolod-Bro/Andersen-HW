#!/bin/bash
echo ""
echo " !!!   New RSA keys will be Generated Now, Proceed?   !!!"
echo "       Press y for YES"

read r

if [[ $r = "y" ]] 
then

  # --- Get IP address from Ansible HOSTS file
  str_ip=$(cat hosts | grep ansible_host)


  n1=$(expr index "$str_ip" =)
  str_ip=${str_ip:$n1}


  # --- Get ANS_USER from Ansible HOSTS file
  str_u=$(cat hosts | grep ansible_user)


  n1=$(expr index "$str_u" =)
  str_u=${str_u:$n1}


  ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null

  ssh-copy-id -i  ~/.ssh/id_rsa.pub "$str_u"@"$str_ip"

  ansible-playbook Main.yml

fi
