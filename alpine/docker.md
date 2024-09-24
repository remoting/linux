~~~
sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
apk update && apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && apk del tzdata && rm -rf /var/cache/apk/*
~~~
