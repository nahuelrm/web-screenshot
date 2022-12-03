#!/bin/bash

# Dependencies: 
# - gowitness (https://github.com/sensepost/gowitness)

#Colors
green="\e[0;32m\033[1m"
endColor="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
cyan="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

help_panel() {
	echo -e "${gray}command line web screenshot tool and information gathering${endColor}"
	echo -e "${cyan}Usage:${gray} web-screenshot [options] ${endColor}"
	echo -e "\n${gray}Options:${endColor}"
	echo -e "\t${yellow}-f <file>${gray}\tperform web screeshots for domains in file${endColor}"
	echo -e "\n\t${yellow}-d <domain>${gray}\tperform web screeshots for single domain${endColor}"
	echo -e "\n\t${yellow}-P <path>${gray}\tpath to directory to save screenshots${endColor}"
	echo -e "\n\t${yellow}-r${gray}\t\tmake report in markdown format${endColor}"
	echo -e "\n\t${yellow}-H${gray}\t\tsave reponse headers${endColor}"
	echo -e "\n\t${yellow}-t${gray}\t\tsave web technologies details${endColor}"
	echo -e "\n\t${yellow}-l${gray}\t\tsave gowitness log${endColor}"
	echo -e "\n\t${yellow}-s${gray}\t\tsilent output${endColor}"
	echo -e "\n\t${yellow}-c${gray}\t\tfilter every response status-code while taking screenshots${endColor}"
	exit
}

format_url() {
	echo $1 | sed 's|https-|https://|' | sed 's|http-|http://|' | sed 's/.png//'
}

# Main

if [[ $# == 0 ]]; then help_panel; fi

optstring="f:d:P:cHtsrl"
domain_option=0; report=false; headers=false; technologies=false; single=false; file=false; silent=false; log=false; status_codes=false; screenshots_path="screenshots";

while getopts $optstring opt 2>/dev/null; do
	case $opt in
		"H") headers=true ;;
		"t") technologies=true ;;
		"s") silent=true ;;
		"c") status_codes=true ;;
		"P") screenshots_path=$OPTARG ;;
		"d") single=true; domain=$OPTARG; let domain_option+=1 ;;
		"r") report=true ;;
		"l") log=true ;;
		"f")
			file=true; 
			dpath=$OPTARG
			if ! [[ -f $dpath ]]; then
				echo -e "${red}[!] File provided does't exist.${endColor}"
				exit 1
			fi
			let domain_option+=1
			;;
		*) help_panel ;;
	esac
done

if [[ $domain_option -gt 1 ]]; then help_panel; fi

mkdir data 2>/dev/null

if $file; then
	if $silent; then
		gowitness file -f $dpath -P $screenshots_path -D /tmp/gowitness.sqlite3 2>&1 | tee data/log &>/dev/null 
	else
		gowitness file -f $dpath -P $screenshots_path -D /tmp/gowitness.sqlite3 2>&1 | tee data/log
	fi
fi

if $single; then
	if $silent; then
		gowitness single $domain -P $screenshots_path -D /tmp/gowitness.sqlite3 2>&1 | tee data/log &>/dev/null
	else
		gowitness single $domain -P $screenshots_path 2>&1 -D /tmp/gowitness.sqlite3 | tee data/log
	fi
fi

if $headers; then
	sqlite3 /tmp/gowitness.sqlite3 "select * from headers;" | rev | awk -F "|" '{print $1 " :" $2 " | " $3 " |"}' | rev > data/headers
fi

if $technologies; then
	sqlite3 /tmp/gowitness.sqlite3 "select * from technologies;" | rev | awk -F "|" '{print $1, $2}' | rev > data/technologies
fi

if $status_codes; then
	mkdir data/status_codes
	for code in $(cat data/log | grep "statuscode" | awk '{print $8}' | sed 's/.*=//' | sort -u); do
		grep -F "$code" data/log | rev | awk '{print $1}' | rev | sed 's/url=//' > data/status_codes/$(echo $code | sed 's/.*m//')_statuscodes
	done
fi

if $report; then
	echo "# Web Screeshots Report" >> web-screenshots-report.md 
	echo "" >> web-screenshots-report.md
	echo "### $(date)" >> web-screenshots-report.md

	i=0; for image in $(ls $screenshots_path); do
		echo "" >> web-screenshots-report.md
		echo "$(format_url $image)" >> web-screenshots-report.md
		let i+=1; echo "![screenshot$i](./$screenshots_path/$image)" >> web-screenshots-report.md
	done
fi

if ! $log; then
	rm data/log 2>/dev/null
	find data -maxdepth 0 -empty -exec bash -c "rm -fr data 2>/dev/null" \;
fi

rm /tmp/gowitness.sqlite3 2>/dev/null
