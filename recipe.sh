#!/bin/bash



#
# Configuration - Will be moved to a .conf?
#
BUILDDIR="/tmp/recipe/build"
BUILDROOT="/tmp/recipe/root"
MINGWPREFIX="/usr/x86_64-w64-mingw32/sys-root/mingw"

mkdir -p "${BUILDDIR}"
mkdir -p "${BUILDROOT}"

#
# Setup
#
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
# Install application
#
win_install_application() {

	mkdir -p "${BUILDROOT}"

	FILENAME="${1}"
	if [ ! -e "${FILENAME}" ]; then
		FILENAME="${MINGWPREFIX}/bin/${FILENAME}"
	fi

	if [ ! -e "${FILENAME}" ]; then
		win_abend "Can't find ${1}"
	fi

	cp "${FILENAME}" "${BUILDROOT}"
	if [ "$?" != "0" ]; then
		win_abend "Can't copy ${FILENAME}"
	fi

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

		find "${BUILDROOT}" -iname "*.dll" >	"${SOURCES}"
		find "${BUILDROOT}" -iname "*.exe" >>	"${SOURCES}"

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
			if [ ! -e "${BUILDROOT}/${FILENAME}" ]; then

				COUNT=$(find "${BUILDROOT}" -iname ${FILENAME} | wc --lines)
				if [ "${COUNT}" == "0" ]; then

					if [ -e "${MINGWPREFIX}/bin/${FILENAME}" ]; then

						win_log "Importing ${MINGWPREFIX}/bin/${FILENAME}"

						AGAIN=1
						cp "${MINGWPREFIX}/bin/${FILENAME}" "${BUILDROOT}"
						if [ "$?" != "0" ]; then
							win_abend "Can't copy ${MINGWPREFIX}/bin/${FILENAME}"
						fi

					elif [ -e ${MINGWPREFIX}/lib/${FILENAME} ]; then

						win_log "Importing ${MINGWPREFIX}/lib/${FILENAME}"

						AGAIN=1
						cp "${MINGWPREFIX}/lib/${FILENAME}" "${BUILDROOT}"
						if [ "$?" != "0" ]; then
							win_abend "Can't copy ${MINGWPREFIX}/lib/${FILENAME}"
						fi

					else 

						win_abend "Can't find ${FILENAME}"

					fi

				fi


			fi

		done < ${REQUIRES}

		rm -f ${SOURCES}
		rm -f ${REQUIRES}

	done


}

cleanup
win_install_application pw3270.exe
win_install_modules


