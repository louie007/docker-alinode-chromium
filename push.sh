docker images --format "{{.Repository}}:{{.Tag}}" louisbb/alinode | xargs -L1 docker push
