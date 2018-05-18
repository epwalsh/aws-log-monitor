#!/usr/bin/env bash
# Put a log event.

SEQ_TOKEN=`aws logs describe-log-streams \
    --log-group-name $LOG_GROUP \
    --log-stream-name-prefix $LOG_STREAM | grep "uploadSequenceToken" | sed "s/[^0-9]\+//g"`

aws logs put-log-events \
    --log-group-name $LOG_GROUP \
    --log-stream-name $LOG_STREAM \
    --log-events "[{\"timestamp\": `gdate +%s%3N`, \"message\": \"$LOG_MESSAGE\"}]" \
    --sequence-token $SEQ_TOKEN
