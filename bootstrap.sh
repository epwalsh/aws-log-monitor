#!/usr/bin/env bash
# ==============================================================================
# This script bootstraps the setup process for the Lambda function:
#
#  1. Creates a Python 3 virtualenv `log-monitor`.
#  2. Installs the right packages and creates a symbolic link from ./lambda/packages/ 
#     to the site-packages directory of the virtualenv.
#  3. Creates an IAM policy with the right permissions for the Lambda function.
#  4. Creates an IAM role for the Lambda function and attaches the policy.
#  5. Creates a deployment package and then uploads it into the new Lambda function
#     called `log-monitor`.
# ==============================================================================

echo "Creating virtualenv log-monitor"
source /usr/local/bin/virtualenvwrapper.sh
which python3 | mkvirtualenv log-monitor -p
workon log-monitor

echo "Installing requirements"
cd lambda
pip install -r requirements.txt

echo "Creating site-packages symbolic link"
ln -s `python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"` packages
deactivate
cd -

echo "Creating IAM policy called log-monitor-policy"
policy_arn=$(aws iam create-policy \
    --policy-name log-monitor-policy \
    --policy-document file://policy.json | \
    grep "Arn" | \
    sed -E 's/.*Arn\": \"([^"]+)\".*/\1/')

echo "Created policy $policy_arn"

echo "Creating IAM role called log-monitor-role"
role_arn=$(aws iam create-role \
    --role-name log-monitor-role \
    --assume-role-policy-document file://role.json | \
    grep "Arn" | \
    sed -E 's/.*Arn\": \"([^"]+)\".*/\1/')

echo "Created role $role_arn"

echo "Attaching policy to role"
aws iam attach-role-policy \
    --role-name log-monitor-role \
    --policy-arn $policy_arn

echo "Building Lambda deployment package"
find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf
cd lambda
zip -r ../deployment.zip *
cd -

echo "Waiting for role to be registered"
sleep 5

echo "Creating Lambda function log-monitor"
aws lambda create-function \
    --function-name log-monitor \
    --zip-file fileb://deployment.zip \
    --role $role_arn \
    --runtime "python3.6" \
    --handler "logmonitor.handler" \
    --timeout 10 \
    --memory-size 128
