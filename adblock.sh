#!/bin/bash
# You are NOT allowed to change the files' names!
domainNames="domainNames.txt"
IPAddresses="IPAddresses.txt"
adblockRules="adblockRules"

function adBlock() {
    if [ "$EUID" -ne 0 ];then
        printf "Please run as root.\n"
        exit 1
    fi
    if [ "$1" = "-domains"  ]; then
        # Configure adblock rules based on the domain names of $domainNames file.
        # ...
        cat $domainNames | while read line; do
        # 1) find IP of DNS
            iptb=`nslookup $line | awk '/^Address: / { print $2 }'` #IP to Block
        # 2) save IP to IPAddresses.txt
            echo $iptb >> $IPAddresses
        done
         # 3) block IP address
        for iptb in $(<$IPAddresses); do
            iplen=${#iptb}
            if [ $iplen -lt 17 ]; then 
                iptables -A INPUT -s $iptb -j REJECT
            else
                ip6tables -A INPUT -s $iptb -j REJECT
            fi
        done

        # ...
        true
            
    elif [ "$1" = "-ips"  ]; then
        # Configure adblock rules based on the IP addresses of $IPAddresses file.
        # ...
        for iptb in $(<IPAddresses.txt); do
            iplen=${#iptb}
            if [ $iplen -lt 17 ]; then 
                iptables -A INPUT -s $iptb -j REJECT
            else
                ip6tables -A INPUT -s $iptb -j REJECT
            fi
        done
        # ...
        true
    elif [ "$1" = "-save"  ]; then
        # Save rules to $adblockRules file.
        # ...
        iptables-save > $adblockRules

        # ...
        true        
    elif [ "$1" = "-load"  ]; then
        # Load rules from $adblockRules file.
        # ...
        iptables-restore < $adblockRules
     
        # ...
        true
    elif [ "$1" = "-reset"  ]; then
        # Reset rules to default settings (i.e. accept all).
        # ...
        iptables -P INPUT ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables -P FORWARD ACCEPT
        ip6tables -P INPUT ACCEPT
        ip6tables -P OUTPUT ACCEPT
        ip6tables -P FORWARD ACCEPT
        
        iptables -F
        ip6tables -F
        # ...
        true    
    elif [ "$1" = "-list"  ]; then
        # List current rules.
        # ...
        iptables -L -v -n|more
        ip6tables -L -v -n|more
        # ...
        true
    elif [ "$1" = "-help"  ]; then
        printf "This script is responsible for creating a simple adblock mechanism. It rejects connections from specific domain names or IP addresses using iptables.\n\n"
        printf "Usage: $0  [OPTION]\n\n"
        printf "Options:\n\n"
        printf "  -domains\t  Configure adblock rules based on the domain names of '$domainNames' file.\n"
        printf "  -ips\t\t  Configure adblock rules based on the IP addresses of '$IPAddresses' file.\n"
        printf "  -save\t\t  Save rules to '$adblockRules' file.\n"
        printf "  -load\t\t  Load rules from '$adblockRules' file.\n"
        printf "  -list\t\t  List current rules.\n"
        printf "  -reset\t  Reset rules to default settings (i.e. accept all).\n"
        printf "  -help\t\t  Display this help and exit.\n"
        exit 0
    else
        printf "Wrong argument. Exiting...\n"
        exit 1
    fi
}

adBlock $1
exit 0