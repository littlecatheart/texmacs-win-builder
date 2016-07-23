#!/bin/sh

# Recreate git-sdk-$VERSION.exe


ARCH="$(uname -m)"
case "$ARCH" in
i686)
	BITNESS=32
	;;
x86_64)
	BITNESS=64
	;;
*)
	die "Unhandled architecture: $ARCH"
	;;
esac

if test ! -d /build ; then
  mkdir -p /build
fi


cd /build

# libcurl option breaks poppler dll and exes on 32 bits
# we rebuild poppler-qt4 from sources, without curl option
# 1- pull package source (easier with svn)
if test ! -d mingw-w64-poppler-qt4 ; then
svn export https://github.com/Alexpux/MINGW-packages/trunk/mingw-w64-poppler-qt4 mingw-w64-poppler-qt4
fi
cd mingw-w64-poppler-qt4/
# 2- we remove curl option  
sed -i '/--enable-libcurl/d' ./PKGBUILD
# 3- bump version  
sed -i 's/pkgver=0.36.0/pkgver=0.45.0/g' ./PKGBUILD
sed -i 's/93cc067b23c4ef7421380d3e8bd7c940b2027668446750787d7c1cb42720248e/96dd1a6024bcdaa4530a3b49687db3d5c24ddfd072ccb37c6de0e42599728798/g' ./PKGBUILD
# fix typo
sed -i 's/$}/${/g' ./PKGBUILD
MINGW_INSTALLS=mingw32 makepkg-mingw -sLi --noconfirm

# we build mingw-w64-wget from sources (no binary available)
cd /build
if test ! -d mingw-w64-wget ; then
svn export https://github.com/Alexpux/MINGW-packages/trunk/mingw-w64-wget mingw-w64-wget
fi
cd mingw-w64-wget/
MINGW_INSTALLS=mingw32 makepkg-mingw -sLi --noconfirm



# guile 1.8 is not in the MSys2 repos, get it from my Githubs.
cd /build
if test ! -d mingw-w64-guile1.8 ; then
if true ;
then
  # donwload already-built
  mkdir mingw-w64-guile1.8/
  cd mingw-w64-guile1.8/
  wget https://github.com/slowphil/mingw-w64-guile1.8/releases/download/v1.8.8-mingw-w64-i686-1/mingw-w64-i686-guile1.8-1.8.8-1-any.pkg.tar.xz
  pacman --noconfirm -U mingw-w64-i686-guile1.8-1.8.8-1-any.pkg.tar.xz
else
  # build from sources
  git clone https://github.com/slowphil/mingw-w64-guile1.8.git
  cd mingw-w64-guile1.8/
  MINGW_INSTALLS=mingw32 makepkg-mingw -sLi --noconfirm
fi
fi

# now, finally download and build texmacs
cd /build
if test ! -d mingw-w64-texmacs ; then
git clone https://github.com/slowphil/mingw-w64-texmacs.git
fi
cd mingw-w64-texmacs/
MINGW_INSTALLS=mingw32 makepkg-mingw -sL --noconfirm 


#package texmacs
