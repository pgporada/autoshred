#!/bin/bash
# AUTHOR:   Phil Porada - philporada@gmail.com
# WHAT:     Automatically runs nwipe on any media plugged into the computer aside from devices in the exclusion list
# WHY:      because automagic


EXCLUSION=("sda" "sdb" "sr")
BLD=$(tput bold)
RST=$(tput sgr0)
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
BLU=$(tput setaf 4)
KEYPRESS=""

usage() {
    echo "${BLD}${RED}WARNING: THIS SCRIPT WILL NUKE DATA IN ANY BLOCK DEVICE NOT IN THE EXCLUSION LIST${RST}"
    echo "${BLD}${RED}WARNING: THIS SCRIPT WILL NUKE DATA IN ANY BLOCK DEVICE NOT IN THE EXCLUSION LIST${RST}"
    echo "${BLD}${RED}WARNING: THIS SCRIPT WILL NUKE DATA IN ANY BLOCK DEVICE NOT IN THE EXCLUSION LIST${RST}"
    echo "${BLD}${RED}WARNING: THIS SCRIPT WILL NUKE DATA IN ANY BLOCK DEVICE NOT IN THE EXCLUSION LIST${RST}"
    echo "${BLD}${RED}WARNING: THIS SCRIPT WILL NUKE DATA IN ANY BLOCK DEVICE NOT IN THE EXCLUSION LIST${RST}"
    echo
    echo "${BLD}Current exclusion list${RST}"
    echo "${BLD}+--------------------+${RST}"
    for i in ${EXCLUSION[@]}; do
        echo "/dev/$i"
    done
    echo
    echo "${BLD}Example usage${RST}"
    echo "${BLD}+-----------+${RST}"
    echo "This will run the script and start wiping your data with a DoD 3 pass"
    echo "sudo ./$(basename $0) -f"
}

# Run only with root privs due to the forceful unmounting we need to do.
# You can't sudo echo. You can technically... but whatever
if [ $EUID -ne 0 ]; then
   usage
   exit 1
fi

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

while getopts ":f" opt; do
  case $opt in
    f)
      echo "${BLD}Running!${RST}" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2;
      usage;
      exit 1;
      ;;
  esac
done


if [ -f /etc/redhat-release ] ; then
    rpm -q nwipe &>/dev/null
    if [ $? -eq 1 ]; then
        echo "${BLD}${RED}===> Nwipe not found. Installing nwipe${RST}"
        sudo yum install -y nwipe 
        echo "${BLD}${GRN}===> Nwipe installed @ $(which nwipe)${RST}"
    fi
elif [ -f /etc/debian_version ]; then
    dpkg-query -l nwipe &>/dev/null
    if [ $? -eq 1 ]; then
        echo "${BLD}${RED}===> Nwipe not found. Installing nwipe${RST}"
        sudo apt-get install -y nwipe 
        echo "${BLD}${GRN}===> Nwipe installed @ $(which nwipe)${RST}"
    fi
else 
    echo "${BLD}${RED}===> Unsupported disto at this time${RST}"
    exit 1
fi

# Thanks to http://www.retrojunkie.com/asciiart/cartchar/turtles.htm
shredder_ascii() {
    cat <<- 'EOF'
                          .;iiiiii;;.
                      ;i!!!!!!!!!!!!!!!i.
                   .i!!!!!!!!!'`.......`''=
                  i!!!!!!!!' .:::::::::::::..
                 i!!!!!!!!' :::::::::::::::::::.
              ' i!!!!!!!!' :::::::::::::::::::::::.
             :  !!!!!!!!! ::::::::::::::::::::::::::.
            ::  !!!!!!!! ::::::::::::::::::::::::::::::
           ::: <!!!!!!!! ::::::::::::::::::::::::::::::: i!!!!>
          .::: <!!!!!!!> ::::::::::::::::::::::::::::'` i!!!!!'
          :::: <!!!!!!!> ::::::::::::::::::::::::'`  ,i!!!!!!'
          :::: `!!!!!!!> :::::::::::::::::::''`  ,i!!!!!!!!'..
         `::::  !!!!!!!!.`::::::::::::::'` .,;i!!!!!!!!!!' ::::.
          ::::  !!!!!!!!!, `''''```  .,;ii!!!!!!!!!!!'' .::::::::
      i!; `::' .!!!!!!!!!!!i;,;i!!!!!!!!!!!!!!!!!!' .::::::::::::::
     i!!!!i;,;i!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!''`  ::::::::::::::::::
     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'`..euJB$. ::::::::::::::::' ::.
      !!!!!!!!!!!!!!!!!!!!!!!!!!!''`,   $$$$$$$$$Fc :::::::::::::: .:::::
        `''''''''''''''''` ..z e$$$F   d$P"`""??<<3c :::::::::::' ::::::::.
           :::: ?Fx$b. "?$ $$$b($$"   dF   'ud$$$$$$c `:::::::' .:::::::::::
           `:::  $$$$$r-.  P9$$$?$bedE' .,d$$$$$$$P"   `::::' .:::::::::::::
            :::: `? =       """"   ""?????????""  .~~~.  :'.:::::::::::::::' ;
            :::::  $$$eeed" .~~~~~~~~~~~~~~~~~~~~~~~~~~~  ::::::::::::::::' i!
            :::::  $$$PF" .~~.$.~~~~~~~~~~~~~~~~~~~~~~~~.  :::::::::::::' ,!!!
             ::       .~~~~~~ ?$ ~~~~~~~~~~~~~~~~~~~~~~~~.  ::::::::::'  ;!!!!
              ::  ~~~~~~~~~~~.`$b ~~~~~~~~~~~~~~~~~~~~~~~~. `:::::::'  ;!!!!!'
             `:::  ~~~~~~~~~~~ `$L ~~~~~~~~~~~~~~~~~~~~~~~ .  `''`   ;!!!!!!
              ::::  ~~~~~~~~~~~ `$c'~~~~~~~~~~~~~~~~~~~~~ ~~ ,iiii! i!!!!!!  !
              :::::  ~~~~~~~~~~~ "$c`~~~~~~~~~~~~~~~~~~~ ~~ ;!!!!' i!!!!!!  i!
              `:::::  ~~~~~~~~~~~ `$.`~~~~~~~~~~~~~~~~  ~  <!!!!' ;!!!!!!'  !!
               :::'`   `~~~~~~~~~~ "$.`~~~~~~~~~~~~~~ .~ .!!!!!' ;!!!!!!!  i!!
                  ,i!    ~~~~~~~~~~ "$r'~~~~~~~~~~~~ '  ;!!!!!  ;!!!!!!!!  !!!
                 !!!!i !i. `~~~~~~~~ `$c ~~~~~~~~~~~~  <!!!!'  i!!!!!!!!!  !!!
                 :!!!!> !!!;  ~~~~~~~. "$. ~~~~~~~~ .;!!!!'  ;!!!!!!!';!!  `!!
                 `!!!!! `!!!!;.  ~~~~~~~~~~~~~~  .;i!!!!' .i!!!!!!' ,!!!!i  !!
                  !!!!!!; `!!!!!i;. ~~~~~~~ .;i!!!!''`.;i!!!!!!!'.;!!!!!!!>  !
              :!  !!!!!!!i `'!!!!!!!!!!!!!!!'''`.;ii!!!!!'`.'` ;!!!!!!!!!!   '
EOF
}

display_header() {
    echo "                               ${BLD}${BLU}##################################${RST}"
    echo "                               ${BLD}${BLU}#${RST}${BLD}    PC Pickup Partition Pwner   ${BLU}#${RST}"
    echo "                               ${BLD}${BLU}#${RST}${BLD} ==> because fuck your data <== ${BLU}#${RST}"
    echo "                               ${BLD}${BLU}##################################${RST}"
}


clear
shredder_ascii
display_header
sleep 3

# This allows you to capture keyboard entries on stdin in a nonblocking fashion
if [ -t 0 ]; then 
    stty -echo -icanon -icrnl time 0 min 0
fi

# Loops through our display while checking if the user wants to exit the prog
while [ "x${KEYPRESS}" = "x" ]; do
    clear
    display_header
    echo "                                     ${BLD}${GRN}Press any key to exit${RST}"
    echo
    echo
    DETECTED=( $(lsblk -dnlo KNAME -e 11,1 | grep -v --color=auto ${EXCLUSION[@]/#/-e}) )

    echo "${BLD}+ Current list of detected devices +${RST}"
    echo "${BLD}+----------------------------------+${RST}"
    for i in ${DETECTED[@]}; do
        echo "/dev/$i"

        if [ -b "/dev/$i" ]; then
            if [ -z $(ps aux | grep nwipe | grep $i | egrep -v '(grep|defunct)' | awk '{print $16}' | sed 's|/dev/||g' | head -n1) ]; then
                gnome-terminal \
                    --geometry=120x7 \
                    -e "bash -c \"nwipe --autonuke --nogui -m dodshort /dev/$i 2>/dev/null; if [ $? -eq 0 ]; then echo 1 > /sys/block/$i/device/delete && exit ; else echo 'Shit was fucked'; fi;\"" & &>/dev/null
            elif [ ! -z $(ps aux | grep nwipe | egrep -v "($i|grep|defunct)" | awk '{print $16}' | sed 's|/dev/||g' | head -n1) ]; then
                continue
            fi
        fi
    done

    echo
    echo
    echo "${BLD}+ Current running jobs +${RST}"
    echo "${BLD}+----------------------+${RST}"
    ps aux | grep nwipe | grep -v grep

    KEYPRESS="$(cat -v)"
    unset DETECTED
    sleep 1
done

# Resets the tty
if [ -t 0 ]; then
    echo "Any prior jobs running will continue running even after this script has exited."
    echo "Exiting..."
    stty sane
fi
