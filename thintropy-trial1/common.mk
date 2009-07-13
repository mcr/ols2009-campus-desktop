PKG = $(shell grep Package DEBIAN/control | cut -d " " -f2)
VER = 0.0.$(shell svn info | grep Revision | cut -d " " -f2)
# point me somewhere useful
INCOMING?=/dev/null
DEB = $(PKG)_$(VER).deb
