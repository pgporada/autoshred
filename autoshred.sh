#!/bin/bash
# AUTHOR:   Phil Porada - philporada@gmail.com
# WHAT:     Automatically runs shred on any block device plugged into the computer aside from devices in the exclusion list
# NOTES:    I do not own any rights to Shredder or shred.

BLD=$(tput bold)
RST=$(tput sgr0)
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YEL=$(tput setaf 3)
BLU=$(tput setaf 4)
DIR=$(dirname "$(readlink -f "$0")")
KEYPRESS=""

function check_config() {
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

#### Rounds of wiping method
ROUNDS=1

#### Use a script that notifies the user of the destruction status
# Set to 0 for off, 1 for on
NOTIFICATION=0
NOTIFYSCRIPT="led-notifier.py"

#### Update override. If set to 1, will continue without updating.
OVERRIDE=0
EOL
    kill -9 $$
    fi
}


function usage() {
    echo "${BLD}${RED}#####################################################################################${RST}"
    echo "${BLD}${RED}# WARNING: THIS SCRIPT WILL NUKE DATA IN ANY BLOCK DEVICE NOT IN THE EXCLUSION LIST #${RST}"
    echo "${BLD}${RED}#####################################################################################${RST}"
    echo
    echo "${BLD}Current exclusion list. Run \`lsblk\` to check mounted devices.${RST}"
    echo "${BLD}+--------------------+${RST}"
    for i in ${EXCLUSION[@]}; do
        echo "/dev/$i"
    done
    echo
    echo "${BLD}Script Usage${RST}"
    echo "${BLD}+--------------------+${RST}"
    echo "${BLD}[-f]${RST}   |   Run the script. By default this will be 3 passes of the DoD wipe. Configure autoshred.conf to change this"
    echo "ex: sudo ./$(basename $0) -f"
    echo
    echo "${BLD}[-h]${RST}   |   Show this help message."
    echo "ex: ./$(basename $0) -h"
    echo
    echo "${BLD}[-s]${RST}   |   Display Shredder and exit"
    echo "ex: ./$(basename $0) -s"
    echo
    echo "${BLD}Important Read for Data Sanitization${RST}"
    echo "${BLD}+---------------------+${RST}"
    echo "http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-88r1.pdf"
    echo
}


function shredder_ascii() {
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


function display_header() {
    echo "                               ${BLD}${BLU}##################################${RST}"
    echo "                               ${BLD}${BLU}#${RST}  ${YEL}Block Device Data Destroyer   ${BLD}${BLU}#${RST}"
    echo "                               ${BLD}${BLU}#${RST} ${YEL}==>  Fuck my data up, fam  <== ${BLD}${BLU}#${RST}"
    echo "                               ${BLD}${BLU}##################################${RST}"
    if [ $UPDATE -eq 1 ]; then
        echo "                         ${RED}${BLD}Autoshred has an update. Run \`git pull\`${RST}"
    fi
}


function cleanup() {
    echo "${BLD}${YEL}[-]${RST} Any prior jobs running will continue running even after this script has exited."
    echo "${BLD}${YEL}[-]${RST} Exiting..."
}


function root_check() {
    # Run only with root privs due to the forceful unmounting we need to do.
    # You can't sudo echo. You can technically... but whatever
    if [ $EUID -ne 0 ]; then
        echo "${BLD}${RED}[!]${RST} You must run as root or use sudo"
        echo
        usage
        kill -9 $$
    fi
}


function script_update() {
    cd "${DIR}"
    git fetch
    if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
        echo "${BLD}${YEL}[-]${RST} Autoshred has an update."
        if [ $OVERRIDE -ne 1 ]; then
            echo "${BLD}${YEL}[-]${RST} Run ${BLD}git pull${RST} to update Autoshred."
            exit
        fi
        UPDATE=1
    else
        echo "${BLD}${GRN}[+]${RST} Autoshred is up to date"
        UPDATE=0
    fi
}


function check_args() {
    if [ $# -ne 1 ]; then
        usage
        kill -9 $$
    fi

    while getopts "fhs" opt; do
      case $opt in
        f) root_check;;
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


function run_bddd() {
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
                if [ -z $(ps aux | grep " shred" | grep $i | egrep -v '(grep|defunct)' | awk '{print $16}' | sed 's|/dev/||g' | head -n1) ]; then
                    bash -c "shred --force --zero --iterations=$ROUNDS /dev/$i 2>/dev/null; if [ $? -eq 0 ]; then echo 1 > /sys/block/$i/device/delete; fi;" & &>/dev/null
                elif [ ! -z $(ps aux | grep " shred" | egrep -v "($i|grep|defunct)" | awk '{print $16}' | sed 's|/dev/||g' | head -n1) ]; then
                    continue
                fi
            fi
        done

        echo
        echo
        echo "${BLD}+ Current running jobs +${RST}"
        echo "${BLD}+----------------------+${RST}"
        ps aux | grep " shred" | egrep -v '(grep|delete)'

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


### Order of operations
check_config
check_args "${@}"

if [ $OVERRIDE -eq 0 ]; then 
    script_update
fi

trap cleanup SIGINT SIGTERM SIGKILL SIGTSTP
clear
export -f shredder_ascii
shredder_ascii
display_header
sleep 5
run_bddd
