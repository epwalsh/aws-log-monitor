# aws-log-monitor

This is an AWS Lambda function that monitors CloudWatch Log Streams for patterns,
and sends Slack notifications to the channel `#logs` when the pattern is found.

> The choice of Slack as a destination is arbitrary and could easily be changed
to something else, such as email.

By default, the key pattern is the term `ERROR`, so whenever that term occurs in a log stream being monitored, this information will be sent to Slack.

## Quick start in 5 minutes or less (OS X or Linux)

**1.** Make sure you have the base requirements.

Make sure you have Python 3, `pip`, `awscli`, `virtualenv`, and `virtualenvwrapper`
installed. If you already Python 3 and pip, just run the following:

```bash
pip install -r requirements.txt
```

If you've never used the AWS CLI before, see 
[Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

**2.** Run the bootstraping script.

Run `./bootstrap.sh`.

**3.** Setup a Slack bot.

If you don't have one already, see
[Create a bot for your workspace](https://get.slack.help/hc/en-us/articles/115005265703-Create-a-bot-for-your-workspace).

Once the bot user has been created, grab the API token from the bot settings
page and add it as an environment variable to the Lambda function through the
AWS Lambda console like so:

# TODO: screen shot of this on lambda

The last thing you need to do in order for the Lambda function to be able to 
deliver messages to Slack is to setup a Slack channel and invite the bot you
just created to the channel. You can do this all through the Slack dashboard or
application. By default, the Lambda function assumes the channel name is "logs",
but you can change that by setting the environment variable `TARGET_SLACK_CHANNEL`.

**4.** Setup a log group to monitor.

The Lambda function should now be deployed to AWS, but we will need to tell 
the Lambda function to start monitoring some log groups. We'll show how to set
up a log group here for testing.


## Adding new log groups to monitor

For example, to add the log group `/aws/test-group`, just run the following:

```
make add-log-group log-group=/aws/test-group id=test-group
```

## Sending test events

To send a test event with the message "ERROR" into the log stream "test-stream" 
in the log group "/aws/test-group", run the following:

```
make test log-group=/aws/test-group message="ERROR" log-stream=test-stream
```

## Removing log groups or other triggers

This has to be done manually from the AWS console: 

# TODO: screen shot
