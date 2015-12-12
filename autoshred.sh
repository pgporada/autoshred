#!/bin/bash
# AUTHOR:   Phil Porada - philporada@gmail.com
# WHAT:     Automatically runs nwipe on any block device plugged into the computer aside from devices in the exclusion list
# NOTES:    I do not own any rights to Shredder or nwipe.

BLD=$(tput bold)
RST=$(tput sgr0)
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YEL=$(tput setaf 3)
BLU=$(tput setaf 4)
DIR=$(dirname "$(readlink -f "$0")")
KEYPRESS=""

check_config() {
    cd "${DIR}"
    if [ -f autoshred.conf ]; then
        source autoshred.conf
        echo "${BLD}${GRN}[+]${RST} Config loaded from "${DIR}"/autoshred.conf"
    else
        echo "${BLD}${RED}[!]${RST} "${DIR}"/autoshred.conf was not located"
        echo "${BLD}${YEL}[-]${RST} Creating a template => "${DIR}"/autoshred.example.conf"
        echo "${BLD}${YEL}[-]${RST} Please configure autoshred.example.conf, rename it to autoshred.conf, and run this script again"
        cat <<- "EOL" > autoshred.example.conf
####
#### WARNING: USE autoshred.sh AT YOUR OWN RISK.
####

#### This block devices will be spared from data destruction.
#EXCLUSION=("sda" "sdb" "sdc" "sr0") 
EXCLUSION=("sda" "sdb" "sr0")

#### Wiping method
#METHOD=dod
#METHOD=gutmann
#METHOD=prng
#METHOD=ops2
#METHOD=zero
#METHOD=quick
METHOD=dodshort

#### Rounds of wiping method
#ROUNDS=1
ROUNDS=3

#### Use a script that notifies the user of the destruction status
# Set to 0 for off, 1 for on
NOTIFICATION=0
NOTIFYSCRIPT="led-notifier.py"
EOL
    kill -9 $$
    fi
}


usage() {
    echo "${BLD}${RED}#####################################################################################${RST}"
    echo "${BLD}${RED}# WARNING: THIS SCRIPT WILL NUKE DATA IN ANY BLOCK DEVICE NOT IN THE EXCLUSION LIST #${RST}"
    echo "${BLD}${RED}#####################################################################################${RST}"
    echo
    echo "${BLD}Current exclusion list. THIS IS IMPORTANT.${RST}"
    echo "${BLD}+--------------------+${RST}"
    for i in ${EXCLUSION[@]}; do
        echo "/dev/$i"
    done
    echo
    echo "${BLD}Script Usage${RST}"
    echo "${BLD}+--------------------+${RST}"
    echo "[ -f ]   |   Run the script. By default this will be 3 passes of the DoD wipe. Configure autoshred.conf to change this"
    echo "ex: sudo ./$(basename $0) -f"
    echo
    echo "[ -h ]   |   Show this help message."
    echo "ex: ./$(basename $0) -h"
    echo
    echo "[ -s ]   |   Display Shredder and exit"
    echo "ex: ./$(basename $0) -s"
    echo
    echo "${BLD}Important Read for Data Sanitization${RST}"
    echo "${BLD}+---------------------+${RST}"
    echo "http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-88r1.pdf"
    echo
}


shredder_ascii() {
    # Thanks to http://www.retrojunkie.com/asciiart/cartchar/turtles.htm
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
    echo "                               ${BLD}${BLU}#${RST}  ${YEL}Block Device Data Destroyer   ${BLD}${BLU}#${RST}"
    echo "                               ${BLD}${BLU}#${RST} ${YEL}==> because fuck your data <== ${BLD}${BLU}#${RST}"
    echo "                               ${BLD}${BLU}##################################${RST}"
}


cleanup() {
    echo "${BLD}${YEL}[-]${RST} Any prior jobs running will continue running even after this script has exited."
    echo "${BLD}${YEL}[-]${RST} Exiting..."
}


root_check() {
    # Run only with root privs due to the forceful unmounting we need to do.
    # You can't sudo echo. You can technically... but whatever
    if [ $EUID -ne 0 ]; then
        echo "${BLD}${RED}[!]${RST} You must run as root or use sudo"
        echo
        usage
        kill -9 $$
    fi
}


script_update() {
    cd "${DIR}"
    echo "${BLD}${GRN}[+]${RST} Checking https://github.com/pgporada/autoshred repository for updates"
    git pull
}


check_prereqs() {
    if [ -f /etc/redhat-release ] ; then
        rpm -q nwipe &>/dev/null
        if [ $? -eq 1 ]; then
            echo "${BLD}${RED}[!]${RST} Nwipe  not found. Installing nwipe"
            sudo yum install -y nwipe
            echo "${BLD}${GRN}[+]${RST} Nwipe installed @ $(which nwipe)"
        fi
    elif [ -f /etc/debian_version ]; then
        dpkg-query -l nwipe &>/dev/null
        if [ $? -eq 1 ]; then
            echo "${BLD}${RED}[!]${RST} Nwipe  not found. Installing nwipe"
            sudo apt-get install -y nwipe
            echo "${BLD}${GRN}[+]${RST} Nwipe installed @ $(which nwipe)"
        fi
    else 
        echo "${BLD}${RED}[!]${RST} Unsupported disto at this time"
        kill -9 $$ 2>/dev/null
    fi
}


check_args() {

    if [ $# -ne 1 ]; then
        usage
        kill -9 $$
    fi

    while getopts "fhs" opt; do
      case $opt in
        f) root_check; 
           echo "${BLD}${GRN}[+]${RST} Running!" >&2;
           ;;
        h) usage;
           kill -9 $$;
           ;;
        s) shredder_ascii;
           kill -9 $$;
           ;;
       \?) echo "Invalid option: -$OPTARG" >&2;
           usage;
           kill -9 $$;
           ;;
      esac
    done
}


run_bddd() {
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
                if [ -z $(ps aux | grep nwipe | grep $i | egrep -v '(grep|defunct|autonuke)' | awk '{print $16}' | sed 's|/dev/||g' | head -n1) ]; then
                    bash -c "nwipe --autonuke --nogui -m $METHOD -r $ROUNDS /dev/$i 2>/dev/null; if [ $? -eq 0 ]; then echo 1 > /sys/block/$i/device/delete; fi;" & &>/dev/null
                elif [ ! -z $(ps aux | grep nwipe | egrep -v "($i|grep|defunct|autonuke)" | awk '{print $16}' | sed 's|/dev/||g' | head -n1) ]; then
                    continue
                fi
            fi
        done

        echo
        echo
        echo "${BLD}+ Current running jobs +${RST}"
        echo "${BLD}+----------------------+${RST}"
        ps aux | grep nwipe | grep -v grep

	if [ $NOTIFICATION -eq 1 ]; then 
		if [ ${#DETECTED[@]} -ne 0 ]; then
			./${NOTIFYSCRIPT}
		fi
	fi

        KEYPRESS="$(cat -v)"
        unset DETECTED
        sleep 1
    done

    # Resets the tty
    if [ -t 0 ]; then
        stty sane
    fi
}


trap cleanup SIGINT SIGTERM SIGKILL SIGTSTP

### Order of operations
script_update
check_config
check_prereqs
check_args "${@}"
clear
export -f shredder_ascii
shredder_ascii
display_header
sleep 5
run_bddd
