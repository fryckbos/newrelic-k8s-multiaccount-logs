FROM newrelic/newrelic-fluentbit-output:1.4.2 as newrelic-fluentbit

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y curl gnupg && \
	curl -s https://packages.fluentbit.io/fluentbit.key | apt-key add - && \
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list && \
	echo "deb https://packages.fluentbit.io/ubuntu/bionic bionic main" >> /etc/apt/sources.list && \
	apt-get update && apt-get install -y td-agent-bit kubectl

COPY --from=newrelic-fluentbit /fluent-bit/bin/out_newrelic.so /out_newrelic.so

COPY main.sh /main.sh

CMD [ "/bin/bash", "/main.sh" ]
