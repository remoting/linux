

docker run -d --restart=always --name mysql57 \
    -p 3306:3306 \
    -v /data/mysql/conf:/etc/mysql/conf.d \
    -v /data/mysql/data:/var/lib/mysql \
    -e "MYSQL_ROOT_PASSWORD=123456" \
   mysql:5.7

docker run -d --restart=always --name kong-database \
    -p 5432:5432 \
    -e "POSTGRES_USER=kong" \
    -e "POSTGRES_DB=kong" \
    -e "POSTGRES_PASSWORD=kong" \
    -v /data/postgresql/data:/var/lib/postgresql/data \
    postgres:9.5

docker run --rm \
    --link kong-database:kong-database \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=kong" \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=kong-database" \
    kong:0.13.1 kong migrations up

docker run -d --restart=always --name kong \
    --link kong-database:kong-database \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=kong-database" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=kong" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_PROXY_LISTEN=0.0.0.0:80" \
    -e "KONG_PROXY_LISTEN_SSL=0.0.0.0:443" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
    -e "KONG_ADMIN_LISTEN_SSL=0.0.0.0:8443" \
    -e "KONG_CUSTOM_PLUGINS=cmp-auth" \
    -v /root/cmp-auth:/usr/local/share/lua/5.1/kong/plugins/cmp-auth \
    -p 80:80 \
    -p 443:443 \
    -p 8001:8001 \
    -p 8443:8443 \
    kong:0.13.1

docker run -d --restart=always -p 1337:1337 \
    --link kong:kong \
    --link kong-database:kong-database \
    -e "DB_ADAPTER=postgres" \
    -e "DB_HOST=kong-database" \
    -e "DB_USER=kong" \
    -e "DB_PASSWORD=kong" \
    -e "NODE_ENV=development" \
    --name konga \
    pantsel/konga:0.11.2