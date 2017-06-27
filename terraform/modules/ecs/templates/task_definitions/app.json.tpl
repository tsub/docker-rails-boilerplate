[
    {
        "name": "app",
        "image": "tsub/docker-rails-boilerplate",
        "command": [
            "bundle",
            "exec",
            "puma",
            "--config",
            "config/puma.rb",
            "--environment",
            "production"
        ],
        "memoryReservation": 256,
        "essential": true,
        "environment": [
            {
                "name": "RAILS_ENV",
                "value": "production"
            },
            {
                "name": "RAILS_MASTER_KEY",
                "value": "${rails_master_key}"
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/app/${cluster}",
                "awslogs-region": "${region}",
                "awslogs-stream-prefix": "${cluster}"
            }
        },
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 0
            }
        ]
    }
]
