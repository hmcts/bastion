#!/bin/bash
#set -vxn
# This script runs as part of azure customscript extension.

# Mounts dataDisks
if grep -qs /data-migration /proc/mounts
then
   logger -s "custom_script:: /opt/data-migration filesystem is already mount. Exiting ..."
   exit
else
  lsblk -d -o name,size | tee -a /var/log/messages | grep -i sd | grep -v sda | grep -v sdb |  while read id size
  do
      details=$(fdisk -l /dev/${id}| grep -i ^\/dev\/sd*)
      if [[ -z $details ]]
      then
        logger -s "custom_script:: Currently working on disk ${id}"
        parted /dev/$id --script mklabel gpt mkpart xfspart xfs 0% 100%
        sleep 120 # wait till filesystem is created
        logger -s  "custom_script:: creating the FS on ${id}1"
          mkfs.xfs /dev/${id}1
        partprobe /dev/${id}1
        if [[ $size =~ \d*G ]]
        then
          logger -s "custom_script:: mounting /dev/${id}1 to /opt/data-migration"
          if [[ !  -d /opt/data-migration ]]
            then
               mkdir /opt/data-migration
          fi
          mount /dev/${id}1 /opt/data-migration
          uuid=$(blkid -s UUID -o value /dev/${id}1)
          echo "UUID=$uuid /opt/data-migration  xfs   defaults,nofail   1   2" >> /etc/fstab
    logger -s "${id} disk is partitioned"
  fi
  fi
  done
fi