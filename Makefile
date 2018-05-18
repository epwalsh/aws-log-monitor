log-group  = "/aws/test-group"
log-stream = "test-stream"
message    = "ERROR (this is a test)"

SRCS := $(wildcard lambda/*.py)


deployment.zip : $(SRCS)
	@cd lambda && zip -r ../deployment.zip *

.PHONY : deploy
deploy : deployment.zip
	aws lambda update-function-code \
		--function-name "log-monitor" \
		--zip-file fileb://./deployment.zip

.PHONY : add-log-group
add-log-group :
	AWS_ACCOUNT=$(account) \
		LOG_GROUP=$(log-group) \
		LOG_GROUP_ID=$(id) \
		AWS_REGION=$(region) \
		./add_log_group.sh

.PHONY : test
test :
	LOG_GROUP=$(log-group) \
		LOG_STREAM=$(log-stream) \
		LOG_MESSAGE=$(message) \
		./put_event.sh

.PHONY : clean
clean :
	rm -f *.zip
