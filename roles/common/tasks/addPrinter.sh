#!/bin/bash

# printer options
PRINTER_NAME=${PRINTER_NAME:=}
PRINT_SERVER=${PRINT_SERVER:=}

# driver options
# DRIVER_PKG it will be silently installed and inform DRIVER_PATH
DRIVER_PKG=${DRIVER_PKG:=}
DRIVER_PATH=${DRIVER_PATH:=}
DRIVER_OPTIONS=${DRIVER_OPTIONS:=}


if [ ! -z "${DRIVER_PKG}" ]; then
	installer -store -pkg "${DRIVER_PKG}" -target /
	DRIVER_PATH=$(pkgutil --payload-files "${DRIVER_PKG}" | grep -m 1 -F "/Library/Printers/PPDs/Contents/Resources/" | sed 's/^\.//')
fi

lpadmin -p ${PRINTER_NAME} -v smb://${PRINT_SERVER}/${PRINTER_NAME} -P "${DRIVER_PATH}" -o printer-is-shared=false ${DRIVER_OPTIONS} 
cupsenable ${PRINTER_NAME}
cupsaccept ${PRINTER_NAME}
lpoptions -d ${PRINTER_NAME}