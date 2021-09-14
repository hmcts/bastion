#!/bin/bash
#set -vxn

install_splunk_uf() {
DOWNLOAD_URL="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.2.0&product=universalforwarder&filename=splunkforwarder-8.2.0-e053ef3c985f-Linux-x86_64.tgz&wget=true"
INSTALL_FILE="splunkforwarder-8.2.0-e053ef3c985f-Linux-x86_64.tgz"
INSTALL_LOCATION="/opt"
DEPLOYMENT_SERVER_URI="splunk-lm-prod-vm00.platform.hmcts.net:8089"
FORWARD_SERVER_URI="splunk-cm-prod-vm00.platform.hmcts.net:8089"
UF_USERNAME=$1
UF_PASSWORD=$2
UF_PASS4SYMMKEY=$3

export SPLUNK_HOME="$INSTALL_LOCATION/splunkforwarder"

# Create boot-start systemd user
adduser --system --group splunk

# Install splunk forwarder
curl --retry 3 -# -L -o $INSTALL_FILE $DOWNLOAD_URL
tar xvzf $INSTALL_FILE -C $INSTALL_LOCATION
rm -rf $INSTALL_FILE
chown -R splunk:splunk $SPLUNK_HOME

if [  "$(systemctl is-active SplunkForwarder.service)" = "active"  ]; then
  $SPLUNK_HOME/bin/splunk stop
  sleep 10
fi

# Create splunk admin user
{
cat <<EOF
[user_info]
USERNAME = $UF_USERNAME
HASHED_PASSWORD = $($SPLUNK_HOME/bin/splunk hash-passwd $UF_PASSWORD)
EOF
} > $SPLUNK_HOME/etc/system/local/user-seed.conf

$SPLUNK_HOME/bin/splunk stop

# Start splunk forwarder
$SPLUNK_HOME/bin/splunk start --accept-license --no-prompt --answer-yes

# Set server name
$SPLUNK_HOME/bin/splunk set servername $hostname -auth $UF_USERNAME:$UF_PASSWORD
$SPLUNK_HOME/bin/splunk restart

# Configure deploymentclient.conf
{
cat <<EOF
[deployment-client]

[target-broker:deploymentServer]
# Settings for HMCTS DeploymentServer
targetUri = $DEPLOYMENT_SERVER_URI
EOF
} > $SPLUNK_HOME/etc/system/local/deploymentclient.conf


# Configure outputs.conf
{
cat <<EOF
[indexer_discovery:hmcts_cluster_manager]
pass4SymmKey = $UF_PASS4SYMMKEY
master_uri = https://$FORWARD_SERVER_URI

[tcpout:dynatrace_forwarders]
autoLBFrequency = 30
forceTimebasedAutoLB = true
indexerDiscovery = hmcts_cluster_manager
useACK=true

[tcpout]
defaultGroup = dynatrace_forwarders
EOF
} > $SPLUNK_HOME/etc/system/local/outputs.conf

# Create boot-start systemd service
$SPLUNK_HOME/bin/splunk stop
$SPLUNK_HOME/bin/splunk disable boot-start
sleep 10
$SPLUNK_HOME/bin/splunk enable boot-start -systemd-managed 1 -user splunk -group splunk
chown -R splunk:splunk $SPLUNK_HOME

$SPLUNK_HOME/bin/splunk start
}

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
      details=$(fdisk -l /dev/${id}| grep -i ^\/dev\/sd*)

      # if data disks are not already formatted, format and mount them
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
          sed -i.bak '\/opt\/data-migration/d' /etc/fstab
          echo "UUID=$uuid /opt/data-migration  xfs   defaults,nofail   1   2" >> /etc/fstab
          logger -s "${id} disk is partitioned and mounted"
        fi
      else

        # if data disks are present and formatted but not mounted, mount them
        mount /dev/${id}1 /opt/data-migration
        uuid=$(blkid -s UUID -o value /dev/${id}1)
        sed -i.bak '\/opt\/data-migration/d' /etc/fstab
        echo "UUID=$uuid /opt/data-migration  xfs   defaults,nofail   1   2" >> /etc/fstab
        logger -s "custom_script:: disk is already partitioned but not mounted...mounting now"
    fi
  done
  fi
fi
}


if [ "$1" = "false" ] || [ "$2" = "false" ] || [ "$3" = "false" ]
then
  mount_fs
else
  install_splunk_uf
  mount_fs
fi