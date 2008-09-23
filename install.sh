#!/usr/bin/env bash

# Attack 0.2 - A threaded (D)DoS-Deflate alternative written in Ruby
# Copyright (C) 2008 JR
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


black='\E[30;47m'
red='\E[31;47m'
blue='\E[34;47m'


cecho () { 
	message=${1:-$default_msg}   
	color=${2:-$black}           
  echo "$color"
  echo "$message"
	tput sgr0
  return
}  

intro () {
	cecho "Welcome to the WarezScene Attack Installation." $red
	cecho "
Attack 0.2 - A threaded (D)DoS-Deflate alternative written in Ruby
Copyright (C) 2008 JR

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
" $blue
	cecho "CTRL + C to cancel installation.\n"
	return
}

which_firewall() {
	echo "Which firewall would you like Attack to use? [apf / csf]"
	read firewall
	return
}

set_firewall() {
	if [[ ! $1 = "" ]]; then
		firewall=$1
		echo "Firewall set: $firewall"
		echo "firewall = \"$firewall\" " > attack.conf
	else
		cecho "FIREWALL NOT SET. Continuing with installation anyway..." $red
		touch attack.conf
	fi
}

which_frequency() {
	echo "\nHow often do you want Attack to check the current connections? (in seconds) [30]"
	read frequency
	return
}

set_frequency() {
	if [[ $(echo "$1" | grep -E "^[0-9]+$") ]]; then
		echo "Frequency set: $frequency"
		echo "frequency = $frequency" >> attack.conf
	else
		echo "frequency = 30" >> attack.conf
	fi
}

get_install_path() {
	echo "\nWhere would you like to install Attack? [/opt/local/attack/]"
	read install_path	
	
	if [[ $install_path == "" ]]; then
		install_path="/opt/local/attack/"
	fi
	
	return
}

move_and_create_files() {

	mkdir -p $install_path
	cp ./README $install_path
	cp ./attack.rb $install_path
	cp ./LICENSE $install_path
	cp ./README $install_path
	cp ./attack.conf $install_path
	cp ./TODO $install_path
	cp ./CHANGELOG $install_path
	cp ./INSTALL $install_path
	
	cecho "Attack has been installed in $install_path. Start Attack now? [Y/N]" $red
	
	read start
	if [[ $start = "Y" ]]; then
		ruby "$install_path"attack.rb
	else
		echo "Installation Complete!"
	fi
}

intro

which_firewall
set_firewall $firewall

which_frequency
set_frequency $frequency

get_install_path
move_and_create_files