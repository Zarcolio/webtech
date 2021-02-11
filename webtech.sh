#!/bin/bash

# == You can configure these options: ==
nmapoptions=""
# ======================================


parser() {
    # Define default values
    ports=${ports:-"medium"}
    host=${host:-""}


    # Assign the values given by the user
    while [ $# -gt 0 ]; do
        if [[ $1 == *"-"* ]]; then
            param="${1/-/}"
            declare -g $param="$2"
        fi
        shift
    done

}

parser $@

paramports=$ports


small="80,443"
medium="80,443,8000,8080,8443"
large="80,81,443,591,2082,2087,2095,2096,3000,8000,8001,8008,8080,8083,8443,8834,8888"
xlarge="80,81,300,443,591,593,832,981,1010,1311,2082,2087,2095,2096,2480,3000,3128,3333,4243,4567,4711,4712,4993,5000,5104,5108,5800,6543,7000,7396,7474,8000,8001,8008,8014,8042,8069,8080,8081,8088,8090,8091,8118,8123,8172,8222,8243,8280,8281,8333,8443,8500,8834,8880,8888,8983,9000,9043,9060,9080,9090,9091,9200,9443,9800,9981,12443,16080,18091,18092,20720,28017"



if [[ -z $paramports ]]
then
	ports=$medium
else
	if [[ $paramports -eq "small" ]] || [[ $paramports -eq "medium" ]] || [[ $paramports -eq "large" ]] || [[ $paramports -eq "xlarge" ]]
	then
		ports=${!paramports}
	else
		ports=$paramports
	fi
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
	echo "=================="|tee -a webtech-tmp-$host.log
	echo "{◕ ◡ ◕} Using Nmap"|tee -a webtech-tmp-$host.log
	echo "=================="|tee -a webtech-tmp-$host.log
	echo "[00m"
	echo >>webtech-tmp-$host.log
	nmap $nmapoptions --open -PN -sV $host -p $ports -oN nmap-$host.log|tee webtech-tmp-$host.log
	cat nmap-$host.log|grep "\/tcp "|grep "  http"|cut -d/ -f1>$host-http-tmp.log
	cat nmap-$host.log|grep "\/tcp "|grep "  ssl/http"|cut -d/ -f1>$host-https-tmp.log

	echo >>webtech-tmp-$host.log
	echo "[91m"
	echo "====================="|tee -a webtech-tmp-$host.log
	echo "{◕ ◡ ◕} Using WhatWeb"|tee -a webtech-tmp-$host.log
	echo "====================="|tee -a webtech-tmp-$host.log
	echo "[00m"
	echo  >>webtech-tmp-$host.log
	while IFS=, read -r webport; do
		whatweb -a 3 http://$host:$webport|sed -e 's/],/]\n/g'|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	echo
	while IFS=, read -r webport; do
		whatweb -a 3 https://$host:$webport|sed -e 's/],/]\n/g'|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log
	
	echo >>webtech-tmp-$host.log
	echo "[91m"
	echo "========================"|tee -a webtech-tmp-$host.log
	echo "{◕ ◡ ◕} Using Wappalyzer"|tee -a webtech-tmp-$host.log
	echo "========================"|tee -a webtech-tmp-$host.log
	echo "[00m"
	echo >>webtech-tmp-$host.log
	while IFS=, read -r webport; do
		wappalyzer http://$host:$webport|wappaligner|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	echo
	while IFS=, read -r webport; do
		wappalyzer https://$host:$webport|wappaligner|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log

	echo >>webtech-tmp-$host.log
	echo "[91m"
	echo "====================="|tee -a webtech-tmp-$host.log
	echo "{◕ ◡ ◕} Using WAFW00F"|tee -a webtech-tmp-$host.log
	echo "====================="|tee -a webtech-tmp-$host.log
	echo "[92m"
	while IFS=, read -r webport; do
		wafw00f http://$host:$webport|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	while IFS=, read -r webport; do
		wafw00f https://$host:$webport|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log
	
	echo >>webtech-tmp-$host.log
	echo "[91m"
	echo "====================="|tee -a webtech-tmp-$host.log
	echo "{◕ ◡ ◕} Using WhatWaf"|tee -a webtech-tmp-$host.log
	echo "====================="|tee -a webtech-tmp-$host.log
	echo "[92m"
	echo >>webtech-tmp-$host.log
	while IFS=, read -r webport; do
		whatwaf --hide --skip --ra -u http://$host:$webport|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	echo
	while IFS=, read -r webport; do
		whatwaf --hide --skip --ra -u https://$host:$webport|tee -a webtech-tmp-$host.log
	done < $host-https-tmp.log
	
	echo >>webtech-tmp-$host.log
	echo "[91m"
	echo "===================="|tee -a webtech-tmp-$host.log
	echo "{◕ ◡ ◕} Using CMSeeK"|tee -a webtech-tmp-$host.log
	echo "===================="|tee -a webtech-tmp-$host.log
	echo "[92m"
	echo >>webtech-tmp-$host.log
	while IFS=, read -r webport; do
		cmseek --no-redirect --batch --light-scan -u http://$host:$webport|sed 's/\x1B\[[0-9;]*[JH]//g'|tee -a webtech-tmp-$host.log
	done < $host-http-tmp.log
	echo
	while IFS=, read -r webport; do
		cmseek --no-redirect --batch --light-scan -u https://$host:$webport|sed 's/\x1B\[[0-9;]*[JH]//g'|tee -a webtech-tmp-$host.log
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
	echo "usage: webtech.sh {host} [{portlist}]"
	echo
	echo "Required arguments:"
	echo "   host		Supply a host name to detect its technologies."
	echo 
	echo "Optional arguments:"
	echo "   ports		Supply a list of ports separated by commas, or 'small', 'medium', 'large' or 'xlarge'."
	echo " 			This script  defaults to 'medium'. These are the same ranges and default as Aquatone uses." 
	echo "			These are the port ranges used:"
	echo " 			small:  80, 443"
	echo " 			medium: 80, 443, 8000, 8080, 8443"
	echo " 			large:  80, 81, 443, 591, 2082, 2087, 2095, 2096, 3000, 8000, 8001, 8008, 8080, 8083, 8443, 8834, 8888"
	echo " 			xlarge: 80, 81, 300, 443, 591, 593, 832, 981, 1010, 1311, 2082, 2087, 2095, 2096, 2480, 3000, 3128, 3333,"
	echo "				4243, 4567, 4711, 4712, 4993, 5000, 5104, 5108, 5800, 6543, 7000, 7396, 7474, 8000, 8001, 8008,"
	echo "				8014, 8042, 8069, 8080, 8081, 8088, 8090, 8091, 8118, 8123, 8172, 8222, 8243, 8280, 8281, 8333,"
	echo "				8443, 8500, 8834, 8880, 8888, 8983, 9000, 9043, 9060, 9080, 9090, 9091, 9200, 9443, 9800, 9981,"
	echo "				12443, 16080, 18091, 18092, 20720, 28017"
	echo ""
	echo "If you want to tune the Nmap options, you can add them in the variable called \$nmapoptions."
	echo ""

fi
