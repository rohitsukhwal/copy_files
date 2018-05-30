#!/bin/bash

set -e -u 

if [ $# -lt 2 ]
then 
    echo -e "ts_rewrap: invalid arguments."
    echo -e "ts_rewrap: USAGE :- $ ./ts_rewrap.sh <input.ts> <out.ts>"
    exit 0;
fi 

INP_FILE=$1
OUT_FILE=$2

FFMPEG_CMD="ffmpeg -y -i $INP_FILE "
STREAM_CNT=0;

ffmpeg -i ${INP_FILE} 2>&1 3>&1 |  grep -i "Stream #" | { 
while read CMD 
do 
    PROGRAM_ID=`echo "$CMD" | cut -d'#' -f 2 | cut -d':' -f 1`
    STREAM_ID=`echo "$CMD" | cut -d'#' -f 2 | cut -d':' -f 2 | cut -d'[' -f 1`
    PID=`echo "$CMD" | cut -d'#' -f 2 | cut -d':' -f 2 | cut -d'[' -f 2 | cut -d']' -f 1`
    FFMPEG_CMD=" $FFMPEG_CMD -map $PROGRAM_ID:$STREAM_ID -streamid ${STREAM_CNT}:$PID"
    STREAM_CNT=$((STREAM_CNT + 1))
done

FFMPEG_CMD=" $FFMPEG_CMD -c copy -pes_payload_size 16 ${OUT_FILE}"
echo "ts_rewrap: Executing $FFMPEG_CMD"
`$FFMPEG_CMD`

}

exit 0;

