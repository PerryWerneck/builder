# SPDX-License-Identifier: LGPL-3.0-or-later
#
#  Copyright (C) 2021 Perry Werneck <perry.werneck@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published
#  by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

!include "MUI2.nsh"
!include "x64.nsh"
!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "winmessages.nsh"

Name "pw3270"
Caption "pw3270 - IBM 3270 Terminal emulator"
outfile "pw3270-5.4.21.11-x86_64.exe"

XPStyle on

installDir "$PROGRAMFILES64\pw3270"

#define the installer icon
!define MUI_ICON "bin/pw3270.ico"
!define MUI_UNICON "bin/pw3270.ico"
icon "bin/pw3270.ico"

# Get installation folder from registry if available
InstallDirRegKey HKLM "Software\pw3270" "InstallLocation"

RequestExecutionLevel admin

# Properties
VIProductVersion "5.4.21.11"
VIFileVersion "21.11.1.11"

# Reference: https://nsis.sourceforge.io/Reference/VIAddVersionKey
VIAddVersionKey "ProductVersion" "5.4.21.11"
VIAddVersionKey "FileVersion" "21.11.1.11"

VIAddVersionKey "ProductName" "pw3270"
VIAddVersionKey "FileDescription" "IBM 3270 Terminal emulator"
VIAddVersionKey "LegalCopyright" "(C) 2017 Banco do Brasil S/A. All Rights Reserved"
# VIAddVersionKey "PrivateBuild" ""

# Interface

!define MUI_ABORTWARNING
# !insertmacro MUI_PAGE_WELCOME
#!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

# !insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
# !insertmacro MUI_UNPAGE_FINISH

# Languages
!insertmacro MUI_LANGUAGE "English"

# Section scripts
!include Sections.nsh

# default section
SubSection "pw3270" SecMain

	Section "Core" SecCore

		SetRegView 64
		${DisableX64FSRedirection}

		# define the output path for this file
		setOutPath $INSTDIR
		SetShellVarContext all

		createShortCut "$SMPROGRAMS\pw3270.lnk" "$INSTDIR\pw3270.exe"
		createShortCut "$DESKTOP\pw3270.lnk" "$INSTDIR\pw3270.exe"

		setOutPath $INSTDIR
		# Binary files
		file /r "bin\*.*"

		# icons & logos
		CreateDirectory "$INSTDIR\icons"
		file "/oname=$INSTDIR\icons\gtk-connect-symbolic.svg"			"share\pw3270\icons\gtk-connect-symbolic.svg"
		file "/oname=$INSTDIR\icons\gtk-disconnect-symbolic.svg"		"share\pw3270\icons\gtk-disconnect-symbolic.svg"
		file "/oname=$INSTDIR\icons\connect-symbolic.svg"			"share\pw3270\icons\connect-symbolic.svg"
		file "/oname=$INSTDIR\icons\disconnect-symbolic.svg"			"share\pw3270\icons\disconnect-symbolic.svg"
		file "/oname=$INSTDIR\icons\pw3270.svg"				"share\pw3270\pw3270.svg"

		file "/oname=$INSTDIR\pw3270-logo.svg"					"share\pw3270\pw3270-logo.svg"
		file "/oname=$INSTDIR\pw3270.svg"					"share\pw3270\pw3270.svg"

		# Schema
		CreateDirectory "$INSTDIR\schemas"
		file "/oname=$INSTDIR\schemas\pw3270-application.gschema.xml"		"share\glib-2.0\schemas\pw3270-application.gschema.xml"
		file "/oname=$INSTDIR\schemas\pw3270-window.gschema.xml"		"share\glib-2.0\schemas\pw3270-window.gschema.xml"
		#file "/oname=$INSTDIR\gschemas.compiled"				"share\glib-2.0\schemas\gschemas.compiled"

		# Configuration files
		file "/oname=$INSTDIR\colors.conf"					"share\pw3270\colors.conf"

		# Documentation files
		#file "/oname=$INSTDIR\AUTHORS"						"AUTHORS"
		#file "/oname=$INSTDIR\LICENSE"						"LICENSE"

		# Misc folders
		CreateDirectory "$INSTDIR\certs"
		CreateDirectory "$INSTDIR\plugins"
		CreateDirectory "$INSTDIR\keypad"

		# UI definition files
		CreateDirectory "$INSTDIR\ui"
		file "/oname=$INSTDIR\ui\application.xml" 	"share\pw3270\ui\application.xml"
		file "/oname=$INSTDIR\ui\window.xml" 		"share\pw3270\ui\window.xml"

		# Charset definition files
		CreateDirectory "$INSTDIR\remap"
		file "/oname=$INSTDIR\remap\bracket.xml" 	"share\pw3270\remap\bracket.xml"

		# Locale files
		#CreateDirectory "$INSTDIR\locale\pt_BR\LC_MESSAGES"
		#file "oname=$INSTDIR\locale\pt_BR\LC_MESSAGES\pw3270.mo"		"share\locale\pt_BR\LC_MESSAGES\pw3270.mo"
		#file "/oname=$INSTDIR\locale\pt_BR\LC_MESSAGES\lib3270-5.4.mo"	"share\locale\pt_BR\LC_MESSAGES\lib3270-5.4.mo"
		#file "/oname=$INSTDIR\locale\pt_BR\LC_MESSAGES\libv3270-5.4.mo"	"share\locale\pt_BR\LC_MESSAGES\libv3270-5.4.mo"

		# define uninstaller name
		SetRegView 32

		writeUninstaller $INSTDIR\uninstall.exe

		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pw3270" \
			         "DisplayName" "pw3270 - IBM 3270 Terminal emulator"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pw3270" \
			         "DisplayIcon" "$INSTDIR\pw3270.ico"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pw3270" \
			         "DisplayVersion" "5.4.21.11"

		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pw3270" \
			         "UninstallString" "$INSTDIR\uninstall.exe"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pw3270" \
			         "InstallLocation" "$INSTDIR"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pw3270" \
			         "NoModify" "1"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pw3270" \
			         "NoRepair" "1"

		# Default settings
		SetRegView 64

		# Setup log file
		# https://docs.microsoft.com/en-us/windows/win32/eventlog/event-sources
		WriteRegStr HKLM "SYSTEM\CurrentControlSet\Services\EventLog\pw3270" \
				 "PackageVersion"	"5.4"

		# Required for IPC Library.
		WriteRegStr 	HKLM	"Software\pw3270"				"InstallLocation"	"$INSTDIR"

		# Customized options
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"autoconnect"		0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"blankfill"             0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"bold"                  0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"keepselected"          0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"marginedpaste"         0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"rectselect"            0x00000000

		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"monocase"              0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"cursorblink"           0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"showtiming"            0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"cursorpos"             0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"linewrap"              0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"crosshair"             0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"fullscreen"            0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"autoreconnect"         0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"insert"                0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"smartpaste"            0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"beep"                  0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"fieldattr"             0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"altscreen"             0x00000001
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"keepalive"             0x00000000

		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"dstrace"               0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"screentrace"           0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"eventtrace"            0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"nettrace"              0x00000000
		WriteRegDWORD	HKLM	"Software\pw3270\toggles"		"ssltrace"              0x00000000

		WriteRegStr 	HKLM	"Software\pw3270"			"font-family"		"Lucida Console"
		WriteRegStr	HKLM	"Software\pw3270"			"colors"		"rgb(24,24,24);rgb(79,156,254);rgb(237,74,70);rgb(235,110,183);rgb(131,199,70);rgb(86,216,201);rgb(239,197,65);rgb(222,222,222);rgb(59,59,59);rgb(54,142,171);rgb(250,145,83);rgb(165,128,226);rgb(112,180,51);rgb(65,199,185);rgb(219,179,45);rgb(119,119,119);rgb(131,199,70);rgb(237,74,70);rgb(65,199,185);rgb(250,145,83);rgb(37,37,37);rgb(222,222,222);rgb(222,222,222);rgb(24,24,24);rgb(222,222,222);rgb(79,156,254);rgb(131,199,70);rgb(239,197,65);rgb(239,197,65)"

	sectionEnd

!ifdef WITHCERTS
	Section "SSL Certificates" SSLCerts
		setOutPath $INSTDIR\certs
		file /r "sslcerts\*.*"
	sectionEnd
!endif

#	SubSection "Plugins" SecPLugin
#
#		Section "Remote control" IPCPlugin
#
#			setOutPath $INSTDIR
#
#			${DisableX64FSRedirection}
#
#			CreateDirectory "$INSTDIR\plugins"
#			file "/oname=$INSTDIR\plugins\ipcserver.dll"			"lib\pw3270-plugins\ipcserver.dll"
#
#			CreateDirectory "$INSTDIR\locale\pt_BR\LC_MESSAGES"
#			file "/oname=$INSTDIR\locale\pt_BR\LC_MESSAGES\libipc3270-5.4.mo"	"share\locale\pt_BR\LC_MESSAGES\libipc3270-5.4.mo"
#
#			file "/oname=$SYSDIR\libipc3270.dll"				"bin\libipc3270.dll"
#
#		sectionEnd
#
#	SubSectionEnd

!ifdef WITHEXTRAS
	SubSection "Extra modules" Languages

!ifdef WITHLIBHLLAPI
		Section "HLLAPI" HLLAPIBinding

			${DisableX64FSRedirection}

			# Install HLLAPI connector
			file "/oname=$SYSDIR\hllapi.dll"		"bin\libhllapi.dll"

			# Install with "lib" prefix for compatibility.
			file "/oname=$SYSDIR\libhllapi.dll"		"bin\libhllapi.dll"

			CreateDirectory "$INSTDIR\locale\pt_BR\LC_MESSAGES"
			file "/oname=$INSTDIR\locale\pt_BR\LC_MESSAGES\libhllapi-5.4.mo"	"share\locale\pt_BR\LC_MESSAGES\libhllapi-5.4.mo"

		SectionEnd
!endif

		Section "KEYPADS" Keypads

			file "/oname=$INSTDIR\keypad\00-right.xml" 	"share\pw3270\keypad\00-right.xml"
			file "/oname=$INSTDIR\keypad\10-bottom.xml" 	"share\pw3270\keypad\10-bottom.xml"

		SectionEnd

	SubSectionEnd
!endif

!ifdef WITHSDK
	Section /o "Software Development Kit" SDK

		setOutPath $INSTDIR\sdk\include
		file /r "include\*.*"

		CreateDirectory "$INSTDIR\sdk"
		CreateDirectory "$INSTDIR\sdk\def"
		CreateDirectory "$INSTDIR\sdk\lib"

		file "/oname=$INSTDIR\sdk\lib\lib3270.dll.a"		"lib\lib3270.dll.a"
		file "/oname=$INSTDIR\sdk\lib\lib3270.delayed.a"	"lib\lib3270.delayed.a"
		file "/oname=$INSTDIR\sdk\lib\lib3270.static.a"	"lib\lib3270.static.a"
		file "/oname=$INSTDIR\sdk\lib\libv3270.dll.a"		"lib\libv3270.dll.a"
		file "/oname=$INSTDIR\sdk\lib\libipc3270.dll.a"	"lib\libipc3270.dll.a"
		file "/oname=$INSTDIR\sdk\lib\libipc3270.static.a"	"lib\libipc3270.static.a"
		file "/oname=$INSTDIR\sdk\lib\libhllapi.dll.a"		"lib\libhllapi.dll.a"

		file "/oname=$INSTDIR\sdk\lib3270.mak"			"share\pw3270\def\lib3270.mak"

		file "/oname=$INSTDIR\sdk\def\lib3270.def"		"share\pw3270\def\lib3270.def"
		file "/oname=$INSTDIR\sdk\def\libv3270.def"		"share\pw3270\def\libv3270.def"
		file "/oname=$INSTDIR\sdk\def\libipc3270.def"		"share\pw3270\def\libipc3270.def"
		file "/oname=$INSTDIR\sdk\def\libhllapi.def"		"share\pw3270\def\libhllapi.def"

		SetRegView 64
		WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "PW3270_SDK_PATH" "$INSTDIR\sdk"
		SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

	SectionEnd
!endif

SubSectionEnd

Section "Uninstall"

	# Always delete uninstaller first
	delete $INSTDIR\uninstaller.exe

	# Remove association

	# Set SMPROGRAMS and DESKTOP path
	SetShellVarContext all

	# now delete installed files
	delete $INSTDIR\pw3270.exe
	delete $SMPROGRAMS\pw3270.lnk
	delete $DESKTOP\pw3270.lnk

	RMDir /r "$INSTDIR\locale"
	RMDir /r "$INSTDIR\share"
	RMDir /r "$INSTDIR\etc"
	RMDir /r "$INSTDIR\plugins"
	RMDir /r "$INSTDIR\sdk"
	RMDir /r "$INSTDIR\gtk2-runtime"

	# Delete all files
	delete "$INSTDIR\*.dll"

	# Remove registry
	SetRegView 32
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pw3270"
	DeleteRegKey HKLM "Software\pw3270"
	
	SetRegView 64
	DeleteRegKey HKLM "Software\pw3270"
	DeleteRegValue HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "PW3270_SDK_PATH"
	DeleteRegKey HKLM "SYSTEM\CurrentControlSet\Services\EventLog\pw3270"

	SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

	DeleteRegKey HKLM "Software\GSettings\apps\pw3270\pw3270"

	# Delete System libraries
	${DisableX64FSRedirection}

	delete $SYSDIR\libipc3270.dll

!ifdef WITHLIBHLLAPI
	delete $SYSDIR\libhllapi.dll
	delete $SYSDIR\hllapi.dll
!endif

	RMDir /r "$INSTDIR"

SectionEnd

Function .onInit

!ifdef WITHSDK

	#---[ Check SDK Command line option ]-----------------------------------------------------------------

	Push $0

	${GetParameters} $R0
	ClearErrors
	${GetOptions} $R0 /SDK= $0

	${if} $0 == "YES"

		SectionGetFlags ${SDK} $0
		IntOp $0 $0 | ${SF_SELECTED}
		SectionSetFlags ${SDK} $0

	${else}

		SectionGetFlags ${SDK} $0
		IntOp $0 $0 & ${SECTION_OFF}
		SectionSetFlags ${SDK} $0

	${EndIf}

	Pop $0
!endif

!ifdef WITHLIBHLLAPI

	#---[ Check HLLAPI Command line option ]-------------------------------------------------------------

	Push $0

	${GetParameters} $R0
	ClearErrors
	${GetOptions} $R0 /HLLAPI= $0

	# Default = YES
	${if} $0 == "NO"

		SectionGetFlags ${HLLAPIBinding} $0
		IntOp $0 $0 & ${SECTION_OFF}
		SectionSetFlags ${HLLAPIBinding} $0

	${else}

		SectionGetFlags ${HLLAPIBinding} $0
		IntOp $0 $0 | ${SF_SELECTED}
		SectionSetFlags ${HLLAPIBinding} $0

		SectionGetFlags ${IPCPlugin} $0
		IntOp $0 $0 | ${SF_SELECTED}
		SectionSetFlags ${IPCPlugin} $0


	${EndIf}

	Pop $0

!endif


FunctionEnd

Function .onInstSuccess

	# Update GTK Image loaders
	

FunctionEnd

