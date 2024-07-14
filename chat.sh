#!/bin/bash

export STORAGE_LOCATION=$HOME/tmp/anythingllm

CMD=$1

if [ -z "${CMD}" ] || [ "${CMD}" == "start" ]; then

  podman pod create --name=chat --userns keep-id --share net -p 3001:3001 -p 8000:8000

  podman create --name ilab --pod=chat --annotation run.oci.keep_original_groups=1 --name ilab --rm -it --entrypoint=bash --device nvidia.com/gpu=0 --security-opt label=type:nvidia_container_t -v /home/mike/instructlab:/opt/app-root/src/instructlab:z -v /home/mike/.cache/huggingface:/opt/app-root/src/.cache/huggingface:z -v /home/mike/.local:/opt/app-root/src/.local:z quay.io/eformat/ilab-mike:latest

  podman create --name anythingllm --pod=chat --rm -it anythingllm \
   -v ${STORAGE_LOCATION}:/app/server/storage:z \
   -v ${STORAGE_LOCATION}/.env:/app/server/.env:z \
   -e STORAGE_DIR="/app/server/storage" \
   mintplexlabs/anythingllm

  podman start ilab
  podman start anythingllm

  podman wait --condition=running ilab 1>/dev/null
  podman exec -d ilab /bin/bash -c "set -x; cd instructlab; nohup ilab serve"

  echo; echo ">>> Browse to http://localhost:3001"  
fi

if [ "${CMD}" == "stop" ]; then
    podman pod stop chat
    podman pod rm chat
fi

