#! /usr/bin/env bash

PROJECT='laravel-sample-app'

# Remove any existing database volume files
rm -fr ./volumes

echo '[info]: creating project structure from doppler-template.yaml'
doppler import

echo '[info]: configuring Production infra'
doppler secrets upload --project $PROJECT --config infra_prd <(jq '.infra_prd' sample-config.json) --silent
doppler configs tokens create --project $PROJECT --config prd --plain INFRA | doppler secrets set --project $PROJECT --config infra_prd DOPPLER_TOKEN --silent
openssl rand -base64 16 | doppler secrets set --project $PROJECT --config infra_prd DB_ROOT_PASSWORD --silent
openssl rand -base64 16 | doppler secrets set --project $PROJECT --config infra_prd DB_PASSWORD --silent

echo '[info]: configuring Staging infra'
doppler secrets upload --project $PROJECT --config infra_stg <(jq '.infra_stg' sample-config.json) --silent
doppler configs tokens create --project $PROJECT --config stg --plain INFRA | doppler secrets set --project $PROJECT --config infra_stg DOPPLER_TOKEN --silent
openssl rand -base64 16 | doppler secrets set --project $PROJECT --config infra_stg DB_ROOT_PASSWORD --silent
openssl rand -base64 16 | doppler secrets set --project $PROJECT --config infra_stg DB_PASSWORD --silent

echo '[info]: configuring Production'
doppler secrets upload --project $PROJECT --config prd <(jq '.prd' sample-config.json) --silent
echo "base64:$(openssl rand -base64 32)" | doppler secrets set --project $PROJECT --config prd APP_KEY --silent
echo "base64:$(openssl rand -base64 32)" | doppler secrets set --project $PROJECT --config prd MAIL_PASSWORD --silent
doppler secrets delete --project $PROJECT --config infra $(jq -r '.prd | keys | join(" ")' sample-config.json) -y --silent

echo '[info]: configuring Staging '
doppler secrets upload --project $PROJECT --config stg <(jq '.stg' sample-config.json)  --silent
echo "base64:$(openssl rand -base64 32)" | doppler secrets set --project $PROJECT --config stg APP_KEY --silent
echo "base64:$(openssl rand -base64 32)" | doppler secrets set --project $PROJECT --config stg MAIL_PASSWORD --silent

echo '[info]: configuring Development'
doppler secrets upload --project $PROJECT --config dev <(jq '.dev' sample-config.json) --silent
echo "base64:$(openssl rand -base64 32)" | doppler secrets set --project $PROJECT --config dev APP_KEY --silent
echo "base64:$(openssl rand -base64 32)" | doppler secrets set --project $PROJECT --config dev MAIL_PASSWORD --silent
DEV_DB_ROOT_PASSWORD="$(openssl rand -base64 16)"
doppler secrets set --project $PROJECT --config dev DB_ROOT_PASSWORD "$DEV_DB_ROOT_PASSWORD" --silent
doppler secrets set --project $PROJECT --config dev DB_PASSWORD "$DEV_DB_ROOT_PASSWORD" --silent

echo '[info]: configuring Development infra'
doppler secrets delete --project $PROJECT --config dev_infra $(jq -r '.dev | keys | join(" ")' sample-config.json) -y --silent
doppler secrets upload --project $PROJECT --config dev_infra <(jq '.dev_infra' sample-config.json) --silent
doppler configs tokens create --project $PROJECT --config dev --plain INFRA | doppler secrets set --project $PROJECT --config dev_infra DOPPLER_TOKEN --silent

echo '[info]: Done! Opening Doppler dashboard'
sleep 2
doppler open dashboard
