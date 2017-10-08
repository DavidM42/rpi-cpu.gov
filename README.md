# rpi-cpu.gov
After you've installed this script with it's convenient one line install method you are able to change the raspberry pi cpu governor. This change will be applied at every boot so you only have to change it one time. 

## Install

one line install command

```shell
wget https://raw.githubusercontent.com/DavidM42/rpi-cpu.gov/master/install.sh && sudo chmod +x ./install.sh && sudo ./install.sh --nochown && sudo rm install.sh
```
## Usage
starting it without arguments (```cpu.gov```) will start a gui similar to ```raspi-config``` to choose the governor  
### Command line arguments  

short long          effect  
`-d`	`--dialog`		use pseudo gui dialog  
`-h`	`--help`			display this help information  
`-s`	`--show`			display active governor and threshold of ondemand if active  
`-g`	`--governor`	give a valid cpu governor as second argument  
`-t`	`--treshold`	changes governor to ondemand and give a valid ondemand threshold as argument two  
`-u`	`--uninstall` removes cpu.gov from system (all changes back to kernel standard after reboot)  

so use it like this ```cpu.gov -g ondemand```  
