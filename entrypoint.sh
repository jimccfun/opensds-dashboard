#!/bin/sh

# Copyright 2018 The OpenSDS Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

OPENSDS_HOTPOT_URL=${OPENSDS_HOTPOT_URL:-http://127.0.0.1:50040}
OPENSDS_ORCHESTRATION_URL=${OPENSDS_ORCHESTRATION_URL:-http://127.0.0.1:5000}
OPENSDS_GELATO_URL=${OPENSDS_GELATO_URL:-http://127.0.0.1:8089}
OPENSDS_AUTH_URL=${OPENSDS_AUTH_URL:-http://127.0.0.1/identity}

OPENSDS_HOTPOT_API_VERSION=${OPENSDS_HOTPOT_API_VERSION:-v1beta}
OPENSDS_ORCHESTRATION_API_VERSION=${OPENSDS_ORCHESTRATION_API_VERSION:-orch}
OPENSDS_GELATO_API_VERSION=${OPENSDS_GELATO_API_VERSION:-v1}
OPENSDS_AUTH_API_VERSION=${OPENSDS_AUTH_API_VERSION:-v3}

LISTEN_PORT=${LISTEN_PORT:-8088}
cat > /etc/nginx/conf.d/default.conf <<EOF
    server {
        listen ${LISTEN_PORT} default_server;
        listen [::]:${LISTEN_PORT} default_server;
        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;
        server_name _;
        location /${OPENSDS_AUTH_API_VERSION}/ {
            proxy_pass ${OPENSDS_AUTH_URL}/${OPENSDS_AUTH_API_VERSION}/;
        }

        location /${OPENSDS_HOTPOT_API_VERSION}/ {
            proxy_pass ${OPENSDS_HOTPOT_URL}/${OPENSDS_HOTPOT_API_VERSION}/;
        }

        location /${OPENSDS_ORCHESTRATION_API_VERSION}/ {
            proxy_pass ${OPENSDS_ORCHESTRATION_URL}/${OPENSDS_HOTPOT_API_VERSION}/;
        }

        location /${OPENSDS_GELATO_API_VERSION}/ {
            proxy_pass ${OPENSDS_GELATO_URL}/${OPENSDS_GELATO_API_VERSION}/;
            client_max_body_size 10240m;
        }
    }
EOF

# print some log to stdin
echo "Service Start Time $(date)"
echo "Configuration /etc/nginx/conf.d/default.conf"
cat /etc/nginx/conf.d/default.conf

# start nginx service
/usr/sbin/nginx -g "daemon off;"

