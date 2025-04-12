#!/bin/sh

#
# Redis SMF installation.
# Yuri Voinov (C) 2024-2025
#
# ident "@(#)redis_smf_inst.sh    1.9    12/04/25 YV"
#

#############
# Variables #
#############

PROGRAM_NAME="Redis"
SERVICE_NAME="redis"
SCRIPT_NAME="init.""$SERVICE_NAME"
SMF_XML="$SERVICE_NAME"".xml"
SMF_DIR="/var/svc/manifest/site"
SVC_MTD="/lib/svc/method"
CONF_DIR="/etc"
CONF_FILE="redis.conf"

# OS utilities
CP=`which cp`
CHOWN=`which chown`
CHMOD=`which chmod`
COPY=`which cp`
CUT=`which cut`
ECHO=`which echo`
ID=`which id`
MKDIR=`which mkdir`
SVCCFG=`which svccfg`
SVCS=`which svcs`
UNAME=`which uname`
ZONENAME=`which zonename`

OS_VER=`$UNAME -r|$CUT -f2 -d"."`
OS_NAME=`$UNAME -s|$CUT -f1 -d" "`
OS_FULL=`$UNAME -sr`
ZONE=`$ZONENAME`

###############
# Subroutines #
###############

os_check ()
{
 if [ "$OS_NAME" != "SunOS" ]; then
  $ECHO "ERROR: Unsupported OS $OS_NAME. Exiting..."
  exit 1
 elif [ "$OS_VER" -lt "10" ]; then
  $ECHO "ERROR: Unsupported $OS_NAME version $OS_VER. Exiting..."
  exit 1
 fi
}

root_check ()
{
 if [ ! `$ID | $CUT -f1 -d" "` = "uid=0(root)" ]; then
  $ECHO "ERROR: You must be super-user to run this script."
  exit 1
 fi
}

# Non-global zones notification
non_global_zones ()
{
if [ "$ZONE" != "global" ]; then
 $ECHO "=============================================================="
 $ECHO "This is NON GLOBAL zone $ZONE. To complete installation please copy"
 $ECHO "script $SCRIPT_NAME" 
 $ECHO "to $SVC_MTD"
 $ECHO "in GLOBAL zone manually BEFORE starting service by SMF."
 $ECHO "Note: Permissions on $SCRIPT_NAME must be set to root:sys."
 $ECHO "============================================================="
fi
}

##############
# Main block #
##############

# Pre-inst checks
# OS version check
os_check

# Superuser check
root_check

$ECHO "-------------------------------------------"
$ECHO "- $PROGRAM_NAME SMF service will be install now   -"
$ECHO "-                                         -"
$ECHO "- Press <Enter> to continue,              -"
$ECHO "- or <Ctrl+C> to cancel                   -"
$ECHO "-------------------------------------------"
read p

# Copy SMF files
$ECHO "Copying $PROGRAM_NAME SMF files..."
if [ -f "$SCRIPT_NAME" -a -f "$SMF_XML" ]; then
 $COPY $SCRIPT_NAME $SVC_MTD
 $CHMOD 555 $SVC_MTD/$SCRIPT_NAME

 $COPY $SMF_XML $SMF_DIR

 $SVCCFG validate $SMF_DIR/$SMF_XML>/dev/null 2>&1
 retcode=`$ECHO $?`
 case "$retcode" in
  0) $ECHO "*** XML service descriptor validation successful";;
  *) $ECHO "*** XML service descriptor validation has errors";;
 esac
 $SVCCFG import ./$SMF_XML>/dev/null 2>&1
 retcode=`$ECHO $?`
 case "$retcode" in
  0) $ECHO "*** XML service descriptor import successful";;
  *) $ECHO "*** XML service descriptor import has errors";;
 esac
else
 $ECHO "ERROR: $PROGRAM_NAME SMF service files not found. Exiting..."
 exit 1
fi

$ECHO "Verify $PROGRAM_NAME SMF installation..."

# View installed service
$SVCS $SERVICE_NAME

# Copy conf file
if [ -f "$CONF_FILE" ]; then
 $CP $CONF_FILE $CONF_DIR
else
 $ECHO "ERROR: $CONF_FILE not found. Exiting..."
 exit 1
fi

# Check for non-global zones installation   
non_global_zones

$ECHO "If $PROGRAM_NAME services installed correctly, enable and start it now"

exit 0