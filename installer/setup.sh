#!/bin/bash
FILENAME="cpu.gov"


if [[ $(cat /etc/init.d/cpu_gov.sh  3>&1 1>&2 2>&3) == *"No such file or directory"* ]]; then
	touch /etc/init.d/cpu_gov.sh
	echo -e "#!/bin/sh\n### BEGIN INIT INFO\n# Provides:          "$FILENAME"\n# Required-Start:    $local_fs $network $named $time $syslog\n# Required-Stop:     $local_fs $network $named $time $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Description:       script to automatically set cpu governors and ondemand threshold to desired value at boot\n### END INIT INFO " > /dev/null 2>&1
	chmod +x /etc/init.d/cpu_gov.sh
	../"$FILENAME"
	insserv -d "$FILENAME"
	update-rc.d cpu_gov.sh defaults
fi
cp ./cpu.gov.sh /usr/local/bin/cpu.gov
sudo chmod 755 /usr/local/bin/cpu.gov
sudo chmod +x /usr/local/bin/cpu.gov
