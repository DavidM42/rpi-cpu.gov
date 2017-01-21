#!/bin/bash

echo "Version number:"
read version

makeself --notemp ../ ../install.sh "rpi-cpu.gov $version" ./installer/setup.sh
