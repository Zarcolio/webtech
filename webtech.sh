#!/bin/bash


for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            ports)              ports=${VALUE} ;;
            host)               host=${VALUE} ;;
            *)   
    esac    
done


if [[ -z $ports ]]
then
	ports="80,81,82,8008,8080,443,1443,2443,3443,4443,5443,6443,7443,8443,9443"
fi

if [[ $host ]]
then
	echo "[91m"
	echo "================="
	echo "{◕ ◡ ◕} Detecting"
	echo "================="
	echo "[00m"

	echo "|\     /|(  ____ \(  ___ \\\\__   __/(  ____ \(  ____ \|\     /|"
	echo "| )   ( || (    \/| (   ) )  ) (   | (    \/| (    \/| )   ( |"
	echo "| | _ | || (__    | (__/ /   | |   | (__    | |      | (___) |"
	echo "| |( )| ||  __)   |  __ (    | |   |  __)   | |      |  ___  |"
	echo "| || || || (      | (  \ \   | |   | (      | |      | (   ) |"
	echo "| () () || (____/\| )___) )  | |   | (____/\| (____/\| )   ( |"
	echo "(_______)(_______/|/ \___/   )_(   (_______/(_______/|/     \|"
                                                              
	echo "[91m"
	echo "=================="
	echo "{◕ ◡ ◕} Using Nmap"
	echo "=================="
	echo "[00m"
	nmap --open -PN -A $host -p $ports -oN nmap-$host.log|tee webtech-tmp-$host.log
	cat nmap-$host.log|grep "\/tcp "|grep "  http"|cut -d/ -f1>$host-http-tmp.log
	cat nmap-$host.log|grep "\/tcp "|grep "  ssl/http"|cut -d/ -f1>$host-https-tmp.log

	echo "[91m"
	echo "====================="
	echo "{◕ ◡ ◕} Using WhatWeb"
	echo "====================="
	echo "[00m"
	while IFS=, read -r webport; do
		whatweb -a 3 http://$host:$webport|sed -e 's/],/]\n/g'|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	echo
	while IFS=, read -r webport; do
		whatweb -a 3 https://$host:$webport|sed -e 's/],/]\n/g'|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log
	
	echo "[91m"
	echo "========================"
	echo "{◕ ◡ ◕} Using Wappalyzer"
	echo "========================"
	echo "[00m"
	while IFS=, read -r webport; do
		wappalyzer http://$host:$webport|wappaligner|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	echo
	while IFS=, read -r webport; do
		wappalyzer https://$host:$webport|wappaligner|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log

	echo "[91m"
	echo "====================="
	echo "{◕ ◡ ◕} Using WAFW00F"
	echo "=====================[92m"
	while IFS=, read -r webport; do
		wafw00f http://$host:$webport|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	while IFS=, read -r webport; do
		wafw00f https://$host:$webport|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log
	
	echo "[91m"
	echo "====================="
	echo "{◕ ◡ ◕} Using WhatWaf"
	echo "=====================[92m"
	while IFS=, read -r webport; do
		echo "Scanning http://$host:$webport"
		whatwaf --hide --skip -u http://$host:$webport|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	echo
	while IFS=, read -r webport; do
		echo "Scan https://$host:$webport"
		whatwaf --hide --skip -u https://$host:$webport|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log
	
	echo "[91m"
	echo "===================="
	echo "{◕ ◡ ◕} Using CMSeeK"
	echo "====================[92m"
	while IFS=, read -r webport; do
		cmseek --no-redirect --batch -u http://$host:$webport|sed 's/\x1B\[[0-9;]*[JH]//g'|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	echo
	while IFS=, read -r webport; do
		cmseek --no-redirect --batch -u https://$host:$webport|sed 's/\x1B\[[0-9;]*[JH]//g'|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log

	# Clean-up colors in result:
	cat webtech-tmp-$host.log|sed 's/\x1B\[[0-9;]*[JKmsuH]//g'>webtech-$host.log

	# Clean-up tmp files:
	rm -f $host-http-tmp.log
	rm -f $host-https-tmp.log
	rm -f nmap-$host.log
	rm -f webtech-tmp-$host.log

	echo
	echo "[91m"
	echo "{◕ ◡ ◕} Created \"webtech-$host.log\" for reviewing {◕ ◡ ◕}"
	echo ""
else
	echo "Detect which web technologies are used for a given host."
	echo "Services using HTTP/HTTPS are detected with Nmap and scanned with"
	echo "WhatWeb, Wappalyzer+Wappaligner, WATW00F, WhatWhaf and CMSeeK."
	echo 
	echo "usage: webtech.sh [ports={portlist}] host={host}"
	echo
	echo "Required arguments:"
	echo "   host		Supply a host name to detect its technologies."
	echo 
	echo "Optional arguments:"
	echo "   ports		Supply a list of ports separated by commas."
	echo "			If no list op ports is given, the following ports are scanned with Nmap:"
	echo " 			80,81,82,8008,8080,443,1443,2443,3443,4443,5443,6443,7443,8443,9443"
fi
