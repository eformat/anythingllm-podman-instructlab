#!/bin/bash

export STORAGE_LOCATION=$HOME/tmp/anythingllm

CMD=$1

if [ -z "${CMD}" ] || [ "${CMD}" == "start" ]; then

  podman run -d --name ilab --userns keep-id --annotation run.oci.keep_original_groups=1 --name ilab --rm -it --entrypoint=bash  --device nvidia.com/gpu=0 --security-opt label=type:nvidia_container_t -v /home/mike/instructlab:/opt/app-root/src/instructlab -v /home/mike/.cache/huggingface:/opt/app-root/src/.cache/huggingface --net=host quay.io/eformat/ilab-mike:latest

  podman exec ilab /bin/bash -c "cd instructlab; ilab serve &"

  podman run -d --name anythingllm --rm -it anythingllm \
   -v ${STORAGE_LOCATION}:/app/server/storage:z \
   -v ${STORAGE_LOCATION}/.env:/app/server/.env:z \
   -e STORAGE_DIR="/app/server/storage" \
   --net=host \
   mintplexlabs/anythingllm
fi

if [ "${CMD}" == "stop" ]; then
    podman stop ilab
    podman stop anythingllm
fi
