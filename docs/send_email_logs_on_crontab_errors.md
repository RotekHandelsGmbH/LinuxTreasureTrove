# send email logs on crontab errors howto

- date : 2025-01-22

sends an email with logfile if the called script fails (exit code ≠ 0), or can not be executed at all. 

## crontab entry

```config
# crontab 
# edit with sudo crontab -e
# usually stored at /var/spool/cron/crontabs/root
#
############################################################################################
# SEND EMAIL LOGS FOR CRONTABS
############################################################################################
# MAILTO="<email address>"  # sends email if the cronjob itself can not be executed
# LOGDIR="/var/log"
# MAILPROG="/rotek/scripts/update/send_crontab_error_logs.sh"   # your path to the send email script 
#
# m  h   dom     mon     dow     command
# SAMPLE: 
# 10  23  *       *       *       CMD="/some/script.sh"; LOG="${LOGDIR}/$(basename "${CMD}").crontab.log"; "${CMD}" > "${LOG}" 2>&1 || "${MAILPROG}" "${CMD}" "${LOG}" "${MAILTO}" > /dev/null
#
# CMD="/some/script.sh"                             : The script to execute.
# LOG="${LOGDIR}/$(basename "${CMD}").crontab.log"  : Defines the log file path, dynamically named based on the script's filename.
# "${CMD}" > "${LOG}" 2>&1                          : Runs the script, Redirects stdout and stderr to the specified log file
# || "${MAILPROG}" "${CMD}" "${LOG}" "${MAILTO}"    : If the script fails (exit code ≠ 0), executes the `MAILPROG` program, 
#                                                      passing the script name, logfile and email address as an argument.
# > /dev/null                                       : sending the standard output of the mailscript to /dev/null
#                                                     if the mailscript fails, You will receive a mail from cron itself
#
# 
## Dependencies
# LOGDIR: Must be predefined in the environment or the crontab file (e.g., `LOGDIR=/var/log`).
# MAILPROG: Path to the script or command responsible for sending error notifications (e.g., MAILPROG="/usr/bin/send_crontab_error_logs.sh").
# MAILTO: email address
#
## Key Notes
# Ensure that `CMD`, `LOGDIR`, `MAILTO`,and `MAILPROG` are correctly set and accessible.
# Verify that the user running the crontab has appropriate permissions for `LOGDIR` and the script.
# Logs are dynamically named based on the script, ensuring clarity for debugging.
# mutt needs to be installed to send the email 
#
```

## the script to send the email : 

[send_crontab_error_logs.sh](https://github.com/RotekHandelsGmbH/LinuxTreasureTrove/scripts/send_crontab_error_logs.sh)

