#!/bin/bash

srcdir=~/nrjcoin
gitrepository=https://github.com/nrjcoin-project/nrjcoin.git
user=nrjcoin
home=/home/$user
confdir=$home/.nrjcoin
installdir=$home/bin

usage() {
	echo "usage: ${0##*/} -asUubir"
	echo "-a: all"
	echo "-s: setup nrjcoin user"
	echo "-U: update/upgrade system and install/update dependencies"
	echo "-u: install/update nrjcoin src"
	echo "-b: build nrjcoind"
	echo "-i: install nrjcoind"
	echo "-r: start/restart nrjcoind"
	echo "-t: start/restart nrjcoind in testnet"
	echo "example: \"${0##*/} -a\" to setup a fresh machine"
	echo "example: \"${0##*/} -ubir\" to fetch src, build and install nrjcoind"
	exit 1
}

##################################
# Parsing command lines
#

setup=false
updatesystem=false
updatesrc=false
build=false
install=false
run=false
runtestnet=false

while getopts asUubirt opt
do
	case $opt in
	a)
		setup=true
		updatesystem=true
		updatesrc=true
		build=true
		install=true
		run=true
		;;
	s)
		setup=true
		;;
	U)
		updatesystem=true
		;;
	u)
		updatesrc=true
		;;
	b)
		build=true
		;;
	i)
		install=true
		;;
	r)
		run=true
		;;
	t)
		runtestnet=true
		;;
	*)
		usage
;;
	esac
done

# XXX
! $setup && 
! $updatesystem && 
! $updatesrc && 
! $build && 
! $install &&
! $run &&
! $runtestnet && usage


##################################
# Functions
#


setup() {
	grep $user /etc/passwd > /dev/null
	if [ $? == 1 ]; then
		echo "Adding $user user"
		sudo useradd -m -U $user
	fi
	sudo -u $user mkdir -p $installdir
	sudo -u $user mkdir -p $confdir
}

updatesystem() {
	sudo apt-get -y update 
	sudo apt-get -y upgrade
	
	sudo apt-get -y install git \
				build-essential \
				libssl-dev \
				libdb-dev \
				libdb++-dev \
				libboost-all-dev \
				libqrencode-dev \
				libminiupnpc-dev
}

# XXX setup ssh pub key auth to use
#     this a noniteractive fashion
updatesrc() {
	if [ -d $srcdir ]; then
		cd $srcdir
		git pull
	else
		git clone $gitrepository $srcdir
	fi
}

build() {
	cd $srcdir/src
	chmod 775 leveldb/build_detect_platform
	make -f makefile.unix USE_UPNP=1 USE_QRCODE=1 USE_IPV6=1
	strip nrjcoind
}


install() {
	killnrjcoind
	sudo cp $srcdir/src/nrjcoind $installdir
	sudo chown $user:$user $installdir/nrjcoind

	sudo cp $srcdir/{nrjcoin,testnet}.conf $confdir
	sudo chown $user:$user $confdir/{nrjcoin,testnet}.conf
}

run() {
	killnrjcoind
 	sudo su -c "LC_ALL=C $installdir/nrjcoind -txindex -reindex" -s /bin/sh $user
}

runtestnet() {
 	sudo su -c "LC_ALL=C $installdir/nrjcoind -txindex -reindex -conf=$confdir/testnet.conf" -s /bin/sh $user
}

killnrjcoind() {
	pid=$(ps opid= -C nrjcoind)
	if [ $? -eq 0 ]; then
		sudo kill -9 $pid
	fi
}

##################################
# Execute
#

$setup && setup
$updatesystem && updatesystem
$updatesrc && updatesrc
$build && build
$install && install
$run && run
$runtestnet && runtestnet
