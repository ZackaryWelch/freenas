#!/bin/sh
#

umask 022
cd "$(dirname "$0")/../.."
TOP="$(pwd)"
. build/nano_env
. build/functions.sh
. build/poudriere-functions.sh
. build/repos.sh

cleanup()
{
	umountfs ${NANO_OBJ}/_.w/usr/ports/packages
}

# XX: Uncomment to debug
#TRACE=-x

trap cleanup EXIT

JAIL=$(basename $(realpath ${NANO_OBJ}/poudriere/etc/poudriere.d/jails/j))
: ${PORTSLIST:=${NANO_OBJ}/poudriere/etc/ports.txt}
: ${PORTS:=p}

mkdir -p ${NANO_OBJ}/_.w/usr/ports/packages
mount -t nullfs ${NANO_OBJ}/ports/packages/${JAIL}-${PORTS} ${NANO_OBJ}/_.w/usr/ports/packages  || exit 1
echo "PACKAGES RIAK CS============="
fetch -o ${NANO_OBJ}/_.w/usr/ports/packages/All/riak-cs-2.0.0-FreeBSD-amd64.tbz http://s3.amazonaws.com/downloads.basho.com/riak-cs/2.0/2.0.0/freebsd/9.2/riak-cs-2.0.0-FreeBSD-amd64.tbz
echo "PACKAGES STANCION============="
fetch -o ${NANO_OBJ}/_.w/usr/ports/packages/All/stanchion-2.0.0-FreeBSD-amd64.tbz http://s3.amazonaws.com/downloads.basho.com/stanchion/2.0/2.0.0/freebsd/9.2/stanchion-2.0.0-FreeBSD-amd64.tbz
echo "PACKAGES RIAK CS CONTROL============="
fetch -o ${NANO_OBJ}/_.w/usr/ports/packages/All/riak-cs-control-1.0.2-FreeBSD-amd64.tbz http://s3.amazonaws.com/downloads.basho.com/riak-cs-control/1.0/1.0.2/freebsd/9/riak-cs-control-1.0.2-FreeBSD-amd64.tbz

set -e
set -x

if [ -n "$WITH_PKGNG" ]; then
	mkdir -p ${NANO_OBJ}/_.w/usr/local/etc/pkg/repos
	echo "local: { url: \"file:///usr/ports/packages\", enabled: yes }" > ${NANO_OBJ}/_.w/usr/local/etc/pkg/repos/local.conf
	echo "FreeBSD: { enabled: no }" > ${NANO_OBJ}/_.w/usr/local/etc/pkg/repos/FreeBSD.conf
	PACKAGES_TO_INSTALL=""
	for package in $(cat ${PORTSLIST}); do 
		PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $package"
	done
	if [ "$FREEBSD_RELEASE_MAJOR_VERSION" -lt 10 ]; then
		PACKAGESITE="PACKAGESITE=file:///usr/ports/packages"
	else
		PACKAGESITE=""
	fi
	mkdir -p ${NANO_OBJ}/_.w/dev
	chroot ${NANO_OBJ}/_.w /sbin/mount -t devfs devfs /dev
	chroot ${NANO_OBJ}/_.w /bin/sh -c "env ASSUME_ALWAYS_YES=yes ${PACKAGESITE} pkg install $PACKAGES_TO_INSTALL"
echo "PACKAGES INSTALL RIAK CS CONTROL============="
	chroot ${NANO_OBJ}/_.w /bin/sh -c "env ASSUME_ALWAYS_YES=yes ${PACKAGESITE} pkg install /usr/ports/packages/All/riak-cs-control-1.0.2-FreeBSD-amd64.tbz"
echo "PACKAGES INSTALL RIAK CS============="
	chroot ${NANO_OBJ}/_.w /bin/sh -c "env ASSUME_ALWAYS_YES=yes ${PACKAGESITE} pkg install /usr/ports/packages/All/riak-cs-2.0.0-FreeBSD-amd64.tbz"
echo "PACKAGES INSTALL STANCION========="
	chroot ${NANO_OBJ}/_.w /bin/sh -c "env ASSUME_ALWAYS_YES=yes ${PACKAGESITE} pkg install /usr/ports/packages/All/stanchion-2.0.0-FreeBSD-amd64.tbz"
	rm -f ${NANO_OBJ}/_.w/usr/local/etc/pkg.conf
	umount ${NANO_OBJ}/_.w/dev


else
	build/ports/install-ports-from-list.py --index ${NANO_OBJ}/ports/packages/${JAIL}-${PORTS}/INDEX-${FREEBSD_RELEASE_MAJOR_VERSION}.bz2 \
                                       --packages ${NANO_OBJ}/ports/packages/${JAIL}-${PORTS} \
                                       --chroot ${NANO_OBJ}/_.w \
                                       --ports ${PORTSLIST}

fi
set +x

echo "PACKAGES AFTER install===================================BEGIN LIST============="
if [ -n "$WITH_PKGNG" ]; then
	chroot ${NANO_OBJ}/_.w /bin/sh -c "pkg info"
else
	chroot ${NANO_OBJ}/_.w /bin/sh -c "pkg_info"
fi
echo "PACKAGES AFTER install===================================END LIST============="

