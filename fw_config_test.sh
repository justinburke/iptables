#!/bin/bash

DELAY_SEC=4

################################################################################

ts=$(date +%Y%m%d-%H%M%S)
backup_file=iptables.backup.$ts

################################################################################

notify() {
  local t=$(date +%H:%M:%S.%N)
  echo "[$t] $@"
}

notify_err() {
  local t=$(date +%H:%M:%S.%N)
  echo "[$t] Error: $*" 1>&2
  exit 1
}

################################################################################

if [$1 == ""]; then
  echo "Usage: $(basename $0) test_config_script"
  exit 1
fi

test_script=$1

if [ -e $backup_file ]; then
  notify_err "Error: backup file ($backup_file) already exists."
fi

notify "Saving to backup file ($backup_file)"
iptables-save > $backup_file || notify_err "iptables-save failed"

stdout=exec.$ts.stdout
stderr=exec.$ts.stderr

notify "Running test configuration script: $test_script"
notify "(Saving stdout to $stdout . Saving stderr to $stderr .)"
$test_script >$stdout 2>$stderr
notify "Script exited with code: $?"

notify "Sleeping for $DELAY_SEC seconds"
sleep $DELAY_SEC

notify "Restoring from backup file"
iptables-restore < $backup_file

