#!/bin/sh

######################################################################
#  LetsBackup.sh                                                     #
#  Backup a directory's content in another directory                 #
#  Optionnally send an email too                                     #
#  Created by Pierre BLAZQUEZ on 17/02/2018... on a Mac! :p          #
######################################################################

## History
#  1.0 - First Revision

## Directory parameters
origin="/mnt/UserData/"
destination="/mnt/Backup/"

## Email parameters
email_enabled=1
email_to="[REDACTED]"
email_from="[REDACTED]"
email_subject="Automated - Backup Report"

## Misc variables
can_send_email=0
main_log="Captured main log:"
backup_log="Captured backup log:"
general_status=255
backup_date=$(date)
launched_by=$(whoami)

## Functions we'll use
# This function is a wrapper around echo
print() {
    echo "[$1]\t$2"
    main_log=$main_log"\n[$1]\t$2"
}

# This function will check if external programs are present
check_dependencies() {
    # If we send emails, check of sendmail
    if [ $email_enabled -eq 1 ]
    then
        if [ -x /usr/sbin/sendmail ]
        then
            can_send_email=1
        else
            print "ERROR" "Sendmail is missing. Either disable email sending or install sendmail."
            return 1
        fi
    fi

    # Check for rsync
    if ! [ -x /usr/bin/rsync ]
    then
        print "ERROR" "Rsync is missing. Please install rsync."
        return 1
    fi

    # IT IS ALRITE
    return 0
}

# This function will check if the script's parameters are correct
check_parameters() {
    # Check for the first directory
    if [ ! -d $origin ]
    then
        print "ERROR" "$origin doesn't exist."
        return 1
    fi

    # Check for the second directory
    if [ ! -d $destination ]
    then
        print "ERROR" "$destination doesn't exist."
        return 1
    fi

    # Everything is good
    return 0
}

# This function will perform the backup
do_backup() {
    backup_log=$backup_log" "$(/usr/bin/rsync -a --stats --delete $origin $destination)

    # Check for backup result
    if [ $? -eq 0 ]
    then
        return_value=0
    else
        print "ERROR" "Rsync encountered an error. Please check your logs."
        return_value=1
    fi

    # Return
    return $return_value
}

# This function will send the report email
send_email() {
    # Talking Body
    body="<h1>I've got a backup report for you!</h1>"
    body=$body"<h2>General Status: "
    if [ $general_status -eq 0 ]
    then
        body=$body"<span style='color:green;'>Success!</span>"
    elif [ $general_status -eq 1 ]
    then
        body=$body"<span style='color:red;'>Missing Dependencies</span>"
    elif [ $general_status -eq 2 ]
    then
        body=$body"<span style='color:red;'>Bad Configuration</span>"
    elif [ $general_status -eq 3 ]
    then
        body=$body"<span style='color:red;'>Error During Backup</span>"
    else
        body=$body"<span style='color:purple;'>Unknown Error!</span>"
    fi
    body=$body"</h2>"
    body=$body"<h3>Backup date: $backup_date on $(hostname)</h3>"
    body=$body"<u>Backup Log:</u><br /><pre>$backup_log</pre><br />"
    body=$body"<u>Main Log:</u><br /><pre>$(echo $main_log)</pre><br />"
    body=$body"<u>Kernel Info:</u><br /><pre>$(uname -a)</pre><br />"
    body=$body"<u>Disk Usage:</u><br /><pre>$(df)</pre><br />"
    body=$body"<u>Mount Status:</u><br /><pre>$(mount)</pre><br />"
    body=$body"<h5>Confidentiality Notice: This is an automated email. Please do not respond. If you were not supposed to be the recipient of this email, please destroy it and alert its original recipient.</h5>"

    # Sending it, the proper way
    /usr/sbin/sendmail $email_to <<MAIL
To: $email_to
From: $email_from
Subject: $email_subject
MIME-Version: 1.0
Content-Type: text/html;charset=utf-8

$body
MAIL

   # I knew you were trouble...
    if [ $? -eq 1 ]
    then
        print "ERROR" "An error occured while sending the email"
        return 1
    fi

    # Email has been sent!
    return 0
}

## Main script
print "INFO" "Hey, it's backup time! Let me check a few things first..."
print "INFO" "I've been launched by $launched_by on $backup_date"

check_dependencies
if [ $? -eq 0 ]
then
    print "INFO" "Dependencies are present. Checking parameters..."
    check_parameters
    if [ $? -eq 0 ]
    then
        print "INFO" "Parameters are correct. Let's backup!"
        print "INFO" "Origin: $origin -> Destination: $destination"
        do_backup
        if [ $? -eq 0 ]
        then
            general_status=0
            print "INFO" "Backup ended successfully on $(date)."
        else
            general_status=3
            print "ERROR" "Backup didn't end well. Go check why."
        fi
        echo "[WARN]\t$backup_log\n"
    else
        general_status=2
        print "ERROR" "Your parameters are wrong. Please check them and try again."
    fi
else
    general_status=1
    print "ERROR" "Uh oh, something's missing. Please check what's wrong and try again."
fi

if [ $can_send_email -eq 1 ]
then
    print "INFO" "Sending report by email..."
    send_email
    if [ $? -eq 0 ]
    then
        print "INFO" "Report has been sent"
    else
        print "WARN" "An error occured while sending the report. Syslog will help you."
    fi
fi

print "INFO" "I'm done. Bye."
