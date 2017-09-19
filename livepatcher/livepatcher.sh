#!/bin/bash - 
######################################################################################
#
# FWUL Live Patcher
#
# Copyright (c) 2017: steadfasterX <steadfasterX | gmail - com >
######################################################################################

LOGINUSR=$SUDO_USER
ME=$(id -u)
PATCHPATH=/opt/fwul/patches
FWULVARS=/var/lib/fwul/generic.vars
YAD="yad --title='FWUL LivePatcher'"
DEBUG=0

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
LOG=${LOGPATH}/livepatcher.log

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
if [ ! -d "$PATCHPATH" ];then 
    F_LOG "ERROR: Patch directory ($PATCHPATH) does not exists! ABORTED"
    $YAD --button="Exit" --text "\nERROR:\n\nPatch directory does not exists?!\n\n"
    F_EXIT "$0"
fi

# patch
for patch in $(find $PATCHPATH -type f -name *.sh);do
    [ $DEBUG -eq 1 ] && echo "processing $patch"
    F_LOG "... processing $patch" $LOG
    bash $patch
    PATCHERR=$?
    if [ $PATCHERR -ne 0 ];then
        F_ERR "problem occured with $patch"   
        $YAD --button=Exit --text "problem occured with $patch! ABORTED.\nCheck $LOG"
	F_EXIT "$0 patching"
    fi	
done



echo all finished
