<span class="badge-paypal"><a href="https://paypal.me/pgporada" title="Donate to my project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
[![License](https://img.shields.io/badge/license-GPLv3-brightgreen.svg)](LICENSE)

# Overview: autoshred
[Shred](https://www.gnu.org/software/coreutils/manual/html_node/shred-invocation.html) wrapper script that will allow you to plug in external drives and automatically wipe them. Nwipe is the tool that DBAN uses under the hood to perform its wipes.

- - - -
# Usage

Installation

    sudo apt update
    sudo apt install -y git coreutils vim
    git clone https://github.com/pgporada/autoshred && cd autoshred
    mv autoshred.example.conf autoshred.conf
    lsblk
    # Configure your exclusion list to drives that should not be wiped
    vim autoshred.conf

Starting the program on boot

    sudo crontab -e
    # In the crontab
    @reboot /home/pi/autoshred/autoshred.conf &

Displays some help

    ./autoshred -h

Destroy data

    sudo ./autoshred -f

Verifying that autoshred is running

    ps aux | grep shred

- - - -
Thank you for using my software! If you find my code useful to you or your organization, please consider donating some beer money to me via the PayPal badge above. :smile: :beers:

Thanks to http://www.retrojunkie.com/asciiart/cartchar/turtles.htm for the Shredder ascii art.

(C) [Phil Porada](https://philporada.com)
