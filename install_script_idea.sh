#!/bin/bash
FILENAME="gui.chooser"  #use name without sh for global use without sh out of /usr/bin


if [[ $(cat /etc/init.d/cpu_gov.sh  3>&1 1>&2 2>&3) == *"No such file or directory"* ]]; then
	sudo touch /etc/init.d/cpu_gov.sh
	echo -e "#!/bin/sh\n### BEGIN INIT INFO\n# Provides:          "$FILENAME"\n# Required-Start:    $local_fs $network $named $time $syslog\n# Required-Stop:     $local_fs $network $named $time $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Description:       script to automatically set cpu governors and ondemand threshold to desired value at boot\n### END INIT INFO " > /dev/null 2>&1
	sudo chmod +x /etc/init.d/cpu_gov.sh
	sudo ./"$FILENAME"
	sudo insserv -d "$FILENAME"
	sudo update-rc.d cpu_gov.sh defaults
	#sudo cp ./"$FILENAME" /usr/bin/"$FILENAME" #or other install method
fi