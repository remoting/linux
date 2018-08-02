docker build -t jenkins:yh-2 .

wget https://nodejs.org/dist/latest-v6.x/node-v6.14.2-linux-x64.tar.gz
wget http://mirrors.hust.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
wget https://downloads.gradle.org/distributions/gradle-4.5.1-bin.zip

cp node-v6.14.2-linux-x64.tar.gz /data/jenkins_home/ci-tools/
cp gradle-4.5.1.tar.gz /data/jenkins_home/ci-tools/
 