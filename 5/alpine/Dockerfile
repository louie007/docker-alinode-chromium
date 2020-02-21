FROM alpine:3.9.4

# 环境变量
ENV ALINODE_VERSION=5.13.0 \
    NODE_VERSION=12.13.0 \
    YARN_VERSION=1.15.1 \
    ENABLE_NODE_LOG=YES \
    NODE_LOG_DIR=/tmp \
    ALINODE_CONFIG=alinode.config.json \
    NODE_ENV=production \
    HOME=/home/node \
    APP_DIR=/home/node/app

# 从官网镜像中复制 alinode 包含了 agenthub 无需安装
COPY --from=registry.cn-hangzhou.aliyuncs.com/aliyun-node/alinode:5.13.0-alpine /usr/local /usr/local

# 添加账号，安装 依赖，运维工具，yarn pm2
RUN addgroup -g 1000 node \
  && adduser -u 1000 -G node -s /bin/sh -D node \
  && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk add -U tzdata \
  && apk add --no-cache libstdc++ ca-certificates curl \
  && apk add --no-cache --virtual .build-deps-yarn gnupg \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && rm -rf /usr/local/bin/yarn* \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && ENABLE_NODE_LOG=NO yarn config set registry https://registry.npm.taobao.org \
  && ENABLE_NODE_LOG=NO yarn config set disturl https://npm.taobao.org/dist \
  && ENABLE_NODE_LOG=NO yarn global add pm2 \
  && ENABLE_NODE_LOG=NO yarn cache clean --force \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && apk del tzdata \
  && apk del .build-deps-yarn \
  && rm -rf /tmp/*

# 设置默认用户
USER node

# 复制初始化脚本
COPY --chown=node default.config.js start-agenthub.sh $HOME/

# 入口脚本
ENTRYPOINT ["/home/node/start-agenthub.sh"]

# 工作目录
RUN mkdir -p /home/node/app
WORKDIR /home/node/app

# 默认启动命令
CMD ["pm2-runtime", "start", "ecosystem.config.js"]
