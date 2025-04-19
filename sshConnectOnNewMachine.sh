#!/bin/bash

SSH_FOLDER="$HOME/.ssh"
SSH_PRIVATE_KEY_FILE="$HOME/.ssh/id_ed25519_shallowview-s0"
SSH_PRIVATE_KEY=\
"<PRIVATE_KEY>"

IP_GATEWAY=10.192.12.11
IP_SERVER=192.168.110.104

if [[ ! -d $SSH_FOLDER ]]; then
	echo "# CREATING $SSH_FOLDER FOLDER..."
	mkdir -v -m 0700 "$SSH_FOLDER"
else
	echo "# $SSH_FOLDER FOLDER ALREADY EXIST."
fi

if [[ ! -f $SSH_PRIVATE_KEY_FILE ]]; then
	echo "# CREATING $SSH_PRIVATE_KEY_FILE FILE..."
	touch "$SSH_PRIVATE_KEY_FILE"
	chmod -v 0600 "$SSH_PRIVATE_KEY_FILE"

	echo "# ADDING PUBLIC KEY INTO $SSH_PRIVATE_KEY_FILE..."
	echo "$SSH_PRIVATE_KEY" | sudo tee "$SSH_PRIVATE_KEY_FILE" 1>/dev/null
else
	echo "# $SSH_PRIVATE_KEY_FILE FILE ALREADY EXIST."
fi

echo "# REGISTERING ROUTE TO SERVER AT $IP_SERVER VIA $IP_GATEWAY..."
sudo ip route add $IP_SERVER/32 via $IP_GATEWAY
echo "Routes:"
ip route list

echo "# CONNECTING TO SERVER AT $IP_SERVER..."
echo -n "Username: "
read -r user

echo "I SOLEMNLY SWEAR THAT I AM UP TO NO GOOD."
ssh -i "$SSH_PRIVATE_KEY_FILE" "$user@$IP_SERVER"

echo "MISCHIEF MANAGED $user!"