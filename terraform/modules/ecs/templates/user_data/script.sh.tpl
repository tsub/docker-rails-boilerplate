#!/bin/bash

set -x

sh -c 'cat << EOF > /etc/ecs/ecs.config
ECS_CLUSTER=${cluster}
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","syslog","journald","gelf","fluentd","awslogs"]
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_UPDATES_ENABLED=true
EOF'
