#!/bin/bash
#############################################################
# MTA:SA Linux server installation and management script	#
#															#
# Developed by Pablo PHG <contact@pablophg.net>				#
#															#
# Use at your own risk										#
#############################################################

# Util spinner
# Spinner by Tasos Latsas <tlatsas@kodama.gr>
function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=0.15

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

# MTA installation/management script starts here
function mta_install {
	# Update
	start_spinner 'Updating repositories...'
    apt-get update &> /dev/null
	stop_spinner $?

	# Upgrade
	start_spinner 'Upgrading packages...'
    apt-get -y upgrade &> /dev/null
	stop_spinner $?
	
	# Install required packages for MTA
	if [ $(uname -m) == 'x86_64' ]; then
		# 64-bit stuff here
		start_spinner 'Adding i386 architecture...'
		dpkg --add-architecture i386 &> /dev/null
		stop_spinner $?
		
		start_spinner 'Updating repositories...'
		apt-get update &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing zip...'
		apt-get -y install zip &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing unzip...'
		apt-get -y install unzip &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing ia32-libs...'
		apt-get -y install ia32-libs &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing lib32ncursesw5...'
		apt-get -y install lib32ncursesw5 &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing lib32readline5...'
		apt-get -y install lib32readline5 &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing screen...'
		apt-get -y install screen &> /dev/null
		stop_spinner $?
	else
		# 32-bit stuff here
		start_spinner 'Installing zip...'
		apt-get -y install zip &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing unzip...'
		apt-get -y install unzip &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing libreadline5...'
		apt-get -y install libreadline5 &> /dev/null
		stop_spinner $?
		
		start_spinner 'Installing screen...'
		apt-get -y install screen &> /dev/null
		stop_spinner $?
	fi
	
	# Download MTA source files and unpack them
	start_spinner 'Downloading server files...'
	wget -O mtasa-linux-server.tar.gz http://linux.mtasa.com/dl/140/multitheftauto_linux-1.4.0.tar.gz &> /dev/null
	stop_spinner $?
	
	start_spinner 'Downloading baseconfig...'
	wget -O baseconfig.tar.gz http://linux.mtasa.com/dl/140/baseconfig-1.4.0.tar.gz &> /dev/null
	stop_spinner $?
	
	start_spinner 'Downloading resources...'
	wget -O mtasa-resources.zip http://mirror.mtasa.com/mtasa/resources/mtasa-resources-r1017.zip &> /dev/null
	stop_spinner $?
	
	start_spinner 'Unpacking server files...'
	tar -zxf mtasa-linux-server.tar.gz &> /dev/null
	mv multitheftauto_linux-1.4.0/* .
	stop_spinner $?
	
	start_spinner 'Unpacking resources...'
	unzip -q mtasa-resources.zip -d mods/deathmatch/resources/ &> /dev/null
	stop_spinner $?
	
	start_spinner 'Unpacking baseconfig...'
	tar -zxf baseconfig.tar.gz
	mv baseconfig/* mods/deathmatch
	stop_spinner $?
	
	start_spinner 'Removing files...'
	rmdir baseconfig multitheftauto_linux-1.4.0
	rm baseconfig.tar.gz mtasa-resources.zip mtasa-linux-server.tar.gz
	stop_spinner $?
	
	echo 'Will now configure the server, simply press enter to use default values'
	# Only basic configurations are showed
	while true; do
		read -p "Server name: " servername
		if [ -n "$servername" ]; then
			sed -i "s|\(<servername>\)[^<>]*\(</servername>\)|\1${servername}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	while true; do
		read -p "Server IP: " serverip
		if [ -n "$serverip" ]; then
			sed -i "s|\(<serverip>\)[^<>]*\(</serverip>\)|\1${serverip}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	while true; do
		read -p "UDP port: " serverport
		if [ -n "$serverport" ]; then
			sed -i "s|\(<serverport>\)[^<>]*\(</serverport>\)|\1${serverport}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	while true; do
		read -p "Maximum players: " maxplayers
		if [ -n "$maxplayers" ]; then
			sed -i "s|\(<maxplayers>\)[^<>]*\(</maxplayers>\)|\1${maxplayers}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	while true; do
		read -p "HTTP server enabled [0 - 1]: " httpserver
		if [ -n "$httpserver" ]; then
			sed -i "s|\(<httpserver>\)[^<>]*\(</httpserver>\)|\1${httpserver}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	while true; do
		read -p "TCP port: " httpport
		if [ -n "$httpport" ]; then
			sed -i "s|\(<httpport>\)[^<>]*\(</httpport>\)|\1${httpport}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	while true; do
		read -p "External download URL: " httpdownloadurl
		if [ -n "$httpdownloadurl" ]; then
			sed -i "s|\(<httpdownloadurl>\)[^<>]*\(</httpdownloadurl>\)|\1${httpdownloadurl}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	while true; do
		read -p "Server password: " password
		if [ -n "$password" ]; then
			sed -i "s|\(<password>\)[^<>]*\(</password>\)|\1${password}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	while true; do
		read -p "FPS limit: " fpslimit
		if [ -n "$fpslimit" ]; then
			sed -i "s|\(<fpslimit>\)[^<>]*\(</fpslimit>\)|\1${fpslimit}\2|" mods/deathmatch/mtaserver.conf
		fi
		break;
	done
	
	echo 'Server configuration complete!'
	
	start_spinner 'Starting server...'
	usedserverport=$(grep -oPm1 "(?<=<serverport>)[^<]+" <<< "$(<mods/deathmatch/mtaserver.conf)")
	sessionname="mtasa$usedserverport"
	screen -wipe &> /dev/null
	screen -dmS $sessionname ./mta-server
	stop_spinner $?
	
	exit;
}


# Init
echo "******************************************************"
echo "MTA:SA Linux server installation and management script"
echo ""
echo "Developed by Pablo PHG <contact@pablophg.net>"
echo "******************************************************"
echo "USE AT YOUR OWN RISK"
echo ""
if [ ! -f mta-server ]; then
	while true; do
		read -p "No server detected. The script will create a new MTA server on current dir. Proceed? [Y/n]" yn
		case $yn in
			[Yy]* ) mta_install; break;;
			[Nn]* ) exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done
else
	# A server is installed, check if running
	
	usedserverport=$(grep -oPm1 "(?<=<serverport>)[^<]+" <<< "$(<mods/deathmatch/mtaserver.conf)")
	
	sessionname="mtasa$usedserverport"

	screen -wipe &> /dev/null
	
	if screen -list | grep -q $sessionname; then
		# Server is running
		screenpid=$(screen -list | grep "$sessionname" | cut -f1 -d'.' | sed 's/\W//g')
		while true; do
			read -p "The server is running. Should we STOP it? [Y/n]" yn
			case $yn in
				[Yy]* ) kill -9 $screenpid; screen -wipe &> /dev/null; echo "Server stopped"; break;;
				[Nn]* ) exit;;
				* ) echo "Please answer yes or no.";;
			esac
		done
	else
		# Server is not running
		while true; do
			read -p "The server is stopped. Should we START it? [Y/n]" yn
			case $yn in
				[Yy]* ) screen -dmS $sessionname ./mta-server; echo "Server started"; break;;
				[Nn]* ) exit;;
				* ) echo "Please answer yes or no.";;
			esac
		done
	fi
fi