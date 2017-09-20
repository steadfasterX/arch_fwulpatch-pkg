#!/bin/bash - 
######################################################################################
#
# FWUL Live Patcher
#
# Copyright (c) 2017: steadfasterX <steadfasterX | gmail - com >
######################################################################################

LOGINUSR=$SUDO_USER
ME=$(id -u)
FWULVARS=/var/lib/fwul/generic.vars
YAD="yad --title=FWUL-LivePatcher"
DEBUG=0
REPOURL="https://github.com/steadfasterX/arch_fwulpatch"

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
    [ -z $patchlevel ] && patchlevel=0
    PREVVER=${fwulversion}.${patchlevel}
else
    F_ERR "cant find needed library file"
    F_EXIT "$0 RELEASE" "3"
fi

# check if patch path exists
if [ ! -d "$FWULPATCHDIR" ];then 
    F_LOG "ERROR: Patch directory ($FWULPATCHDIR) does not exists! ABORTED"
    $YAD --button="Exit" --text "\nERROR:\n\nPatch directory does not exists?!\n\n"
    F_EXIT "$0"
fi

# show main dialog
$YAD --center --width=800\
    --text "\nWelcome to the FWUL Live Patcher.\nThis is mainly useful for FWUL <b>persistent</b> as you have to re-run this on <b>forgetful</b> after each reboot\n" \
    --form \
    --field="Check &amp; Download Patches":FBTN "/usr/local/bin/liveupdater.sh" \
    --button="Cancel":1 --button="Force Mode":2 --button="Start LivePatcher":99

YADANS=$?
F_LOG "Answered: $YADANS"
if [ $YADANS -ne 99 ]|&&[ $YADANS -ne 2 ];then
    F_LOG "Aborted by user" && F_EXIT "$0"
fi

# patch
F_PATCH(){
    for patch in $(find $FWULPATCHDIR -type f -name *.sh | sort -n);do
        [ $DEBUG -eq 1 ] && echo "processing $patch"
        F_LOG "... processing $patch" $LOG
        spatch="${patch##*/}"
        (bash $patch) | $YAD --center --width=500 --progress --progress-text="processing $spatch" --auto-close
        PATCHERR=$?
        if [ $PATCHERR -ne 0 ];then
            F_ERR "problem occured with $patch"   
            $YAD --button=Exit --text "problem occured with $patch! ABORTED.\nCheck $LOG"
        F_EXIT "$0 patching"
        fi	
    done
}

# force or not depending on the users ans
if [ "$YADANS" -eq 2 ];then
    F_LOG "will force patching on user request"
    F_PATCH
else
    F_LOG "will check before patching to ensure we apply when needed only"
    REMVER=$(F_CHKLASTTAG "${REPOURL}.git")
    [ "$REMVER" -le "$PREVVER" ] && $YAD --button=Close --center --width=300 --height=200 --text "\n\nYour LivePatcher database is already current\n\n" && F_EXIT "$0 noupdates" 0
    F_LOG "$REMVER is higher than $PREVVER"
    F_PATCH
fi

source $RELEASE
[ -z $patchlevel ] && patchlevel=0
if [ "$PREVVER" != "${fwulversion}.${patchlevel}" ];then
    F_LOG "previous FWUL version $PREVVER differs from the new one: ${fwulversion}${patchlevel}"
    $YAD --center --width=300 --button=Exit --text "\nAll patches applied.\n\nBefore:\t<b>$PREVVER</b>\nNow:\t<b>${fwulversion}.${patchlevel}</b>\n"
else
    F_LOG "previous FWUL version $PREVVER matches new one: ${fwulversion}.${patchlevel}"
    $YAD --center --width=200 --text "\nFinished - all patches re-applied.\n"
fi

F_LOG "All finished"
