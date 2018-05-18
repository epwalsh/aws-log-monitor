#!/usr/bin/env bash
# Adds a CloudWatch log group for the Lambda function to monitor.

aws lambda add-permission \
    --function-name "log-monitor" \
    --statement-id "log-monitor-$LOG_GROUP_ID" \
    --principal "logs.us-west-2.amazonaws.com" \
    --action "lambda:InvokeFunction" \
    --source-arn "arn:aws:logs:$AWS_REGION:$AWS_ACCOUNT:log-group:$LOG_GROUP:*" \
    --source-account "$AWS_ACCOUNT"

aws logs put-subscription-filter \
    --log-group-name "$LOG_GROUP" \
    --filter-name "error" \
    --filter-pattern "ERROR" \
    --destination-arn "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT:function:log-monitor"
