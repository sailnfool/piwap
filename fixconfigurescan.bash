#! /bin/bash
# https://stackoverflow.com/questions/16898125/error-packaging-a-shell-script-with-autotools
#
here=$(pwd)
package_src=$(basename ${here})
FULL_PACKAGE_NAMe="$(cat PKG_FULL_NAME)"
if [ ! "${package_src}" = "virgin_${FULL_PACKAGE_NAME}" ]
then
	errecho "This script can only be run from the virgin source tree"
	errecho "This directory is $here - $package_src, should be virgin_${FULL_PACKAGE_NAME}"
	exit 1
fi
MAJOR_VERSION="$(cat PKG_MAJOR_VERSION)"
MINOR_VERSION="$(cat PKG_MINOR_VERSION)"
PACKAGE_REVISION=$(expr $(cat PKG_REVISION) '+' 1 )
if [ ${PACKAGE_REVISION} -gt 99 ]
then
	PACKAGE_REVISION=0
	MINOR_VERSION=$(expr ${MINOR_VERSION} '+' 1 )
	if [ ${MINOR_VERSION} -gt 99 ]
	then
		MINOR_VERSION=0
		MAJOR_VERSION=$(expr ${MAJOR_VERSION} '+' 1 )
		echo ${MAJOR_VERSION} > PKG_MAJOR_VERSION
	fi
	echo ${MINOR_VERSION} > PKG_MINOR_VERSION
fi
echo ${PACKAGE_REVISION} > PKG_REVISION
PACKAGE_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}-${PACKAGE_REVISION}"
BUG_REPORT_ADDRESS="sailnfool@gmail.com"
newdir=../${FULL_PACKAGE_NAME}_${PACKAGE_VERSION}
if [ -d $newdir ]
then
	##########
	# In theory we should never get here because the PACKAGE_REVISION
	# is incremented each time that this script is run.
	##########
	errecho "Directory $newdir already exists.  Aborting"
	exit 2
fi
echo "Copying from virgin{${FULL_PACKAGE_NAME} to $newdir"
find . -print | cpio -pdmv $newdir
cd $newdir
autoscan
sed -e "s/FULL-PACKAGE-NAME/${FULL_PACKAGE_NAME}/" \
-e "s/VERSION/${PACKAGE_VERSION}/" \
-e "s|BUG-REPORT-ADDRESS|${BUG_REPORT_ADDRESS}|" \
-e '10i\
AM_INIT_AUTOMAKE' \
<configure.scan > configure.ac
touch NEWS README AUTHORS Changelog
autoreconf -iv
# ./configure
# make distcheck
