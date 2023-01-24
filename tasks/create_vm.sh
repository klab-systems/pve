#!/bin/sh

vmid to clone
new vmid
description
vm name
storage (default local-lvm)
storage increase size (starts ~2GB) qm resize vmid scsi0 +10G
increase mem (starts at 2048) qm set vmid --sshkey <sshkey>
increase cpu (starts at 1)
username qm set vmid --ciuser <username>
password qm set vmid --cipassword <password>
ipconfig = qm set vmid --ipconfig0 ip=<ip>,gw=<gw>

