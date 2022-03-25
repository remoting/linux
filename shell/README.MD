# 安装zsh

```
yum install -y zsh
 

git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

yum install -y util-linux-user
chsh -s zsh

```

---
# 配置bash

```
cd ~

curl -L -o .bashrc https://raw.github.com/remoting/linux/master/.bashrc

source .bashrc
```
