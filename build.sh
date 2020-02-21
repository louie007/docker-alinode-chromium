#!/bin/bash

# 例子
# sh build.sh 3-alpine 3.13-alpine 3.13.0-alpine

set -e

# 输入参数
tag=${1:-3}

# 版本
version=${tag/-*/}
# 版本标签
tagname=${tag/*-/}

# 对应目录
dir="$version/$tagname"

# 如果没标签，默认 jessie 版本
if [ "$version" = "$tagname" ]; then
  dir="$version/jessie"
fi

# 判断目录是否存在
if [ ! -d $dir ]; then
  echo "no such tag: $tag"
  exit -1
fi

# 构建镜像
docker build -f $dir/Dockerfile -t louisbb/alinode-chromium:$tag context

echo
echo "✨ louisbb/alinode-chromium:$tag is done!"
echo

if [ $# -gt 1 ]; then
  for ((i=2; i<=$#; i++)); do
    echo "Create tag $tag -> ${!i}"
    docker tag louisbb/alinode-chromium:$tag louisbb/alinode-chromium:${!i}
  done
fi

echo

if [ "$version" = "$tagname" ]; then
  docker images louisbb/alinode-chromium:$tag*
else
  docker images louisbb/alinode-chromium:$version*-$tagname
fi

echo
docker run --rm louisbb/alinode-chromium:$tag sh -c 'echo "alinode v$ALINODE_VERSION" && echo "node $(node -v)" && echo "npm v$(npm -v)" && echo "yarn v$(yarn -v)" && echo "pm2 v$(pm2 -v)"'
echo
