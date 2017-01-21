#!/bin/bash
valid_governors=(
				powersave 
				ondemand 
				performance
				conservative
				userspace)
initd_file="cpu_gov"  #use name without sh for global use without sh out of /usr/bin
first_cmd_arg="$1"
second_cmd_arg="$2"
			
# testing if governor tests works and change of startup script				
function governor_changer {
    sudo echo $1 | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor > /dev/null 2>&1
    RESULT=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    if [ "$RESULT" == "$1" ]; then
	  local_fs='$local_fs'
	  network='$network'
	  named='$named'
	  time='$time'
	  syslog='$syslog'
	  echo -e "#!/bin/sh\n### BEGIN INIT INFO\n# Provides:          "$initd_file"\n# Required-Start:    $local_fs $network $named $time $syslog\n# Required-Stop:     $local_fs $network $named $time $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Description:       script to automatically set cpu governors and ondemand threshold to desired value at boot\n### END INIT INFO\n\nsudo echo $1 | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" | sudo tee /etc/init.d/cpu_gov.sh > /dev/null 2>&1
	  echo "Success: Set governor to $RESULT"
    else
      echo "Failed. You probably don't have sudo rights"
    fi
}

function governor_cmd {
if [[ "$first_cmd_arg" == "--governor" ]] || [[ "$first_cmd_arg" == "-g" ]]; then
	INPUT_GOVERNOR="$second_cmd_arg"
	for i in "${valid_governors[@]}"
	do
		if [ "$i" == "$INPUT_GOVERNOR" ]; then
			governor_changer "$INPUT_GOVERNOR"
			if [ "$INPUT_GOVERNOR" == "ondemand" ] || [ "$INPUT_GOVERNOR" == "conservative" ]; then
				echo 'Your custom threshold does not stay conserved when changing it. use gui or "-t" to change it to your desired value'
			fi
			exit
		fi
	done
	echo "$second_cmd_arg is not a valid governor"
	exit
fi 
}

function gui {
	OPTION=$(whiptail --title "CPU.gov" --menu "Choose standard cpu governor" 25 92 16 \
			"powersave" "locks the CPU frequency at the lowest frequency set by the user"\
			"ondemand" "gets clocked to max at about 90% load"\
			"performance" "locks the CPU at maximum frequency"\
			"conservative" "larger, more persistent load take place before CPU clockspeed will rise"\
			"userspace" "allows any program executed by the user to set the CPU's operating frequency"		3>&1 1>&2 2>&3)
	
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		governor_changer "$OPTION"
		if [ "$OPTION" == "ondemand" ] || [ "$OPTION" == "conservative" ]; then
			if (whiptail --title "Governor Threshold" --yes-button "Change Threshold" --no-button "No don't change"  --yesno "Would you like to change to threshold at which CPU clocks at max speed? (0-100)" 10 60) then		
				if [[ "$OPTION" == "conservative" ]];then
					threshold_input=$(whiptail --title "UP-Threshold Input" --inputbox "What is your desired threshold at which CPU clocks at max speed? (0-100)" 10 60 80 3>&1 1>&2 2>&3)
				else
					threshold_input=$(whiptail --title "UP-Threshold Input" --inputbox "What is your desired threshold at which CPU clocks at max speed? (0-100)" 10 60 95 3>&1 1>&2 2>&3)
				fi
				exitstatus=$?
				if [ $exitstatus = 0 ]; then
					echo "Your desired threshold is:" $threshold_input
					if [[ $threshold_input -le 100 ]] && [[ $threshold_input -gt 0 ]]; then
						change_up_threshold "$threshold_input"
					else
						echo "Not a valid threshold. Did not change"
					fi
				else
					echo "Ok did not change threshold."
				fi
				exit
			
			else 
				echo "Ok did not change threshold"
				exit
			fi
		fi
		exit
	else
		echo "You chose Cancel therefore failed"
	fi
}

function change_up_threshold {
	if [[ $1 -le 100 ]] && [[ $1 -ge 0 ]]; then
		governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
		if [[ "$governor" == "ondemand" ]] || [[ "$governor" == "conservative" ]]; then
			echo $1 | sudo tee /sys/devices/system/cpu/cpufreq/"$governor"/up_threshold > /dev/null 2>&1
			echo "echo $1| sudo tee /sys/devices/system/cpu/cpufreq/$governor/up_threshold" | sudo tee --append /etc/init.d/cpu_gov.sh > /dev/null 2>&1
		else
			echo "failed to chanage threshold. Not the correct governor."
		fi
	fi
}

function threshold_input_handler {
	if [ "$first_cmd_arg" == "-t" ] || [ "$first_cmd_arg" == "--treshold" ]; then
		governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
		if [[ "$governor" != "ondemand" ]] && [[ "$governor" != "conservative" ]]; then
			PS3='Which governor that supports thresholds should be activated: '
			options=("ondemand" "conservative" "Cancel")
			select opt in "${options[@]}"
			do
				case $opt in
					"ondemand")
						governor_changer "ondemand"
						break
						;;
					"conservative")
						governor_changer "conservative"
						break
						;;
					"Cancel")
						exit
						;;
					*) echo invalid option;;
				esac
			done
		fi
		if [[ $second_cmd_arg -le 100 ]] && [[ $second_cmd_arg -ge 0 ]]; then
			change_up_threshold "$second_cmd_arg"
		else
			echo "Not a valid threshold"
		fi
		echo "done changed governor to ondemand and threshold to $second_cmd_arg"
		exit
	fi
}

function help_command {
	if [ "$first_cmd_arg" == "-h" ] || [ "$first_cmd_arg" == "--help" ]; then
		echo "Usage:"
		echo ""
		echo "start with no arguments -> start with gui to choose governor" 
		echo "-d	--dialog		use pseudo gui dialogs"
		echo "-h	--help			display this help information"
		echo "-s	--show			display active governor and threshold of ondemand if active"
		echo "-g	--governor		give a valid cpu governor as argument two"
		echo "-t	--treshold		changes governor to ondemand and give a valid ondemand threshold as argument two"
		exit
	fi
}

function show_state {
if [ "$first_cmd_arg" == "-s" ] || [ "$first_cmd_arg" == "--show" ]; then
	RESULT=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
	echo "Current Governor: $RESULT" 
	CURRENT_FREQ=$(sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq)
	CURRENT_FREQ=$(expr "$CURRENT_FREQ" / 1000)
	echo "Current CPU freq: $CURRENT_FREQ mhz"
	if [[ "$RESULT" == "ondemand" ]] || [[ "$RESULT" == "conservative" ]];then
		RESULT_THRESHOLD=$(cat /sys/devices/system/cpu/cpufreq/$RESULT/up_threshold)
		echo "$RESULT threshold: $RESULT_THRESHOLD %"
	fi
	exit
fi
}

function dialog_handler {
	if [ "$first_cmd_arg" == "-d" ] || [ "$first_cmd_arg" == "--dialog" ]; then
		PS3='Which governor should be activated: '
		options=("powersave" "ondemand" "performance" "userspace" "conservative" "Cancel")
		select opt in "${options[@]}"
		do
			case $opt in
				"powersave")
					governor_changer "powersave"
					break
					;;
				"ondemand")
					governor_changer "ondemand"
					read -p "change CPU boost threshold (empty leaves default): " threshold
					threshold=${threshold:-95}
					if [[ $threshold != 95 ]]; then 
						change_up_threshold $threshold
					fi
					break
					;;
					
				"performance")
					governor_changer "performance"
					break
					;;
					
				"userspace")
					governor_changer "userspace"
					break
					;;
					
				"conservative")
					governor_changer "conservative"
					read -p "change CPU boost threshold (empty leaves default): " threshold
					threshold=${threshold:-80}
					if [[ $threshold != 80 ]]; then 
						change_up_threshold $threshold
					fi		
					break
					;;
					
				"Cancel")
					exit
					;;
				*) echo invalid option;;
			esac
		done
		exit
	fi
}

show_state
help_command
governor_cmd
threshold_input_handler
dialog_handler
echo "No valid command line argument given. starting gui"
gui
