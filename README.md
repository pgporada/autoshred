<span class="badge-paypal"><a href="https://paypal.me/pgporada" title="Donate to my project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
[![License](https://img.shields.io/badge/license-GPLv3-brightgreen.svg)](LICENSE)

# Overview: autoshred
[Shred](https://www.gnu.org/software/coreutils/manual/html_node/shred-invocation.html) wrapper script that will allow you to plug in external drives and automatically wipe them. Nwipe is the tool that DBAN uses under the hood to perform its wipes.

- - - -
# Usage

Installation

    sudo apt update
    sudo apt install -y git coreutils vim screen
    git clone https://github.com/pgporada/autoshred && cd autoshred
    mv autoshred.example.conf autoshred.conf
    lsblk
    # Configure your exclusion list to drives that should not be wiped
    vim autoshred.conf

Starting the program on boot

    sudo crontab -e
    @reboot /usr/bin/screen -d -m /home/pi/autoshred/autoshred.sh -f

Displays some help

    ./autoshred -h

Destroy data

    sudo ./autoshred -f

Verifying that autoshred is running

    screen -ls
    ps aux | grep shred

- - - -
# Development/Testing

The average user shouldn't need to worry about this section. This will take you through the process of creating a vagrant and a garbage volume to test the script out

    vagrant up
    vagrant ssh

Create a volume, mount it, and destroy it

```
vagrant@ubuntu-xenial:/vagrant$ sudo dd if=/dev/zero of=MyDrive.img bs=1M count=500
500+0 records in
500+0 records out
524288000 bytes (524 MB, 500 MiB) copied, 2.90638 s, 180 MB/s

vagrant@ubuntu-xenial:/vagrant$ sudo fdisk MyDrive.img

Welcome to fdisk (util-linux 2.27.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x5cb4896a.

Command (m for help): p
Disk MyDrive.img: 500 MiB, 524288000 bytes, 1024000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5cb4896a

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
   Select (default p): p
   Partition number (1-4, default 1): 1
   First sector (2048-1023999, default 2048):
   Last sector, +sectors or +size{K,M,G,T,P} (2048-1023999, default 1023999):

   Created a new partition 1 of type 'Linux' and of size 499 MiB.

   Command (m for help): w
   The partition table has been altered.
   Syncing disks.

vagrant@ubuntu-xenial:/vagrant$ sudo mkfs -t ext4 MyDrive.img
mke2fs 1.42.13 (17-May-2015)
Found a dos partition table in MyDrive.img
Proceed anyway? (y,n) y
Creating filesystem with 512000 1k blocks and 128016 inodes
Filesystem UUID: 48ea4ef2-6393-46e4-b35b-ddf06b27e6a4
Superblock backups stored on blocks:
8193, 24577, 40961, 57345, 73729, 204801, 221185, 401409

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

vagrant@ubuntu-xenial:/vagrant$ sudo mount -t ext4 MyDrive.img /media/test/

vagrant@ubuntu-xenial:/vagrant$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   10G  0 disk
└─sda1   8:1    0   10G  0 part /
sdb      8:16   0   10M  0 disk
loop0    7:0    0  500M  0 loop /media/test
```

- - - -
# Thanks
Thank you for using my software! If you find my code useful to you or your organization, please consider donating some beer money to me via the PayPal badge above. :smile: :beers:

Thanks to http://www.retrojunkie.com/asciiart/cartchar/turtles.htm for the Shredder ascii art.

(C) [Phil Porada](https://philporada.com)
