#!/bin/bash
set -Eeuo pipefail
echo "AGENT-WRAPPER: Wrapper started with process id: '$$'"
LOGFILE="/var/lib/mongodb-mms-automation/docker-started-automation-agent.log"

# Handler for receiving SIGTERM (kill -15) signals.
# Tells any mongod/mongos to gracefully shutdown before gracefully shutting
# down the automation agent, then shutting down the main 'tail' process
# (OR'd with 'true' to prevent 'no matching processes' from throwing error).
# Finally because any MongoDB processes have now terminated (due to use of 
# wait '-w'), try to kill main Docker process.
sigterm_handler() {
  echo "AGENT-WRAPPER: Starting hanging up mongos/mongod/agent processes"
  killall -w -SIGTERM mongos || true
  killall -w -SIGTERM mongod || true
  killall -w -SIGTERM mongodb-mms-automation-agent || true
  killall -w -SIGTERM tail || true
  kill -KILL 1 || true
  echo "AGENT-WRAPPER: Finished hanging up mongos/mongod/agent processes"
  exit 143
}

# Register the above sigterm handler function
echo "AGENT-WRAPPER: Registering SIGTERM handler"
trap 'kill ${!}; sigterm_handler' SIGTERM

# All args from the Docker CMD, passed to this script, will form the command
# ($@) to be run in the background
echo "AGENT-WRAPPER: Invoking agent in background with command: $@"
echo
nohup "$@" > $LOGFILE 2>&1 &

# Tail the agent log file indefinitely (run in background so can catch signal)
echo "AGENT-WRAPPER: Continuously tailing output log of background agent '${LOGFILE}' ....."
echo
tail -F $LOGFILE & wait ${!}
echo
echo "AGENT-WRAPPER: Terminated"

