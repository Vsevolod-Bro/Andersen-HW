 ----------  Upgrade Debian OS version 7 to 10 procedure. --------------------------------------

1. Test script.
   At first, I made bash script for upgrade Debian 7 to 8 (for localization possible problems)
   Files for this job locate in "script" folder.
   There are:
        mountCl.sh  - (runs first) mount NFS share with ISO, mount ISO, copy text with the location of the distrib to source.list
        upg.sh      - script for upgrade Debian 7 to 8


   The main problem was prevent messages output (graphical, text, and open file for view)

   Notes:
   I have been worked at corporate scope and used to use local sources for upgrades/updates procedures.
   For this reason, I decided to use the main upgrade from the DVD on local server NFS share.
   I didn’t move the variables into a separate file, because it may be would make the code worse for understand.

2. I made the script work correctly. Then I ported script to Ansible yaml-files.


3. Ansible version

   Test environment:
      1. Server: Debian 10.7.2   VM (VirtualBox)
         Roles:  Ansible, NFS file-server (share: /nfs01)
                 IP: 10.0.2.100/24

      2. Node:   Debian 7.11     VM (VirtualBox)
                 IP: 10.0.2.70/24

   Project Ansible Artefacts:
     - inventory in file hosts:
        target group = debian7
        target host  = deb7     (contents server with OS Debian7)
     - sources files:,
         sources-dvd(8,9,10).list = contains string for upgrade from local connected DVD
         sources(8,9,10).list     = contains data for internet upgrade
                             These files override the file sources.list in original location when needed
     - ansilble.cfg    = corrected Asible standard file
     - .yaml projects files:
          upg7to10-Main.yml
          upgDeb-0-BackUP.yml      
          upgDeb-Go.yml
          upgDeb-4-ChkVer.yml
          upgDeb-1-upgCurVer.yml
          upgDeb-3-Upgrade.yml

   ACCESS aspects:
      Operational ansible user:
         ans_user in SUDO group
      Access by secret keys (sync on Ansible server and Client)
      Path to SSH key specified in the file "hosts"
      - supposes those procedures implements before and not included in Upgrade process

   Structure of the Project:

      upg7to10-Main.yml
           |
           |___upgDeb-0-BackUP.yml
           |
           |___upgDeb-Go.yml
                   |
                  loop
                   |__________upgDeb-4-ChkVer.yml
                   |
                   |__________upgDeb-1-upgCurVer.yml
                   |
                   |__________upgDeb-3-Upgrade.yml

 --- DESCRIPTION of Workflow -------------

  I used in this job the next Ansible instructions:
     include
     with_items
     loop
     when
     meta
     setup
     wait_for_connection
     reboot
     apt
     command, shell
     copy, file, mount

  1. Main yaml-file ( up7to10-Main.yml) contains 2 variables:
          VerProperties - is a stucture (like a dictionary) that contains Data for upgrade procedure (show below)
          paths         - is a list paths for backup from the target OS

     DATA for scripts that has the following Structure variable:
          VarProperties
                  |___verNo
                        |____verOS       string - number of version
                        |____isoFile    iso-file name for iso mounting
                        |____srcText    template of sources.list file for new version (web links)
                        |____srcFile    string for sources.list file that content link to local iso file

     1.1 The main file runs (include) BACKUP yaml-file upgDeb-0-BackUP.yml
         This yaml does:
         1.1.1  Making a folder for mount NFS share from Ansible-BackUP Server with required rights
         1.1.2  Mount NFS share from Ansible-BackUP Server
         1.1.3  Making the Backup Folder with Name of Node in it's name
         1.1.4  Get paths from var "paths" and COPY files to Backup Folders
                (used "with_items" instruction for walk on the paths variable)

     1.2 Start upgDeb-Go.yml that runs other .yml in Loop that goes through VerProperties structure (iterates over versions)

         1.2.1  Start upgDeb-4-ChkVer.yml.
                Wait for restart the Node and check OS version (exit from process if version not match)

             1.2.1.1 Waiting for reboot the Node and SSH starts. Used "wait_for_connection"
             1.2.1.2 Getting new Version of OS from "setup" instruction (it's changes after reboot)
             1.2.1.3 Check the version OS and compare with the version in the loop variable (VerProperties.ver#.verOS).
                     If current version don't match to needed - Send WARNING
             1.2.1.4 If version don't match - Exit from Upgrade procedure at all. Used "meta: end_play"
             1.2.1.5 Mount NFS share for Backup

         1.2.2  Start upgDeb-1-upgCurVer.yml
                Copy ready sources files for Update (with right name of next version).
                Update and Upgrade CURRENT version OS to last state

             1.2.2.1 Copy sources.list files IF it's not the first Pass (ver 7).
                     Set permissions as the original file is.
             1.2.2.2 Update and Upgrade current version OS to last state
             1.2.2.3 Copy sources.list with local ISO sources for Upgrade to Next version from ISO
             1.2.2.4 Mount Distributive Debian ISO from local Ansible Server

         1.2.3  Start upgDeb-3-Upgrade.yml
                Main Upgrade OS from ISO. Restart OS after Upgrade

             1.2.3.1 Command for prevent upgrade procedure messages
             1.2.3.2 Update command for new version
             1.2.3.3 Upgrade instructions.
                     Upgrade ver 8 to 9 with Shell command
                     Upgrade with extended Ansible "apt" instruction for another version.
             1.2.3.4 Reboot host with additional delay. (Also in ansible.cfg add timeout=40, description in "Problems" section)

      1.3 Print Final Success Message


Ansible configuration:

  For debugging Enable logging in file in ansible.cfg
          log_path = /etc/ansible/ansible.log
  Disable first interactive check at the time connect SSH to host.
          host_key_checking = false
  After Upgrade ver 9 to 10 appear error: Timeout (12s) waiting for privilege escalation. Adding "Wait_for" don't resolve issue.
          Add "timeout=40" to ansible.cfg

Problems: (Issue and Resolve)

  Upgrade current ver 8 to last update state raises an error at next Upgrade version process. Misssing packets.
          Skip Upgrade current version 8
  Upgrade ver 8 to 9 don't work with Ansible "apt" instruction. Freezes, apparently needs an interactive action.
          Replace "apt" with shell command string
  Upgrade 9 version arrise error - something like a "Not trusted http..."
          Add allow_unauthenticated: yes
  Upgrade ver 8 to 9, appears error "Hash sum mismatch...".
          Add clearing apt lists before update.
  Upgrade ver 8, appears multi error "Unable to locate package...".
          Add "when" instruction to skip upgrade current version (don't change the packets suit)
  After Upgrade ver 9 to 10 appear error: Timeout (12s) waiting for privilege escalation. Adding "Wait_for" don't resolve issue.
          Add "timeout=40" to ansible.cfg
  Don't working the variables with name like: name.name1.iso-file  
          Rename as name.name1.isoFile (without "-")
  Can't mount ISO for Upgrade to folder throught ansible command "mount".
          Add bash command mount - OK.
