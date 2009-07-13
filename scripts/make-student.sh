#!/bin/sh

student=$1


cat >/etc/xen/student${student} <<XENCFG
name = "student${student}"
memory = "64"
disk = [ 'phy:/dev/GuestGroup00/MLS_student${student},sda1,w',
	'phy:/dev/GuestGroup00/MLS_student${student}_swap,sda2,w',
	'phy:/dev/GuestGroup00/MLS_student${student}_data,sdb1,w' ]
vif = [ 'mac=00:16:3e:a8:${student}:89, bridge=front',
	'mac=00:16:3e:a9:${student}:89, bridge=back${student}' ]
kernel  = "/images/kernel/vmlinuz-2.6.16.29-pae-3.0.3e"
#root = "/dev/sda1 ro vdso=0 init=/bin/sh" 
root = "/dev/sda1 ro vdso=0" 

on_reboot   = 'restart'
on_crash    = 'restart'
XENCFG

brctl addbr back${student}; ifconfig back${student} up

port=$(($student + 2200))
vncport=$(($student + 5900))
ip=$(($student + 32))
guestip=$(($student + 64))

iptables -A PREROUTING -t nat -d 206.191.0.162 -p tcp --dport ${port} -j DNAT --to-destination 172.16.1.$ip:22

iptables -A PREROUTING -t nat -d 206.191.0.162 -p tcp --dport ${vncport} -j DNAT --to-destination 172.16.1.$guestip:5900

lvcreate -L 4G --name MLS_student${student}        /dev/GuestGroup00
lvcreate -L 512M --name MLS_student${student}_swap /dev/GuestGroup00
lvcreate -L 8G --name MLS_student${student}_data   /dev/GuestGroup00
mkfs.ext3 /dev/GuestGroup00/MLS_student${student}
mkfs.ext3 /dev/GuestGroup00/MLS_student${student}_data
mkswap    /dev/GuestGroup00/MLS_student${student}_swap

mount  /dev/GuestGroup00/MLS_student${student} /mnt
zcat /images/ols-campus/MLS_server.dump.gz | (cd /mnt && restore -xf - )

cat >/mnt/etc/network/interfaces <<STUDENTIF
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
        address 172.16.1.${ip}
        netmask 255.255.255.0
        gateway 172.16.1.1

auto eth1
iface eth1 inet static
        address 172.23.1.250
        netmask 255.255.240.0
STUDENTIF

echo "student${student}" >/mnt/etc/hostname
echo CHANGING PASSWORD to root_s${student}.
( echo root_s${student}; echo root_s${student}; ) | (chroot /mnt passwd root)

umount /mnt

studmac=12-00-00-aa-2${student}-11
cat >/etc/xen/$studmac <<DESKTOP
name = "$studmac"
memory = "128"
kernel = "/images/kernel/vmlinuz-vL2007-45t1"
ramdisk = "/images/initrd/initrd-vL2007-45t1"
nfs_server = "172.23.1.250"
nfs_root = "/exports/root/12-00-00-aa-11-11/,rsize=1024,wsize=1024"
root = "/dev/nfs ro"
vif = [ 'mac=12:00:00:aa:2${student}:11, bridge=back${student}',
        'mac=12:00:00:bb:2${student}:11, bridge=front' ]
ip = "172.23.2.1"
netmask = "255.255.240.0"
on_reboot = "restart"
on_crash =  "restart"
DESKTOP

useradd -m --shell /bin/rbash -G mls student${student} 
cd /home/student${student}
mkdir bin
cp ~teacher/.profile . 
chown root .profile .bash_logout .bashrc
cp ~teacher/bin/* bin
echo $studmac >.mac

(echo xen_${student} ; echo xen_${student} ) | passwd student${student}

