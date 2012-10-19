SAB ()
{
	echo "$(date) Refreshing Sabnzbd"
	/etc/init.d/sabnzbdplus $1
	wait ${!}
	if [ `/etc/init.d/sabnzbdplus status | grep "running" | wc -l ` -lt 1 ]; then
		echo "Sabnzbd $1 failed.  Retrying $1 1 time."
		etc/init.d/sabnzbdplus restart
		wait ${!}
		if [ `/etc/init.d/sabnzbdplus status | grep "running | wc -l ` -lt 1 ]; then
			echo "$(date) Sabnzbd failed 2 restarts"
			return 1
		fi
	else
		echo "$(date) SABNZBD $1 successfull!"
		return 0
	fi
}
SICKBEARD ()
{
	echo "$(date) Refreshing Sickbeard"
	/etc/init.d/sickbeard $1	
	wait ${!}
	if [ `ps aux 2>/dev/null | grep SickBeard.py | grep /usr/bin/python | wc -l` -eq 0 ] && echo "Sickbeard $1 failed.  Retrying restart 1 time."; then
		/etc/init.d/sickbeard $1
		wait ${!}
		if [ `ps aux 2>/dev/null | grep SickBeard.py | grep /usr/bin/python | wc -l` -eq 0 ]; then
			echo "$(date) Sickbeard failed 2 ${1}s"
			return 1
		fi
	else
		echo "$(date) Sickbeard ${1} successfull!"
		return 0
	fi
}
COUCHPOTATO ()
{
	echo "$(date) Refreshing CouchPotato"
	/etc/init.d/couchpotato $1
	wait ${!}
	if [ `ps aux 2>/dev/null | grep CouchPotato.py | grep /usr/bin/python | wc -l`  -eq 0 ] && echo "Couchpotato $1 failed.  Retrying $1 1 time."; then
		/etc/init.d/couchpotato $1
		wait ${!}
		if [ `ps aux 2>/dev/null | grep CouchPotato.py | grep /usr/bin/python | wc -l` -ne 0 ]; then
			echo "$(date) Couchpotato failed 2 ${1}s"
			return 1
		fi
	else
		echo  "$(date) Couchpotato ${1} successful!"
		return 0
	fi
}

startall ()
{
	DSTATUS=0
	SAB restart
	let DSTATUS+=$?
	COUCHPOTATO restart
	let DSTATUS+=$?
	if [ -e /etc/init.d/yourservice.d/Sick-Beard/sickbeard.pid ]; then
		SICKBEARD restart
	else
		SICKBEARD start
	fi
	let DSTATUS+=$?
	
	if [ $DSTATUS -ne 0 ]; then
		echo $date " Not everything started correctly."
		return 1
	else
		echo $date " All Downloaders Initiated"
		return 0
	fi
	exit
}
stop ()
{
	SICKBEARD stop
	wait ${!}
	COUCHPOTATO stop
	wait ${!}
	SAB stop
}
case "$1" in
	start) startall;;
	stop) stop;;
esac
