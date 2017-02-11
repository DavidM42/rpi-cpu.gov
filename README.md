# rpi-cpu.gov
Bash script to conveniently change raspberry pi governor at every boot

## Install

one line install command

```shell
wget https://raw.githubusercontent.com/DavidM42/rpi-cpu.gov/master/install.sh && sudo chmod +x ./install.sh && sudo ./install.sh --nochown && sudo rm install.sh && sudo chmod 755 /usr/local/bin/cpu.gov && sudo chmod +x /usr/local/bin/cpu.gov
```
