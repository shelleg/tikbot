FROM ubuntu:16.04
MAINTAINER Haggai Philip Zagury <hagzag@tikalk.com>

# -----------------------------------------------------------------------------
# Environment variables
# -----------------------------------------------------------------------------
ENV HUBOT_NAME ${HUBOT_NAME:-tikbot}
ENV HUBOT_ADAPTER ${HUBOT_ADAPTER:-slack}
ENV HUBOT_DIR /opt/${HUBOT_NAME}
# Custom secrets expected to be passed to
ENV HUBOT_SLACK_TOKEN false
ENV HUBOT_JENKINS_URL false
ENV HUBOT_JENKINS_AUTH false
ENV HUBOT_AWS_ACCESS_KEY_ID false
ENV HUBOT_AWS_SECRET_ACCESS_KEY false
ENV HUBOT_AWS_REGION false

RUN apt-get update
RUN apt-get -yqq install nodejs npm && \
    apt-get -yqq clean && \
    apt-get -yqq autoclean && \
    apt-get -yqq autoremove && \
    rm -rf /var/lib/apt/* && \
    rm -rf /var/lib/cache/* && \
    rm -rf /var/lib/log/* && \
    rm -rf /tmp/* && \
    ln -s /usr/bin/nodejs /usr/bin/node && \
    npm install -g coffee-script yo generator-hubot

RUN	useradd -d ${HUBOT_DIR} -m -s /bin/bash -U ${HUBOT_NAME}

USER	${HUBOT_NAME}
WORKDIR ${HUBOT_DIR}

RUN yo hubot --owner="Haggai Philip Zagury <hagzag@tikalk.com>" \
             --name="${HUBOT_NAME}" \
             --description="Tikbot the bot that gets things done" \
             --defaults

#COPY ./* ${HUBOT_DIR}/
RUN rm -rf ${HUBOT_DIR}/hubot-scripts.json

# allow custom scripts to be included / overwritten by user
VOLUME ${HUBOT_DIR}/scripts
RUN npm install hubot-slack --save
CMD node -e "console.log(JSON.stringify('$EXTERNAL_SCRIPTS'.split(',')))" > external-scripts.json && \
	npm install $(node -e "console.log('$EXTERNAL_SCRIPTS'.split(',').join(' '))") && \
	bin/hubot -a ${HUBOT_ADAPTER}
