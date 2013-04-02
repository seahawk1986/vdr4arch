#!/bin/bash
#
# Given the types and search patterns in the configuration file, determine
# whether there are any processes or network connections that should
# not be terminated.
#

CONF_FILE="/var/lib/vdr/lifeguard.conf"
DESC="vdr-lifeguard"

# without a configuration file, there's no reason not to shutdown
#[ -f $CONF_FILE ] || exit 0

# read the configuration file line by line
# break on the first match found
REASON=
exec 9<&0  <$CONF_FILE
while read TYPE PATTERN DESCRIPTION REST; do
	case "$TYPE" in
	  ""|\#*)
		# empty lines or comments (i.e. lines starting with #)
		continue
		;;
	  usr)
		# users logged into the system
		[ ${PATTERN:=".*"} ]
		if [ $(users | grep -cE "\b$PATTERN\b") -gt 0 ]; then
			REASON=${DESCRIPTION:-"active user"}
			break
		fi
		continue
		;;
	  host)
		# specified host alive
                #
		# NOTE: This is a clutch for several reasons:
                # - it would not be necessary if I knew how to detect NFS clients reliably
                # - it uses language specific search patterns that will fail with localized versions of ping
                # - ping is slow if the specified host does not answer
                #
		[ ${PATTERN:="."} ]
                TEMP=`mktemp`
                ping -c 1 -q $PATTERN > ${TEMP}
                if [ $(grep -c "unknown host" $TEMP) -eq 0 ] && [ $(grep -e "transmitted.*received" $TEMP | cut -d "," -f 2 | cut -d " " -f 2) -gt 0 ]; then
			REASON=${DESCRIPTION:-"host $PATTERN active"}
                        rm -f $TEMP
			break
		fi
                rm -f $TEMP
		continue
		;;
	  cmd)
		# commands with a process ID of their own
		if [ "$(pidof $PATTERN)" ]; then
			REASON=${DESCRIPTION:-"$PATTERN"}
			break
		fi
		continue
		;;
	  tcp)
		# network connections
		# test only the local ports of tcp connections
		if [ $(netstat -t | grep -e "^tcp" | grep -ve "CLOSE_WAIT[ \t]*$" | sed -re "s/ +/ /g" | cut -d " " -f 4 | grep -cE ":$PATTERN\b") -gt 0 ]; then
			REASON=${DESCRIPTION:-"$PATTERN"}
			break
		fi
		continue
		;;
	  smb)
		# samba locks or shares
		case "$TYPE" in
		  lock*)
			if [ $(smbstatus -L | wc -l) -gt 2 ]; then
				REASON=${DESCRIPTION:-"Samba locks"}
				break 2
			fi
			continue 2
			;;
		  share*)
			if [ $(smbstatus -S | wc -l) -gt 4 ]; then
				REASON=${DESCRIPTION:-"Samba shares"}
				break 2
			fi
			continue 2
			;;
		  *)
			if [ $(smbstatus -S | grep -cE "$PATTERN\b") -gt 0 ]; then
				REASON=${DESCRIPTION:-"$PATTERN"}
				break 2
			fi
			continue 2
			;;
		esac
		continue
		;;
	  afp)
		# Apple file sharing
		if [ $(ps ancx -o user,command | grep "afpd$" | sed -e "s/^ \+//g" | grep  -cve "^0") -gt 0 ]; then
			REASON=${DESCRIPTION:-"AppleShare"}
			break
		fi
		continue
		;;
	  sh)
		# shell scripts
		if [ "$(pidof -x $PATTERN)" ]; then
			REASON=${DESCRIPTION:-"$PATTERN"}
			break
		fi
		continue
		;;
	  oth*)
		# any other processes
		if [ $(ps ax | grep -v "grep" | grep -cE "$PATTERN\b") -gt 0 ]; then
			REASON=${DESCRIPTION:-"$PATTERN"}
			break
		fi
		continue
		;;
	  *)
		logger -t "$DESC" "unkown type '$TYPE'"
		continue
		;;
	esac
done
exec 0<&9 9<&-

# if there is a reason not to shutdown, tell VDR about it
if [ "$REASON" ]; then
	MESSAGE="$REASON"
	# add an explanation to syslog that includes the reason
#	logger -t "$DESC" "$MESSAGE"
	echo "ABORT_MESSAGE=\"$MESSAGE\""
        /usr/bin/vdr-dbus-send /Skin skin.QueueMessage string:"Shutdown inhibited by $MESSAGE"
	exit 1
fi

#Sync back system time to hardware time (Maybe VDR has changed it)
hwclock --systohc --utc

#Unset previous timer
echo '0' > /sys/class/rtc/rtc0/wakealarm

#Set new timer 5mins before recording starts
echo $(($1 - 300 )) > /sys/class/rtc/rtc0/wakealarm

#Initiate shutdown
/sbin/shutdown -h now
