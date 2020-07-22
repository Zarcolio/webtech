#!/bin/bash

if [[ $1 ]]
then
	echo "[91m"
	echo "====================="
	echo "{◕ ◡ ◕} Detecting"
	echo "====================="
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
	nmap -A $1 -p 80,81,82,8008,8080,443,1443,2443,3443,4443,5443,6443,7443,8443,9443 -oN nmap-$1.log|tee webtech-tmp-$1.log
	cat nmap-$1.log|grep "  http "|cut -d/ -f1>$1-http-tmp.log
	cat nmap-$1.log|grep "  ssl/https "|cut -d/ -f1>$1-https-tmp.log

	echo "[91m"
	echo "====================="
	echo "{◕ ◡ ◕} Using WhatWeb"
	echo "====================="
	echo "[00m"
	while IFS=, read -r webport; do
		whatweb -a 3 http://$1:$webport|sed -e 's/],/]\n/g'|tee -a webtech-tmp-$1.log
	done < $1-http-tmp.log
	echo
	while IFS=, read -r webport; do
		whatweb -a 3 https://$1:$webport|sed -e 's/],/]\n/g'|tee -a webtech-tmp-$1.log
	done < $1-https-tmp.log
	
	echo "[91m"
	echo "========================"
	echo "{◕ ◡ ◕} Using Wappalyzer"
	echo "========================"
	echo "[00m"
	while IFS=, read -r webport; do
		wappalyzer http://$1:$webport|wappaligner|tee -a webtech-tmp-$1.log
	done < $1-http-tmp.log
	echo
	while IFS=, read -r webport; do
		wappalyzer https://$1:$webport|wappaligner|tee -a webtech-tmp-$1.log
	done < $1-https-tmp.log

	echo "[91m"
	echo "====================="
	echo "{◕ ◡ ◕} Using WAFW00F"
	echo "=====================[92m"
	while IFS=, read -r webport; do
		wafw00f http://$1:$webport|tee -a webtech-tmp-$1.log
	done < $1-http-tmp.log
	while IFS=, read -r webport; do
		wafw00f https://$1:$webport|tee -a webtech-tmp-$1.log
	done < $1-https-tmp.log
	
	echo "[91m"
	echo "====================="
	echo "{◕ ◡ ◕} Using WhatWaf"
	echo "=====================[92m"
	while IFS=, read -r webport; do
		echo "Scanning http://$1:$webport"
		whatwaf --hide --skip -u http://$1:$webport|tee -a webtech-tmp-$1.log
	done < $1-http-tmp.log
	echo
	while IFS=, read -r webport; do
		echo "Scan https://$1:$webport"
		whatwaf --hide --skip -u https://$1:$webport|tee -a webtech-tmp-$1.log
	done < $1-https-tmp.log
	
	echo "[91m"
	echo "===================="
	echo "{◕ ◡ ◕} Using CMSeeK"
	echo "====================[92m"
	while IFS=, read -r webport; do
		cmseek --no-redirect --batch -u http://$1:$webport|tee -a webtech-tmp-$1.log
	done < $1-http-tmp.log
	echo
	while IFS=, read -r webport; do
		cmseek --no-redirect --batch -u https://$1:$webport|tee -a webtech-tmp-$1.log
	done < $1-https-tmp.log

	# Clean-up colors in result:
	cat webtech-tmp-$1.log|sed 's/\x1B\[[0-9;]*[JKmsuH]//g'>webtech-$1.log

	# Clean-up tmp files:
	rm -f $1-http-tmp.log
	rm -f $1-https-tmp.log
	rm -f nmap-$1.log
	
fi
