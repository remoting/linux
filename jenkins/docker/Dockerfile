FROM jenkins/jenkins:lts
USER root
RUN /bin/cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


RUN export http_proxy="http://10.1.30.95:8088" && apt-get update && \
apt-get install -y apt-transport-https ca-certificates wget software-properties-common && \
wget https://download.docker.com/linux/debian/gpg && \
apt-key add gpg && \
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list && \
apt-get update && apt-get install -y docker-ce

#ADD apache-maven-3.3.9-bin.tar.gz /usr/local/
#ADD gradle-3.5.tar.gz /usr/local/
#ENV MAVEN_HOME /usr/local/apache-maven-3.3.9
#ENV GRADLE_HOME /usr/local/gradle-3.5
#ENV PATH "$PATH:$MAVEN_HOME/bin:$GRADLE_HOME/bin"

#ADD docker /usr/bin/docker

USER jenkins

RUN mkdir -p $JENKINS_HOME/.m2 \
    && rm -rf ~/.m2 \
    && ln -s $JENKINS_HOME/.m2 ~/.m2

ADD run.sh /opt/run.sh
ENTRYPOINT ["/sbin/tini", "--", "/opt/run.sh"]