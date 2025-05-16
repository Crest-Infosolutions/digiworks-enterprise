#!/bin/bash

APS_URL="http://localhost:8080"
ADMIN_USER="admin@app.activiti.com"
ADMIN_PASS="admin"
DUMMY_USER="johndoe@crestsolution.com"
DUMMY_PASSWORD="Crest@123"
DYNAMIC_DEFINITION_FILE="/usr/local/bin/Dynamic-Collaboration-Workflow.zip"
CONTRACT_DEFINITION_FILE="/usr/local/bin/ContractManagement.zip"


# Wait until APS is ready
until curl -s -u "$ADMIN_USER:$ADMIN_PASS" "$APS_URL/activiti-app/api/enterprise/profile" > /dev/null; do
  echo "Waiting for APS to start..."
  sleep 10
done

echo "Creating APS user..."

USER_RESPONSE=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/users" \
  -H "Content-Type: application/json" \
  -d '{
    "email": '\"$DUMMY_USER\"',
    "firstName": "John",
    "lastName": "Doe",
    "status": "active",
    "type": "enterprise",
    "password": '\"$DUMMY_PASSWORD\"',
    "tenantId": 1
}')

USER_ID=$(echo "$USER_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)

echo "APS user created with ID: $USER_ID"

echo "Creating group 'workflow'..."

GROUP_RESPONSE=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/groups" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Workflow","tenantId":1,"type":1
}')

GROUP_ID=$(echo "$GROUP_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)

echo "Group 'workflow' created with ID: $GROUP_ID"

echo "Adding user to 'workflow' group..."

curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/groups/$GROUP_ID/members/$USER_ID" \
  -H "Content-Type: application/json" 

echo "Importing app definition from ZIP file..."

APP_DEFINITION_RESPONSE=$(curl -s -X POST "$APS_URL/activiti-app/api/enterprise/app-definitions/import?renewIdmEntries=true" \
  -u "$ADMIN_USER:$ADMIN_PASS" \
  -F "file=@\"$DYNAMIC_DEFINITION_FILE\"")

echo "App definition imported successfully."

APP_ID=$(echo "$APP_DEFINITION_RESPONSE" | grep -o '"id":[0-9]*' | head -n1 | cut -d ':' -f 2)


echo "Dynamic workflow definition imported successfully with ID: $APP_ID"

echo "Publishing Dynamic workflow app definition with ID: $APP_ID..."

curl -s -X POST "$APS_URL/activiti-app/api/enterprise/app-definitions/$APP_ID/publish" \
  -u "$ADMIN_USER:$ADMIN_PASS" \
  -H "Content-Type: application/json" \
  -d '{"comment":""}'

echo "Dynamic workflow App definition published successfully."


CONTRACT_APP_DEFINITION_RESPONSE=$(curl -s -X POST "$APS_URL/activiti-app/api/enterprise/app-definitions/import?renewIdmEntries=true" \
  -u "$ADMIN_USER:$ADMIN_PASS" \
  -F "file=@\"$CONTRACT_DEFINITION_FILE\"")

echo "Contract APP definition imported successfully."

APP_ID=$(echo "$CONTRACT_APP_DEFINITION_RESPONSE" | grep -o '"id":[0-9]*' | head -n1 | cut -d ':' -f 2)


echo "Contract APP definition imported successfully with ID: $APP_ID"

echo "Publishing Contract app definition with ID: $APP_ID..."

curl -s -X POST "$APS_URL/activiti-app/api/enterprise/app-definitions/$APP_ID/publish" \
  -u "$ADMIN_USER:$ADMIN_PASS" \
  -H "Content-Type: application/json" \
  -d '{"comment":""}'

echo "Dynamic workflow App definition published successfully."



echo "Configuring Alfresco REPO'..."

ALFRESCO_REPO_RESPONSE=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/integration/alfresco" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ACS",
    "tenantId": 1,
    "alfrescoTenantId": "-default-",
    "repositoryUrl": "http://alfresco:8080/alfresco",
    "shareUrl": "http://share:8080/share",
    "secret": null,
    "version": "6.1.1",
    "authenticationType": "basic",
    "sitesFolder": "Sites"
}')

ALFRESCO_REPO_ID=$(echo "$ALFRESCO_REPO_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)

echo "Alfresco REPO Configured with ID: $ALFRESCO_REPO_ID"

sleep 10
echo "Configuring Alfresco REPO for Admin'..."
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/integration/alfresco/$ALFRESCO_REPO_ID/account" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin"
}'

echo "Configured Alfresco REPO for Admin'"


echo "Configuring Alfresco REPO for $DUMMY_USER'..."
curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST "$APS_URL/activiti-app/api/enterprise/integration/alfresco/$ALFRESCO_REPO_ID/account" \
  -H "Content-Type: application/json" \
  -d '{
    "username": '\"$DUMMY_USER\"',
    "password": '\"$DUMMY_PASSWORD\"'
}'

echo "Configured Alfresco REPO for $DUMMY_USER"


echo "Configuring Basic auth'..."

BASIC_AUTH_RESPONSE=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/basic-auths" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ACS",
    "username": "admin",
    "password": "admin",
    "tenantId": 1
}')

BASIC_AUTH_ID=$(echo "$BASIC_AUTH_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)

echo "BASIC AUTH Configured with ID: $BASIC_AUTH_ID"


echo "Configuring Digisign URL'..."

BASIC_AUTH_RESPONSE=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/endpoints" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "DIGISIGN",
    "protocol": "HTTP",
    "host": "alfresco",
    "port": "8080",
    "path": "alfresco/s/crest/digisign",
    "basicAuthId": '$BASIC_AUTH_ID',
    "basicAuthName": "",
    "requestHeaders": [],
    "tenantId": 1
}')

BASIC_AUTH_ID=$(echo "$BASIC_AUTH_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)

echo "Digisign URL Configured with ID: $BASIC_AUTH_ID"

echo "Configuring ACS-OOTB-API URL'..."

BASIC_AUTH_RESPONSE=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/endpoints" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ACS-OOTB-API",
    "protocol": "HTTP",
    "host": "alfresco",
    "port": "8080",
    "path": "alfresco",
    "basicAuthId": '$BASIC_AUTH_ID',
    "basicAuthName": "",
    "requestHeaders": [],
    "tenantId": 1
}')

BASIC_AUTH_ID=$(echo "$BASIC_AUTH_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)

echo "ACS-OOTB-API URL Configured with ID: $BASIC_AUTH_ID"