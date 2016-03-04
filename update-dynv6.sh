#/bin/sh

# Fritz!Box script to update IP addresses at dynv6.net
# Author: Christoph Hochstaetter
# Code quality level: Proof of concept
# Tested with Fritz!Box 7390 OS version 6.30 (no Freetz required)
# SLA: support: 0 x 24 h, guaranteed uptime: 0.0%, maximum response time: 200 years ;-)

##### Change this to your needs #####

#####################################
hostname=my.host.name                    # set this to your dynv6 hostname
token=xxxxxxxxxxxxxxxxxxxxxxxx           # enter your token here
netmask=/64                              # netmask must be set manually (usually /56 or /64). If in doubt, use /64
sleepinterval=300                        # seconds between checks of new IPv6 address (< 60 not allowed in productive mode, < 300 is strongly discouraged)
#####################################

### End of customization section ####

### don't change anything below this line if you are not a shell script guru

if [ "$1" == "-h" ] || [ $# -gt 1 ]; then
  echo "Usage: $0 [-p | -h]:"
  echo ""
  echo "  -h display help"
  echo "  -p run in production mode (test mode otherwise)"
  echo ""
  echo "You must customize this script before you can use it."
  echo ""
  echo "In the customization section change the following:"
  echo "  hostname=<your dynv6 hostname>"
  echo "  token=<your dynv6 token>"
  echo "  netmask=<ipv6 netmask from your internet provider>"
  echo "  sleepinterval=<seconds between checks for new ipv6 address>"
  echo ""
  exit 3
fi

# noob protection (at least an attempt for it)
if [ "$hostname" == "my.host.name" ]; then
  echo "Please customize hostname."
  exit 1
fi

if [ "$token" == "xxxxxxxxxxxxxxxxxxxxxxxx" ]; then
  echo "Please customize token."
  exit 1
fi

if [ $sleepinterval -lt 60 ] && [ "$1" == "-p" ]; then
  echo "Sleep intervals below 60 seconds are forbidden in production mode."
  echo "Please don't change this limit to not accidentally cause DoS attacks."
  echo "Thanks for your understanding."
  exit 2
fi

while [ 1 ];
do
  ipv6=$(echo $(ifconfig lan | grep "inet6 addr" | grep "Scope:Global" | grep -v "fd00::") | grep -v "fe80::" |  cut -f 3 -d " " | sed -e "s=/64=$netmask=")

  if [ "$ipv6" != "$oldipv6" ]; then
    echo $(date +"%Y-%d-%y %T"): $hostname = $ipv6
    echo $(date +"%Y-%d-%y %T"): wget -q -O - "http://dynv6.com/api/update?hostname=$hostname&ipv4=auto&ipv6=$ipv6&token=$token"
    
    if [ "$1" == "-p" ]; then
      echo $(date +"%Y-%d-%y %T"): $(wget -q -O - "http://dynv6.com/api/update?hostname=$hostname&ipv4=auto&ipv6=$ipv6&token=$token")
    fi
    
    oldipv6=$ipv6
  fi
  
  sleep $sleepinterval
done

