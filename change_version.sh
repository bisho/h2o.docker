#!/bin/bash

set -ex

branch=""
tag=""

if [ -z "$1" ]; then
    branch="master"
    VERSION="$branch"
else
    tag="$1"
    VERSION="tags/$tag"
fi

sed -e 's#^\(ENV VERSION \).*#\1 '$VERSION'#' -i Dockerfile

line='- ```'$tag'```'" (*[$tag/Dockerfile](https://github.com/lkwg82/h2o.docker/blob/$tag/Dockerfile)*)"
echo $line >> README.md

git commit -m "changed to version $VERSION" Dockerfile tagged.versions README.md

if [ -n "$tag" ]; then
    git tag --force --annotate $tag -m "released version $tag" HEAD 
fi

git push 
git push --tags --force

exit
function trigger {
    local data=$1
    local endpoint="https://registry.hub.docker.com/u/lkwg82/h2o-http2-server/trigger/ed94f4aa-f3b6-40f0-819c-d72d6789c58e/"
    curl -s -H "Content-Type: application/json" --data "$data" -X POST $endpoint
}

if [ -n "$tag" ]; then
    trigger "{'source_type': 'Tag', 'source_name': '$tag', 'docker_tag': 'latest'}"
else
    trigger "{'build': true, 'docker_tag': 'daily'}"
fi