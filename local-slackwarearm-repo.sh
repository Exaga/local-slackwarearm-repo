#!/bin/bash

# Create Slackware ARM local repository mirror utility script.
#
# local-slackwarearm-repo.sh - SAREPO [v2.0.3] - 13 Mar 2021
#
# Coyright (c) 2021 Exaga - SARPi Project - sarpi.penthux.net
#
# Version - 08 Mar 2021 [v0.1a] - progenitor
#         - 10 Mar 2021 [v1]    - associative array mechanics 
#         - 12 Mar 2021 [v2]    - indexed array mechanics 
#
# ######
#
# This script creates a local Slackware ARM mirror repository of any  
# version(s) [i.e. ARM, Aarch64, 15.0, current] which are defined in 
# the settings. Only change the settings which suit your own personal 
# preferences, unless you really know what you're doing!
#
# This script will create a /home/$(whoami)/slackwarearm directory, by 
# default, which to store any repository data. It will also create a 
# /home/<username>/bin directory to store a database and logfile which 
# contains a list of all the local repository files and used to verify
# (diff) with a remote repository to check if there's any updates. This 
# script can also be added to crontab to run periodically.
#
# Put this script anywhere you choose and run like this:
#
# ~$ chmod +x local-slackwarearm-repo.sh 
# ~$ ./local-slackwarearm-repo.sh
#
# It's also possible to run the apache server software on the system and
# create a symlink to the local Slackware ARM repository so that it can 
# be accessed from the browser and/or used as a local mirror for whatever 
# use you may find for it. After setting up and starting the httpd daemon 
# just create a symlink to the repository directory. For example:
#
# ~# ln -sf /home/$(whoami)/slackwarearm /var/www/htdocs/slackwarearm
#
# Then it should be accessible in your browser and can be used as a URL
# during Slackware ARM 'setup' when selecting source media.
#
# ######


### Slackware brand name !!! Explicitly _DO_NOT_ Change !!!
SLACKNAM=(slackware);

# Slackware ARM Project element !!! Explicitly _DO_NOT_ Change !!!
ARMPROJECT=(arm)

# Slackware ARM [array-based] remote repo dir !!! _DO_NOT_ Change !!!
REMOTE_SAREPO_DIR="::${SLACKNAM[@]}${ARMPROJECT[@]}"

######################################################################
##               local-slackwarearm-repo.sh SETTINGS                ##
######################################################################

# -- Edit the settings in this section to suit your requirements -- ##
#
# PRGNAM vars
PRGNAM="$(basename $BASH_SOURCE .sh)"
PETNAM="SAREPO"

# User directory vars
USERDIR="/home/$(whoami)"
SOURCEDIR="${USERDIR}/public_html/slackwarearm"
USERBINDIR="${USERDIR}/bin"
LOG_FILE="${USERBINDIR}/${PRGNAM}.log"

# Choose the Slackware ARM version(s) you wish to mirror and enter 
# any between the brackets, seperated by a space. Omit any versions 
# which you do not want to download. NOTE: It _MUST_ already exist
# on the remote server before you can download it. Obviously! 
#
# Slackware ARMVERS elements [ 14.2 | 15.0 | current | devtools ]
ARMVERS=(14.2 15.0 devtools)

# Same as the above but this is for Slackware AARCH64 versions when 
# it is released.
#
# Slackware A64VERS elements [ 15.0 | current ]
A64VERS=(current)

# Specify the URL of ONE remote Slackware repository or mirror site
# WITHOUT any leading "http://" or "ftp://" and WITHOUT a trailing 
# forward slash "/".
# e.g. "ftp.arm.slackware.com" or "ftp.halifax.rwth-aachen.de"
# or "mirror.slackbuilds.org" or "slackware.uk"
#
# Remote Slackware ARM repository [ !!! NO ftp:// or trailing "/" !!! ]
SAREPO_URL="slackware.uk"

# Set BANDWIDTH_LIMIT to cap download speed of remote repository data, 
# or set a value of "0" [zero] for no limit [Kilobits per second].
#
# BANDWIDTH_LIMIT [Kbps]
BANDWIDTH_LIMIT="0"

######################################################################
##            END OF local-slackwarearm-repo.sh SETTINGS            ##
######################################################################

# Halt build process on error
set -ue
IFS="$(printf '\n\t')"

# Local .database and .lock files
LOCAL_SAREPO_DB="${USERBINDIR}/.${PRGNAM}.database"
TMP_DATA_DB="${USERBINDIR}/.${PRGNAM}.TMP"
LOCK_FILE="${TMP_DATA_DB}.lock"

# Delete LOCK_FILE TMP_DATA_DB on error trap EXIT
trap "{ echo 'EXIT ${PIPESTATUS[@]}'; rm -rf ${LOCK_FILE} ${TMP_DATA_DB}; exit; }" INT TERM EXIT

# LOG_FILE function
function log {
  echo "$(date +"%F %T") [$$] $1"
  echo "$(date +"%F %T") [$$] $1" >> "${LOG_FILE}"
  
}

# Recreate SOURCEDIR USERBINDIR
echo "Starting ${PETNAM} update [PID $$] ..."
log "${PETNAM} : initiating local repository audit"
mkdir -p "${SOURCEDIR}" "${USERBINDIR}"
rm -f "${TMP_DATA_DB}"
touch "${LOCAL_SAREPO_DB}"

# Create LOCK_FILE - exit if PRGNAM is already running
if [ -f "${LOCK_FILE}" ]; then
  for PID in $(pidof -x "${PRGNAM}.sh"); do
    if [ "${PID}" != "$$" ]; then
      echo "[!] ERROR : ${PRGNAM} : Process is already running with PID ${PID} ..."
      log "[!] ERROR : ${PRGNAM} : Process is already running with PID ${PID} ..."
      exit 1
	else
	  rm -f "${LOCK_FILE}"
      touch "${LOCK_FILE}"
    fi
  done
else
  touch "${LOCK_FILE}"
fi

# Slackware ARM PORT-VERSION array element mechanics function
array_element_mechanics () {
  log "${PETNAM} : validating local repository data ..."
  # Slackware ARM elements
  if [[ "${#ARMVERS[@]}" ]]; then
    REMOTE_SAREPO_ARM_PATH="${SAREPO_URL}${REMOTE_SAREPO_DIR}"/"${SLACKNAM[0]}${ARMPROJECT[0]}"
	for elementarm in "${!ARMVERS[@]}"; do
      log "> [${SAREPO_URL}] ${SLACKNAM[0]}${ARMPROJECT[0]}-${ARMVERS[$elementarm]}"
      rsync -avq --no-motd --contimeout=30 --timeout=60 --delete --itemize-changes --human-readable \
      --log-file="${LOG_FILE}" --log-file-format="%o %n %'''b" --bwlimit="${BANDWIDTH_LIMIT}" \
	  "${REMOTE_SAREPO_ARM_PATH}-${ARMVERS[$elementarm]}" "${SOURCEDIR}" || \
      exit "${PIPESTATUS[@]}"
    done
  fi
  # Slackware AARCH64 elements
  if [[ "${A64VERS[@]}" ]]; then
    REMOTE_SAREPO_A64_PATH="${SAREPO_URL}${REMOTE_SAREPO_DIR}"/"${SLACKNAM[0]}${ARMPROJECT[0]+aarch64}"
    for elementa64 in "${!A64VERS[@]}"; do
      log "> [${SAREPO_URL}] ${SLACKNAM[0]}${ARMPROJECT[0]+aarch64}-${A64VERS[$elementa64]}"
      rsync -avq --no-motd --contimeout=30 --timeout=60 --delete --itemize-changes --human-readable \
      --log-file="${LOG_FILE}" --log-file-format="%o %n %'''b" --bwlimit="${BANDWIDTH_LIMIT}" \
	  "${REMOTE_SAREPO_A64_PATH}-${A64VERS[$elementa64]}" "${SOURCEDIR}" || \
      exit "${PIPESTATUS[@]}"
    done
  fi
  # Process database file
  build_database
  
}

# Process LOCAL_SAREPO_DB file
build_database() {
  cd "${SOURCEDIR}"
  echo "${PETNAM} : verifying ${PRGNAM}.database ..."
  find . -type f ! -name "index.html" -exec ls -la --time-style=full "{}" \+ >> "${TMP_DATA_DB}" 
  #find . -type f ! -name "index.html" -print0 | xargs -0 ls -la --time-style=full >> "${TMP_DATA_DB}" 
  cmp -s "${TMP_DATA_DB}" "${LOCAL_SAREPO_DB}" && CMPSTATUS=0 || CMPSTATUS=1
  if [[ $CMPSTATUS -eq 0 ]]; then 
    log "${PETNAM} : Local repository database is up-to-date ..."
  else 
    rm -f "${LOCAL_SAREPO_DB}" && mv "${TMP_DATA_DB}" "${LOCAL_SAREPO_DB}" && log "${PETNAM} : [!] Local repository database updated!"
  fi
  log "${PETNAM} : local repository audit complete"  
  log "+-----------------------------------------------+" && echo >> ${LOG_FILE}
  echo "${PETNAM} update complete"
  # Done
  exit 

}

# run rsync
array_element_mechanics

#EOF<*>

