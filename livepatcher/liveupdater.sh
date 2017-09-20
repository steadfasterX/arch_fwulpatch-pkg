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
YAD="yad --title=Updating-LivePatcher"
DEBUG=0
REPOURL="https://github.com/steadfasterX/arch_fwulpatch"
PATCHURL="$REPOURL/archive/master.zip"
PATCHZIP=/tmp/fwulpatches.zip


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
if [ -r "$GENFUNC" ];then
	source $GENFUNC
	[ $DEBUG -eq 1 ] && echo "sourced $GENFUNC"
else
	F_ERR "cant find needed library file" $LOG
	F_EXIT "$0 GENFUNC" "3"
fi

# include FWUL release info

if [ -r "$RELEASE" ];then
    source $RELEASE
    [ $DEBUG -eq 1 ] && echo "sourced $RELEASE"
    CURVER="$(echo $fwulversion | tr -d '.')"
else
    F_ERR "cant find needed library file"
    F_EXIT "$0 RELEASE" "3"
fi

# check if needed
REMVER=$(git ls-remote --tags ${REPOURL}.git|cut -d "/" -f3 |head -n 1 | tr -d '.')
[ "$REMVER" -le "$CURVER" ] && $YAD --button=Close --center --width=300 -height=200 --text "\n\nYour LivePatcher database is already current\n\n" && F_EXIT "$0 noupdates" 0
F_LOG "$REMVER is higher than $CURVER"

# check if patch path exists
if [ ! -d "$FWULPATCHDIR" ];then 
    F_LOG "ERROR: Patch directory ($FWULPATCHDIR) does not exists! ABORTED"
    $YAD --center -- width=500 --button="Exit" --text "\nERROR:\n\nPatch directory does not exists?!\n\n"
    F_EXIT "$0"
fi

# clean any previous run
[ -d /tmp/arch_fwulpatch-master ] && F_LOG "$(rm -vfr /tmp/arch_fwulpatch-master)"
[ -f $PATCHZIP ] && F_LOG "$(rm -vf $PATCHZIP)"

# show download dialog
(wget $PATCHURL -O $PATCHZIP) | $YAD --center --width=400 --progress --progress-text="... downloading" --auto-close
[ ! -f "$PATCHZIP" ] && F_ERR "Missing patch update file! Something went wrong with download" && F_EXIT "$0 patchdownload"

(echo 0 && cd /tmp && unzip $PATCHZIP >>$LOG 2>&1 && cp -av arch_fwulpatch-master/patches/* $FWULPATCHDIR/ >> $LOG 2>&1) | $YAD --width=300 --center --pulsate --progress --progress-text="... refresh local patch db" --auto-close
REFRESHDB=$?

if [ $REFRESHDB -eq 0 ];then
    $YAD --button=Close --center --width=400 --height=200 --text "\n\nSuccessfully updated the FWUL LivePatcher database\n\n"
else
    F_ERR "ERROR while refreshing FWUL LivePatcher db! Check your internet connection and logfile:\n$LOG\n"
fi

F_EXIT "All finished" $REFRESHDB
