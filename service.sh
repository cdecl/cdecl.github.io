#!/bin/bash

# service.sh - Script to manage Hugo development server

PID_FILE="./hugo-server.pid"
LOG_FILE="./hugo-server.log"
HUGO_COMMAND="hugo server --bind 0.0.0.0 --disableFastRender" # --minify --destination public

start() {
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null; then
            echo "Hugo server is already running with PID $PID."
            return 0
        else
            echo "Stale PID file found. Cleaning up."
            rm $PID_FILE
        fi
    fi

    echo "Starting Hugo server..."
    # Start in background, redirect output to log file
    $HUGO_COMMAND > $LOG_FILE 2>&1 &
    PID=$!
    echo $PID > $PID_FILE
    echo "Hugo server started with PID $PID. Log: $LOG_FILE"
}

stop() {
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null; then
            echo "Stopping Hugo server with PID $PID..."
            kill $PID
            # Optional: wait for process to terminate
            # while ps -p $PID > /dev/null; do sleep 1; done
            echo "Hugo server stopped."
        else
            echo "No running Hugo server found with PID $PID."
        fi
        rm $PID_FILE
    else
        echo "No PID file found. Hugo server might not be running."
    fi
}

restart() {
    stop
    sleep 2
    start
}

status() {
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null; then
            echo "Hugo server is running with PID $PID."
        else
            echo "PID file found ($PID_FILE), but process with PID $PID is not running. Stale PID file."
            rm $PID_FILE
        fi
    else
        echo "Hugo server is not running (no PID file found)."
    fi
}

logs() {
    if [ -f $LOG_FILE ]; then
        echo "Showing logs from $LOG_FILE:"
        tail -f $LOG_FILE
    else
        echo "Log file not found: $LOG_FILE"
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac

exit 0
