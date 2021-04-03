# local-slackwarearm-repo README

 local-slackwarearm-repo is also available on SlackDocs Project:   
 https://docs.slackware.com/howtos:hardware:arm:slackwarearm_local-mirror-repository

 Create Slackware ARM local mirror repository utility script.

 local-slackwarearm-repo.sh - SAREPO [v2.0.3] -  13 Mar 2021

 Copyright (c) 2021 Exaga - SARPi Project - https://sarpi.penthux.net
```
 Versions - 08 Mar 2021 [v0.1a] - progenitor   
          - 10 Mar 2021 [v1]    - associative array mechanics    
          - 12 Mar 2021 [v2]    - indexed array mechanics   
```
######

 This script creates a local Slackware ARM mirror repository of any 
 version(s) [i.e. ARM, Aarch64, 15.0, current] which are defined in 
 the settings. Only change the settings which suit your own personal 
 preferences, unless you really know what you're doing!

 This script will create a /home/$(whoami)/slackwarearm directory, by 
 default, which to store any repository data. It will also create a 
 /home/$(whoami)/bin directory to store a database and logfile which 
 contains a list of all the local repository files and used to verify 
 (diff) with a remote repository to check if there's any updates. This 
 script can also be added to crontab to run periodically.

 Put this script anywhere you choose and run like this:
```
 ~$ chmod +x local-slackwarearm-repo.sh 
 ~$ ./local-slackwarearm-repo.sh
```
 It's also possible to run the apache server software on the system and 
 create a symlink to the local Slackware ARM repository so that it can 
 be accessed from the browser and/or used as a local mirror for whatever 
 use you may find for it. After setting up and starting the httpd daemon 
 just create a symlink to the repository directory. For example: 
```
 ~# ln -sf /home/<-username->/slackwarearm /var/www/htdocs/slackwarearm
```
 Then it should be accessible in your browser and can be used as a URL 
 during Slackware ARM 'setup' when selecting source media. 

 ######

### !!!_ BEFORE_RUNNING_THIS_SCRIPT_!!! ###

 Users should edit the settings under the following section within the 
 script code shown below to suit their own requirements: 
```
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
SOURCEDIR="${USERDIR}/slackwarearm"
USERBINDIR="${USERDIR}/bin"
LOG_FILE="${USERBINDIR}/${PRGNAM}.log"

# Choose the Slackware ARM version(s) you wish to mirror and enter 
# any between the brackets, seperated by a space. Omit any versions 
# which you do not want to download. NOTE: It _MUST_ already exist
# on the remote server before you can download it. Obviously! 
#
# Slackware ARMVERS elements [ 14.2 | 15.0 | current | devtools ]
ARMVERS=(14.2 current devtools)

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
```

Then RUN the script periodically and/or put it in a crontab...

#EOF<*>
