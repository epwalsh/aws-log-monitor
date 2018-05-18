log-group  = /aws/test-group
log-stream = test-stream
message    = ERROR (this is a test)

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
	@cd scripts && \
		./02_permissions.sh $(id) $(log-group) && \
		./03_subscription_filter.sh $(log-group)

.PHONY : test
test :
	@cd scripts && \
		./put_event.sh "$(log-group)" "$(message)" "$(log-stream)"

.PHONY : clean
clean :
	rm -f *.zip
