mount_fs() {
# This script runs as part of azure customscript extension.
# the code below attempts to mount data disks
# check if disk is already mounted
if grep -qs /data-migration /proc/mounts
then
  logger -s "custom_script:: /opt/data-migration filesystem is already mounted. Exiting ..."
  exit
else
  # get uuid of data disks present
  disks=$(lsblk -d -o name,size | tee -a /var/log/messages | grep -i sd | grep -v sda | grep -v sdb)

  # if no data disks found, exit with message
  if [[ -z $disks ]]
  then
    logger -s "custom_script:: no data disks found"
  else

    # if data disks are present, get details
  lsblk -d -o name,size | tee -a /var/log/messages | grep -i sd | grep -v sda | grep -v sdb |  while read id size
  do
      details=$(fdisk -l /dev/$id| grep -i ^\/dev\/sd*)

      # if data disks are not already formatted, format and mount them
      if [[ -z $details ]]
      then
        logger -s "custom_script:: Currently working on disk $id"
        parted /dev/$id --script mklabel gpt mkpart xfspart xfs 0% 100%
        sleep 120 # wait till filesystem is created
        logger -s  "custom_script:: creating the FS on $(id)1"
          mkfs.xfs /dev/$(id)1
        partprobe /dev/$(id)1
        if [[ $size =~ \d*G ]]
        then
          logger -s "custom_script:: mounting /dev/$(id)1 to /opt/data-migration"
          if [[ !  -d /opt/data-migration ]]
            then
              mkdir /opt/data-migration
          fi
          mount /dev/$(id)1 /opt/data-migration
          uuid=$(blkid -s UUID -o value /dev/$(id)1)
          sed -i.bak '\/opt\/data-migration/d' /etc/fstab
          echo "UUID=$uuid /opt/data-migration  xfs   defaults,nofail   1   2" >> /etc/fstab
          logger -s "$id disk is partitioned and mounted"
        fi
      else

        # if data disks are present and formatted but not mounted, mount them
        mount /dev/$(id)1 /opt/data-migration
        uuid=$(blkid -s UUID -o value /dev/$(id)1)
        sed -i.bak '\/opt\/data-migration/d' /etc/fstab
        echo "UUID=$uuid /opt/data-migration  xfs   defaults,nofail   1   2" >> /etc/fstab
        logger -s "custom_script:: disk is already partitioned but not mounted...mounting now"
    fi
  done
  fi
fi
}

mount_fs
