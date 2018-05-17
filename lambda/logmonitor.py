#!/usr/bin/env python

"""
Defines Lambda handler function.
"""

import base64
import os
import sys; sys.path.append('./packages/')  # noqa: E702
import zlib

from slacker import Slacker


SLACK_TOKEN = os.environ["SLACK_API_TOKEN"]
SLACK_CHANNEL = "#" + os.environ["TARGET_SLACK_CHANNEL"]

slack = Slacker(SLACK_TOKEN)


def url_builder(log_group, log_stream):
    url = "https://us-west-2.console.aws.amazon.com/cloudwatch/home?"\
        "region=us-west-2#logEventViewer:group={};stream={}"\
        .format(log_group, log_stream)
    return url


def format_message(log_event, log_group, log_stream):
    return "\n".join([
        '> Log Group: "{}"'.format(log_group),
        '> Log Stream: "{}"'.format(log_stream),
        '> Message: "{}"'.format(log_event["message"]),
        '> Timestamp: {}'.format(log_event["timestamp"]),
        '{}'.format(url_builder(log_group, log_stream)),
    ])


def handler(event, context):
    log_data_str = \
        zlib.decompress(base64.b64decode(event["awslogs"]["data"]), 24)
    log_data = eval(log_data_str)
    for item in log_data['logEvents']:
        message = \
            format_message(item, log_data["logGroup"], log_data["logStream"])
        slack.chat.post_message(SLACK_CHANNEL, message, as_user=True)
