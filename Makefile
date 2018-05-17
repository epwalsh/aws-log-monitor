log-group      = /aws/test-group
log-stream     = test-stream
message        = ERROR (this is a test)
site-packages := `python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`


.PHONY : build
build :
	@cd lambda && zip -r ../deployment.zip *

.PHONY : setup
setup :
	workon logmonitor
	cd lambda && \
		pip install -r requirements.txt && \
		ln -s $(site-packages) packages

.PHONY : push
push :
	aws lambda update-function-code \
		--function-name "logmonitor" \
		--zip-file fileb://./deployment.zip

.PHONY : deploy
deploy : build push

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
	rm -f ./lambda/packages
	rm -f *.zip
