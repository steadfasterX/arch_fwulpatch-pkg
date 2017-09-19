#!/bin/bash - 
######################################################################################
#
# FWUL Live Patcher - Updater
#
# Copyright (c) 2017: steadfasterX <steadfasterX | gmail - com >
######################################################################################

LOGINUSR=$SUDO_USER
ME=$(id -u)
FWULVARS=/var/lib/fwul/generic.vars
YAD="yad --title='Updating FWUL LivePatcher'"
DEBUG=0
PATCHURL="https://github.com/steadfasterX/arch_fwulpatch/archive/master.zip"
PATCHZIP=fwulpatches.zip


# check perms & restart if required
if [ $ME -ne 0 ];then
    echo "not started as root - will restart as root now!"
    nohup sudo bash $0 &
fi

# include FWUL vars
if [ -r "$FWULVARS" ];then
        source $FWULVARS
	[ $DEBUG -eq 1 ] && echo "sourced $FWULVARS"
else
	echo "ERROR: cant find needed fwul variables file" >> $LOG
	exit
fi
# define the log
LOG=${LOGPATH}/liveupdater.log

[ ! -d "$LOGPATH" ] && mkdir -p $LOGPATH
echo -e "\n$(date) - Starting $0" >> $LOG

# include FWUL functions
if [ -r "$FWULLIB" ];then
	source $FWULLIB
	[ $DEBUG -eq 1 ] && echo "sourced $FWULLIB"
else
	F_ERR "cant find needed library file" $LOG
	F_EXIT "$0 LIB" "3"
fi

# include FWUL release info

if [ -r "$RELEASE" ];then
    source $RELEASE
    [ $DEBUG -eq 1 ] && echo "sourced $RELEASE"
else
    F_ERR "cant find needed library file"
    F_EXIT "$0 RELEASE" "3"
fi

# check if patch path exists
if [ ! -d "$FWULPATCHDIR/patches" ];then 
    F_LOG "ERROR: Patch directory ($FWULPATCHDIR/patches) does not exists! ABORTED"
    $YAD --center -- width=500 --button="Exit" --text "\nERROR:\n\nPatch directory does not exists?!\n\n"
    F_EXIT "$0"
fi

# show download dialog
(wget $PATCHURL -O $PATCHZIP) | $YAD --center --width=400 --progress --progress-text="... downloading" --auto-close
[ ! -f "$PATCHZIP" ] && F_ERR "Missing patch update file! Something went wrong with download" && F_EXIT "$0 patchdownload"

(echo 0 && cd /tmp && unzip $PATCHZIP >>$LOG 2>&1 && cp -av fwulpatches/arch_fwulpatch-master/patches/* $FWULPATCHDIR/patches/ >> $LOG 2>&1) | $YAD --width=300 --center --pulsate --progress --progress-text="... refresh local patch db" --auto-close
REFRESHDB=$?

if [ $REFRESHDB -eq 0 ];then
    $YAD --center --width=500 --text "Successfully updated the FWUL LivePatcher database"
else
    F_ERR "ERROR while refreshing FWUL LivePatcher db! Check your internet connection and logfile:\n$LOG\n"
fi

F_EXIT "All finished" $REFRESHDB
