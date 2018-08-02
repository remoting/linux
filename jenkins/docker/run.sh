#!/bin/bash

JENKINS_HOME=${1:-"/var/jenkins_home"}
JENKINS_USER_PROFILE="$JENKINS_HOME/.bashrc"
JENKINS_CI_TOOLS="$JENKINS_HOME/ci-tools"
JENKINS_CI_PROFILE="$JENKINS_HOME/.ciconfig"

add_citools_path(){
  local cipath="$JENKINS_HOME/bin"

  # 发现ci tools
  for i in `ls $JENKINS_CI_TOOLS/*.tar.gz`;do
    echo "==> find tools: $i";tool=$(basename $i .tar.gz)
    if [ ! -d $JENKINS_CI_TOOLS/$tool ];then
      echo "==> add tools: $tool";tar zxf $JENKINS_CI_TOOLS/$tool.tar.gz -C $JENKINS_CI_TOOLS/
    fi
  done

  # 加入path
  ls $JENKINS_CI_TOOLS/|grep -v tar.gz
  for i in `ls $JENKINS_CI_TOOLS/|grep -v tar.gz`;do
    tool=$JENKINS_CI_TOOLS/$i
    if [ -d  $tool ];then
      echo "==> load tools to path: $i"; cipath=$tool/bin:$cipath
    fi
  done
  export PATH=$cipath:$PATH
  echo "export PATH=$cipath:\$PATH" > $JENKINS_CI_PROFILE;echo $PATH

  # 加载配置
  if [ ! -e $JENKINS_USER_PROFILE ] || [ "$(cat $JENKINS_USER_PROFILE|grep JENKINS_CI_PROFILE)" == "" ];then
    echo "source $JENKINS_CI_PROFILE"
    echo "source $JENKINS_CI_PROFILE #JENKINS_CI_PROFILE" >> $JENKINS_USER_PROFILE
  fi
}

mkdir -p $JENKINS_CI_TOOLS;add_citools_path;/usr/local/bin/jenkins.sh $@