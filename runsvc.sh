#!/bin/bash

# convert SIGTERM signal to SIGINT
# for more info on how to propagate SIGTERM to a child process see: http://veithen.github.io/2014/11/16/sigterm-propagation.html
trap 'kill -INT $PID' TERM INT

if [ -f ".path" ]; then
    # configure
    PATH="$(cat .path)"
    export PATH
    echo ".path=${PATH}"
fi

if [ -x ./externals/node24/bin/node ]; then
    nodever="node24"
elif [ -x ./externals/node20/bin/node ]; then
    nodever="node20"
else
    echo "No supported Node.js runtime found under ./externals (expected node24 or node20)" >&2
    exit 1
fi

# run the host process which keep the listener alive
./externals/${nodever}/bin/node ./bin/RunnerService.js &
PID=$!
wait $PID
trap - TERM INT
wait $PID
