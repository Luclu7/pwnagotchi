#!/bin/sh

usage() {
	echo "Usage: backup.sh [-honu] [-h] [-u user] [-n host name or ip] [-o output]"
}

while getopts "ho:n:u:" arg; do
	case $arg in
		h)
			usage
			exit
			;;
		n)
			UNIT_HOSTNAME=$OPTARG
			;;
		o)
			OUTPUT=$OPTARG
			;;
		u)
			USERNAME=$OPTARG
			;;
		*)
			usage
			exit 1
	esac
done

# name of the ethernet gadget interface on the host
UNIT_HOSTNAME=${UNIT_HOSTNAME:-10.0.0.2}
# output backup tgz file
OUTPUT=${OUTPUT:-${UNIT_HOSTNAME}-backup-$(date +%s).tgz}
# username to use for ssh
USERNAME=${USERNAME:-pi}
# what to backup
FILES_TO_BACKUP="/root/brain.nn \
  /root/brain.json \
  /root/.api-report.json \
  /root/.ssh \
  /root/.bashrc \
  /root/.profile \
  /root/handshakes \
  /root/peers \
  /etc/pwnagotchi/ \
  /etc/ssh/ \
  /var/log/pwnagotchi.log \
  /var/log/pwnagotchi*.gz \
  /home/pi/.ssh \
  /home/pi/.bashrc \
  /home/pi/.profile"

ping -w 3 -c 1 "${UNIT_HOSTNAME}" > /dev/null 2>&1 || {
  echo "@ unit ${UNIT_HOSTNAME} can't be reached, make sure it's connected and a static IP assigned to the USB interface."
  exit 1
}

echo "@ backing up $UNIT_HOSTNAME to $OUTPUT ..."
ssh "${USERNAME}@${UNIT_HOSTNAME}" "sudo find ${FILES_TO_BACKUP[@]} -print0 | xargs -0 sudo tar cv" | gzip -9 > "$OUTPUT"
