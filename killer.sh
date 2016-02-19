#!/bin/bash
trap stopall SIGINT SIGTERM

function stopall {
  exit 1
}

function killer {
  trap stopall SIGINT SIGTERM
  while $(which true) ; do
    sleep 600
    if [ -n "$STOP" ]; then
      break
    fi

    pkill -f port=${PORT} --newest --signal 9
    pkill -f port=${PORT} --oldest --signal 9

    pkill -f port=${SSL_PORT} --newest --signal 9
    pkill -f port=${SSL_PORT} --oldest --signal 9

    pkill -f web100clt --newest --signal 9
    pkill -f web100clt --oldest --signal 9
  done
}

killer
