include ${TOP}/common.mk

DIRS ?= $(shell find . -maxdepth 1 -type d | grep -vw svn | grep -v DEBIAN | egrep -v '\.$$' | sed 's/\.\///')

all : deb

deb : $(DEB)

tmp.tar : $(shell find $(DIRS) -path '*/.svn' -prune -o -type f -print) Makefile
	tar cvf tmp.tar --exclude=".svn" --exclude="*~" --exclude="\#*" $(DIRS)

debian.tar : DEBIAN/control
	tar cvf debian.tar --exclude=".svn" --exclude="*~" --exclude="\#*" DEBIAN

$(DEB) : tmp.tar debian.tar
	mkdir -p tmp 
	if [ -n "${NFSDESTDIR}" ] ; then mkdir -p tmp/${NFSDESTDIR} ; fi
	tar xvf debian.tar -C tmp
# WARNING:  NFSDESTDIR must have a trailing slash
	tar xvf tmp.tar -C tmp/${NFSDESTDIR}.
	perl -pi -e 's/\$$\(VER\)/$(VER)/g' tmp/DEBIAN/control
	fakeroot sh -c 'chown -R root tmp; dpkg-deb -b tmp $(DEB)'
	rm -rf tmp

push : $(DEB)
	scp $(DEB) $(INCOMING)

divert :
	perl ../tools/divert $(PKG)

clean :
	rm -rf *.deb tmp.tar debian.tar tmp

.PHONY : all deb push divert clean
