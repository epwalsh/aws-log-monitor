# aws-log-monitor

This is an AWS Lambda function that monitors CloudWatch Log Streams for patterns,
and sends Slack notifications to the channel `#logs` when the pattern is found.

> The choice of Slack as a destination is arbitrary and could easily be changed
to something else, such as email.

By default, the key pattern is the term `ERROR`, so whenever that term occurs in a log stream being monitored, this information will be sent to Slack.

## Requirements (for OS X or Linux)

Make sure you have Python 3, `pip`, `awscli`, `virtualenv`, and `virtualenvwrapper`
installed. If you already Python 3 and pip, just run the following:

```bash
pip install -r requirements.txt
```

If you've never used the AWS CLI before, see 
[Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
TLDR: you'll need to have IAM user with programmatic access setup. Then you need to create two
files `~/.aws/config` and `~/.aws/credentials`.

`~/.aws/config` will look something like this:

```
[default]
region=us-west-2
```

And `~/.aws/credentials` will look something like this:

```
[default]
aws_access_key_id = *****
aws_secret_access_key = *****
```

## Quick start in 5 minutes or less (OS X or Linux)

**1. Run the bootstraping script.**

Run `./bootstrap.sh`. This will:

- Create a Python 3 virtualenv called `log-monitor`.
- Install the application requirements (`./lambda/requirements.txt`) to that virtualenv.
- Create a symbolic link `./lambda/packages` to the site-packages directory of that virtualenv,
  so that all of the dependencies can be bundled together in the deployment package.
- Create an IAM policy that gives the lambda function certain permissions.
- Create a role for the Lambda function to use, and attach the policy to that role.
- Build a deployment package.
- Create a Lambda function on AWS with the role attached and upload the deployment package.

**2. Setup a Slack bot.**

If you don't have one already, see
[Create a bot for your workspace](https://get.slack.help/hc/en-us/articles/115005265703-Create-a-bot-for-your-workspace).

Once the bot user has been created, grab the API token from the bot settings
page and add it as an environment variable to the Lambda function through the
AWS Lambda console like so:

![environment.png](https://github.com/epwalsh/aws-log-monitor/blob/master/.figures/environment.png)

The last thing you need to do in order for the Lambda function to be able to 
deliver messages to Slack is to setup a Slack channel and invite the bot you
just created to the channel. You can do this all through the Slack dashboard or
application. By default, the Lambda function assumes the channel name is "logs",
but you can change that by setting the environment variable `TARGET_SLACK_CHANNEL`.

**3. Setup a log group to monitor.**

The Lambda function should now be deployed to AWS, but we will need to point it to at least one 
log group to verify that it works. We'll just set up a dummy log group here for testing.

Navigate the AWS CloudWatch console, click on "Logs" on the left panel and then
"Create log group", and enter the name "test-group" as shown here:

![log-group.png](https://github.com/epwalsh/aws-log-monitor/blob/master/.figures/log-group.png)

Then create a new log stream within the log group called "test-stream":

![log-group.png](https://github.com/epwalsh/aws-log-monitor/blob/master/.figures/test-stream.png)

Lastly, to get the Lambda function to start monitoring the new log group we just created,
we run the following:

```
make add-log-group log-group=/aws/test-group id=test-group
```

That's it! You can now send a fake error message into the log stream to test if it works:

```
make test log-group=/aws/test-group message="ERROR" log-stream=test-stream
```
