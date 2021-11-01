#!/bin/bash
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# Copyright (C) 2021 Perry Werneck <perry.werneck@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#


#
# Configuration - Will be moved to a .conf?
#
BUILDDIR="/tmp/recipe/build"
BUILDROOT="/tmp/recipe/root"

. ./recipe.conf

#
# Setup
#
mkdir -p "${BUILDDIR}"
mkdir -p "${BUILDROOT}"
export LANG=C

#
# Cleanup targets
#
cleanup() {
	rm -fr "${BUILDDIR}"
	rm -fr "${BUILDROOT}"
}

#
# Abnormal ending
#
win_abend() {
	echo "${1}"
	exit -1
}

win_log() {
	echo "${1}"
}

#
# Copy package
#
win_copy_package() {
	
	win_log "Importing package ${1}"

	FILES=$(mktemp)
	rpm -ql "${1}" | grep -v "${1}" | grep "${MINGWPREFIX}" | sed -e "s|${MINGWPREFIX}||g" > ${FILES}

	while read FILE
	do
		if [ -f "${MINGWPREFIX}${FILE}" ]; then
			echo "Importing file ${FILE}"			
			mkdir -p "$(dirname "${BUILDROOT}${FILE}")"
			cp "${MINGWPREFIX}${FILE}" "${BUILDROOT}${FILE}"
			if [ "$?" != "0" ]; then
				win_abend "Can't copy ${FILE}"
			fi
		fi
	done < ${FILES}

	rm -f ${FILES}

}

#
# Copy module
#
win_copy_module() {
	win_log "Importing file ${1}"

	mkdir -p "${BUILDROOT}/bin"

	cp "${1}" "${BUILDROOT}/bin"
	if [ "$?" != "0" ]; then
		win_abend "Can't copy ${1}"
	fi

	win_copy_package "$(rpm -qf "${1}")"

	EXTRAPACKAGES=$(mktemp)
	rpm -q --requires $(rpm -qf "${1}") | grep 'lang' | cut -d' ' -f1 > "${EXTRAPACKAGES}"
	rpm -q --requires $(rpm -qf "${1}") | grep 'data' | cut -d' ' -f1 >> "${EXTRAPACKAGES}"

	while read PACKAGE
	do
		win_copy_package "${PACKAGE}"
	done < ${EXTRAPACKAGES}

	rm -f "${EXTRAPACKAGES}"
}

#
# Install application
#
win_install_application() {

	FILENAME="${1}"
	if [ ! -e "${FILENAME}" ]; then
		FILENAME="${MINGWPREFIX}/bin/${FILENAME}"
	fi

	if [ ! -e "${FILENAME}" ]; then
		win_abend "Can't find ${1}"
	fi

	win_copy_module "${FILENAME}"

}

#
# Install required modules
#
win_install_modules() {

	mkdir -p "${BUILDROOT}"

	AGAIN=1
	until [  $AGAIN = 0 ]; do

		SOURCES=$(mktemp)
		REQUIRES=$(mktemp)

		find "${BUILDROOT}/bin" -iname "*.dll" >	"${SOURCES}"
		find "${BUILDROOT}/bin" -iname "*.exe" >>	"${SOURCES}"

		while read FILENAME
		do
			objdump -p ${FILENAME} | grep "DLL Name:" | cut -d: -f2 | tr "[:upper:]" "[:lower:]" >> ${REQUIRES}
		done < ${SOURCES}

		libs_to_exclude="
			advapi32
			cfgmgr32
			comctl32
			comdlg32
			crypt32
			d3d8
			d3d9
			ddraw
			dnsapi
			dsound
			dwmapi
			gdi32
			gdiplus
			glu32
			glut32
			imm32
			iphlpapi
			kernel32
			ksuser
			mpr
			mscms
			mscoree
			msimg32
			msvcr71
			msvcr80
			msvcr90
			msvcrt
			mswsock
			netapi32
			odbc32
			ole32
			oleacc
			oleaut32
			opengl32
			psapi
			rpcrt4
			secur32
			setupapi
			shell32
			shlwapi
			user32
			usp10
			version
			wininet
			winmm
			wldap32
			ws2_32
			wsock32
			winspool.drv
			ntdll
			winhttp
		"

		# Excluo DLLs do sistema
		for i in $libs_to_exclude; do
			sed -i -e "/${i}/d" ${REQUIRES}
		done

		# Procuro pelas DLLs que faltam
		AGAIN=0
		while read FILENAME
		do

			if [ ! -e "${BUILDROOT}/bin/${FILENAME}" ]; then

				if [ -e "${MINGWPREFIX}/bin/${FILENAME}" ]; then

					AGAIN=1
					win_copy_module "${MINGWPREFIX}/bin/${FILENAME}"

				else 

					win_abend "Can't find ${FILENAME}"

				fi

			fi

		done < ${REQUIRES}

		rm -f ${SOURCES}
		rm -f ${REQUIRES}

	done


}

MINGWPREFIX="/usr/x86_64-w64-mingw32/sys-root/mingw"
cleanup
win_install_application "${APPMAIN}"
win_install_modules



