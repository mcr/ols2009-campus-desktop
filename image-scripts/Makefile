# See file ../COPYING for license.
#
# This is a work of Michael Richardson (C) 2009 <mcr@simtone.net>
#
# You will need to adapt it to your local situation.


#NEW_VERSION ?= vL2008-01
NEW_VERSION ?= vL$(shell date +%Y-%V)
SKELETON = /proj/thintropy/skeletons
PRODUCTION = $(SKELETON)/production/$(NEW_VERSION)
TARGET_DIR = $(SKELETON)/spool/$(NEW_VERSION)
OS_RELEASE = feisty

# set this to something useful. We use a local mirror, because the production
# mirrors seem to dislike us pulling so many files so fast... Besides,
# it is much more polite.
#UBUNTU_MIRROR = http://tbm800.thintropy.com/ubuntu/
UBUNTU_MIRROR = set-me-to-something-useful
export DEBOOTSTRAP_DIR
export TARGET_DIR

xubuntu-image : $(PRODUCTION)/root/base.list $(PRODUCTION)/sha1sumsum.txt

stage1 $(TARGET_DIR)/base.list :
	-grep /proj/thintropy/skeletons/spool /proc/mounts | awk '{print $$2;}' | while read mount; do sudo umount $$mount; done
	-sudo mv $(TARGET_DIR) $(TARGET_DIR).old
	-sudo rm -rf $(TARGET_DIR).old
	sudo mkdir -p $(TARGET_DIR)
	sudo ./debootstrap $(OS_RELEASE) $(TARGET_DIR) $(UBUNTU_MIRROR) 2>&1 | tee /tmp/build$$$$.log
	sudo ln -s /usr/opt $(TARGET_DIR)/opt
	sudo mkdir -p $(TARGET_DIR)/root/bin
	sudo cp buildGuestImage $(TARGET_DIR)/root/bin
	echo STARTING interactive install
	sudo chroot $(TARGET_DIR) /root/bin/buildGuestImage
	sudo mv $(TARGET_DIR)/lib/tls $(TARGET_DIR)/lib/tls.disabled
	sudo mkdir -p $(TARGET_DIR)/lib/modules/2.6.18-xenU
	echo $(NEW_VERSION) | sudo dd of=$(TARGET_DIR)/PTVERSION
	cat nosetuid.txt | sudo chroot $(TARGET_DIR) xargs chmod u-s

passwd :
	-expect -f pwchange.tcl

stage2 $(PRODUCTION)/root/base.list : $(TARGET_DIR)/base.list
	-expect -f pwchange.tcl
	sudo chroot $(TARGET_DIR) apt-get -y autoremove
	sudo rm -rf $(PRODUCTION)
	sudo mkdir -p $(PRODUCTION)
	sudo mv $(TARGET_DIR)/usr $(PRODUCTION)/usr
	sudo mv $(TARGET_DIR)     $(PRODUCTION)/root
	sudo mkdir -p $(PRODUCTION)/root/usr
	#sudo rm -rf $(PRODUCTION)/root/var/cache/apt $(PRODUCTION)/root/var/lib/apt

$(PRODUCTION)/sha1sumsum.txt : $(PRODUCTION)/sha1sum.txt
	sudo sh -c "(cd $(PRODUCTION) && sha1sum sha1sum.txt >sha1sumsum.txt )"

$(PRODUCTION)/sha1sum.txt : $(PRODUCTION)/root/base.list
	sudo sh -c "(cd $(PRODUCTION) && find root usr -type f -print0 | xargs -0 sha1sum >sha1sum.txt )"

undo :
	sudo mv $(PRODUCTION)/root $(TARGET_DIR)     
	sudo rmdir $(TARGET_DIR)/usr
	sudo mv $(PRODUCTION)/usr $(TARGET_DIR)/usr 

clean :
	sudo rm -rf $(TARGET_DIR)

chroot :
	sudo chroot $(TARGET_DIR) /bin/bash

version :
	@echo $(NEW_VERSION)
	@echo TARGET_DIR=$(TARGET_DIR)

