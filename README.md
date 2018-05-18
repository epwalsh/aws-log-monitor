# aws-log-monitor

This is an AWS Lambda function that monitors CloudWatch Log Streams for patterns,
and sends Slack notifications to a channel when the pattern is found.

> The choice of Slack as a destination is arbitrary and could easily be changed
to something else, such as email.

By default, the key term is `ERROR`.
So whenever `ERROR` occurs in a log stream being monitored, this information will be sent to Slack.

## Requirements (OS X or Linux)

Make sure you have Python 3, `pip`, `awscli`, `virtualenv`, and `virtualenvwrapper`
installed. If you already Python 3 and pip, just run the following:

```bash
pip install -r requirements.txt
```

If you've never used the AWS CLI before, see
[Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
TLDR: you'll need to have an IAM user with programmatic access setup. Then you need to create two
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

## Quick start in 5 minutes or less (OS X or Linux) :+1: :ok_hand: :+1: :ok_hand: :raised_hands: :clap:

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

**2. Set up a Slack bot user.** :space_invader:

If you don't have one already, see
[Create a bot for your workspace](https://get.slack.help/hc/en-us/articles/115005265703-Create-a-bot-for-your-workspace).

Once the bot user has been created, grab the API token from the bot settings
page and add it as an environment variable to the Lambda function through the
AWS Lambda console like so:

![environment.png](https://github.com/epwalsh/aws-log-monitor/blob/master/.figures/environment.png)

The last thing you need to do in order for the Lambda function to be able to
deliver messages to Slack is to create a Slack channel and invite the bot user
to that channel. You can do this through the Slack dashboard or
application. By default, the Lambda function assumes the channel name is "logs",
but you can change that by setting the environment variable `TARGET_SLACK_CHANNEL`
in the same way that you just set the API token environment variable above.

**3. Set up a log group to monitor.**

The Lambda function should now be deployed to AWS, but we will need to point it to at least one
log group to verify that it works. We'll just create a dummy log group here for testing.

Navigate the AWS CloudWatch console, click on "Logs" on the left panel and then
"Create log group", and enter the name "test-group" as shown here:

![log-group.png](https://github.com/epwalsh/aws-log-monitor/blob/master/.figures/log-group.png)

Then create a new log stream within the log group called "test-stream":

![log-group.png](https://github.com/epwalsh/aws-log-monitor/blob/master/.figures/log-stream.png)

Lastly, to get the Lambda function to start monitoring the new log group we just created,
run the following `make` command:

```
make add-log-group log-group=/aws/test-group id=test-group
```

That's it! You can now send a fake error message into the log stream to test if it works:

```
make test log-group=/aws/test-group message="ERROR" log-stream=test-stream
```

Happy logging! :sunglasses:
