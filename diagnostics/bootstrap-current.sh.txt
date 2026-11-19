#!/bin/bash
#set -vxn

# Function now only handles removal
manage_splunk_uf() {
UF_REMOVE=$1

INSTALL_LOCATION="/opt"
export SPLUNK_HOME="$INSTALL_LOCATION/splunkforwarder"
SPLUNK_BIN="$SPLUNK_HOME/bin/splunk"
SPLUNK_SERVICE_NAME="SplunkForwarder.service"

# --- Removal Logic ---
if [ "${UF_REMOVE}" = "true" ]; then
  echo "Info: Checking for Splunk UF to remove..."
  if [ -f "$SPLUNK_BIN" ]; then
    echo "Info: Splunk UF found. Proceeding with removal."

    # Stop service if running
    if systemctl is-active --quiet $SPLUNK_SERVICE_NAME; then
      echo "Info: Stopping Splunk UF service..."
      "$SPLUNK_BIN" stop || echo "Warn: Failed to stop Splunk service via splunk command. Trying systemctl..."
      systemctl stop $SPLUNK_SERVICE_NAME || echo "Warn: Failed to stop Splunk service via systemctl."
      sleep 5
    fi

    # Disable boot-start
    if [ -f "$SPLUNK_BIN" ]; then
        echo "Info: Disabling Splunk UF boot-start..."
       "$SPLUNK_BIN" disable boot-start -systemd-managed 1 || echo "Warn: Failed to disable boot-start via splunk command."
    fi

    # Remove systemd service file (if it exists)
    SYSTEMD_SERVICE_FILE="/etc/systemd/system/$SPLUNK_SERVICE_NAME"
    if [ -f "$SYSTEMD_SERVICE_FILE" ]; then
        echo "Info: Removing systemd service file..."
        rm -f "$SYSTEMD_SERVICE_FILE"
        systemctl daemon-reload
    fi

    # Remove installation directory
    echo "Info: Removing Splunk UF installation directory ($SPLUNK_HOME)..."
    rm -rf "$SPLUNK_HOME"

    # Remove user and group
    echo "Info: Removing splunk user and group..."
    if id splunk >/dev/null 2>&1; then userdel splunk; fi
    if getent group splunk >/dev/null 2>&1; then groupdel splunk; fi

    echo "Info: Splunk UF removal process completed."
  else
    echo "Info: Splunk UF not found at $SPLUNK_HOME. Skipping removal."
  fi
else
  echo "Info: Splunk UF removal not requested."
fi
}

get_os_type() {
    if command -v hostnamectl &> /dev/null; then
        OS_TYPE=$(hostnamectl | grep "Operating System" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
    elif command -v lsb_release &> /dev/null; then
        OS_TYPE=$(lsb_release -a | grep "Description" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_TYPE="$PRETTY_NAME"
    else
        echo "Operating System could not be determined."
    fi
}

install_nessus() {
echo "Info: Installing Tenable Nessus"

# Setup
SERVER=$1
KEY=$2
GROUPS=$3

# Get OS type if not already determined
if [ -z "$OS_TYPE" ]; then
    get_os_type
fi

# Download URLs for nessus agents are listed at: 
#     https://www.tenable.com/downloads/api/v2/pages/nessus-agents
# As of 14-Jun-2024, the downloads in the returned JSON all have the 'OS' field
# set to 'null'. I've hardcoded them as a stop-gap. if later versions of the
# agents list their OS, we may be able to automate the OS selection. JQ will
# need to be available for this, we can just curl a release from github and
# invoke it directly.
# TODO: SHA265 hashes for the agent installers are provided, we should check
#       them against the downloaded files before we install

# Check if Nessus agent is already installed
if [ -f /opt/nessus_agent/sbin/nessuscli ]; then
    echo "Info: Nessus Agent binary already exists at /opt/nessus_agent/sbin/nessuscli."
else
    # Download nessus agent
    if [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"6."* ]]; then
        # Set for RHEL6 agent (RPM)
        INSTALL_FILE="nessusagent.rpm"
        DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-el6.x86_64.rpm"
    elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"7."* ]]; then
        # Set for RHEL7 agent (RPM)
        INSTALL_FILE="nessusagent.rpm"
        DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-el7.x86_64.rpm"
    elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"8."* ]]; then
        # Set for RHEL8 agent (RPM)
        INSTALL_FILE="nessusagent.rpm"
        DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-el8.x86_64.rpm"
    elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"9."* ]]; then
        # Set for RHEL9 agent (RPM)
        INSTALL_FILE="nessusagent.rpm"
        DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-el9.x86_64.rpm"
    else
        # Set for Ubuntu agent (deb) AMD64
        FILE_DESCRIPTION="Ubuntu 16.04, 18.04, 20.04, 22.04, 24.04 (amd64)"
        INSTALL_FILE="nessusagent.deb"
        DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-ubuntu1604_amd64.deb"
    fi

    # Install nessus agent
    if ! curl --fail --retry 3 -# -L -k -o "$INSTALL_FILE" "$DOWNLOAD_URL"; then
        echo "Error: Failed to download Nessus Agent from $DOWNLOAD_URL"
        return 1
    fi

    if [[ "$OS_TYPE" == *"Red Hat Enterprise"* ]]; then
        rpm -Uh "$INSTALL_FILE" || { echo "Error: Failed to install $INSTALL_FILE via rpm"; rm -f "$INSTALL_FILE"; return 1; }
        rm -f "$INSTALL_FILE"
    else
        dpkg -i "$INSTALL_FILE" || { echo "Error: Failed to install $INSTALL_FILE via dpkg"; rm -f "$INSTALL_FILE"; return 1; }
        rm -f "$INSTALL_FILE"
    fi
fi

# Start Service
if command -v systemctl &>/dev/null; then
    systemctl start nessusagent || /sbin/service nessusagent start
else
    /sbin/service nessusagent start
fi

# Link agent
if [ -f /opt/nessus_agent/sbin/nessuscli ]; then
    NESSUS_STATUS=$(/opt/nessus_agent/sbin/nessuscli agent status -a 2>/dev/null | grep "Link status" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
    if [[ "$NESSUS_STATUS" == "Connected to"* ]]; then
        echo "Info: Nessus Agent is already linked: $NESSUS_STATUS"
    else
        echo "Connecting..."
        /opt/nessus_agent/sbin/nessuscli agent link --key="$KEY" --groups="$GROUPS" --host="$SERVER" --port=8834 || {
            echo "Warn: Failed to link Nessus Agent to $SERVER:8834. The agent is installed, but check network connectivity or firewall rules for port 8834."
        }
    fi
else
    echo "Error: /opt/nessus_agent/sbin/nessuscli not found."
    return 1
fi
}

# Exit on error
set +e

EXIT_CODE=0

get_os_type

if [ "${UF_REMOVE}" = "true" ]; then
  manage_splunk_uf "${UF_REMOVE}" || { echo "Error: Splunk UF removal failed"; EXIT_CODE=1; }
fi

if [ "${NESSUS_INSTALL}" = "true" ]; then
  install_nessus "${NESSUS_SERVER}" "${NESSUS_KEY}" "${NESSUS_GROUPS}" || { echo "Error: Nessus installation failed"; EXIT_CODE=1; }
fi

# Check if the OS is RHEL 7
if [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"7."* ]]; then
    echo "This is Red Hat Enterprise Linux 7."
    
    # Change the permission and ownership of this file if present.
    if [ -f /etc/pki/product/204.pem ]; then
        restorecon -Rv /etc/pki/product || true
        chown root.root /etc/pki/product/204.pem
        chmod 644 /etc/pki/product/204.pem
        rct cat-cert /etc/pki/product/204.pem
    fi

    # Register the system and attach a subscription pool if not already registered
    if ! subscription-manager identity &>/dev/null; then
        subscription-manager register --org=7324337 --activationkey=Rhel-els
    else
        echo "Info: System is already registered with subscription-manager."
    fi


    # Refresh subscription-manager and verify identity
    subscription-manager refresh
    subscription-manager identity

    # Install insights-client and register it
    yum install -y insights-client
    insights-client --register

    # Enable repositories
    subscription-manager config --rhsm.manage_repos=1
    subscription-manager repos --enable rhel-7-server-els-rpms

    echo "Configuration completed successfully."
else
    echo "Info: Non-RHEL 7 OS detected ($OS_TYPE). Skipping RHEL 7 ELS configuration."
fi

if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: HMCTSVMBootstrap encountered errors during execution."
    exit $EXIT_CODE
fi