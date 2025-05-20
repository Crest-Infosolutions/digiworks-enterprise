#!/bin/bash

# ✨ Digiworks Enterprise Initial Setup Script

########################################
# 📁 Configuration
########################################
APS_URL="http://localhost:8080"
ACS_URL="http://alfresco:8080"
APS_ADMIN_USER="admin@app.activiti.com"
APS_ADMIN_PASS="admin"
ACS_ADMIN_USER="admin"
ACS_ADMIN_PASS="admin"
DUMMY_USER="johndoe@crestsolution.com"
DUMMY_PASSWORD="Crest@123"
DYNAMIC_DEFINITION_FILE="/usr/local/bin/Dynamic-Collaboration-Workflow.zip"
CONTRACT_DEFINITION_FILE="/usr/local/bin/ContractManagement.zip"

########################################
# ⏳ Wait for APS & ACS to be available
########################################
echo "🚪 Waiting for APS to start..."
until curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" "$APS_URL/activiti-app/api/enterprise/profile" > /dev/null; do
  sleep 10
done

echo "🚪 Waiting for ACS to start..."
until curl -s -u "$ACS_ADMIN_USER:$ACS_ADMIN_PASS" "$ACS_URL/alfresco/api/-default-/public/authentication/versions/1/tickets" > /dev/null; do
  sleep 10
done

########################################
# 🔍 Check if 'workflow' group exists
########################################
GROUP_RESPONSE=$(curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X GET "$APS_URL/activiti-app/api/enterprise/admin/groups?functional=true&tenantId=1&filter=workflow")
GROUP_ID=$(echo "$GROUP_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)

if [[ -z "$GROUP_RESPONSE" || "$GROUP_RESPONSE" == "[]" || -z "$GROUP_ID" ]]; then
  echo "📆 -- Configuring APS for Digiworks Enterprise --"

  ########################################
  # 👤 Create user
  ########################################
  echo "🏡 Creating APS user..."
  USER_RESPONSE=$(curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/users" \
    -H "Content-Type: application/json" \
    -d '{
      "email": "'$DUMMY_USER'",
      "firstName": "John",
      "lastName": "Doe",
      "status": "active",
      "type": "enterprise",
      "password": "'$DUMMY_PASSWORD'",
      "tenantId": 1
    }')
  USER_ID=$(echo "$USER_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)
  echo "🏡 APS user created with ID: $USER_ID"

  ########################################
  # 🧰 Create group 'workflow' and add user
  ########################################
  echo "📄 Creating group 'workflow'..."
  GROUP_RESPONSE=$(curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/groups" \
    -H "Content-Type: application/json" \
    -d '{"name":"Workflow","tenantId":1,"type":1}')
  GROUP_ID=$(echo "$GROUP_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)
  echo "📄 Group 'workflow' created with ID: $GROUP_ID"

  echo "🪤 Adding user to 'workflow' group..."
  curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/groups/$GROUP_ID/members/$USER_ID" \
    -H "Content-Type: application/json"

  ########################################
  # 📁 Import Dynamic Workflow Definition
  ########################################
  echo "📦 Importing Dynamic Workflow App..."
  APP_DEFINITION_RESPONSE=$(curl -s -X POST "$APS_URL/activiti-app/api/enterprise/app-definitions/import?renewIdmEntries=true" \
    -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" \
    -F "file=@\"$DYNAMIC_DEFINITION_FILE\"")
  APP_ID=$(echo "$APP_DEFINITION_RESPONSE" | grep -o '"id":[0-9]*' | head -n1 | cut -d ':' -f 2)
  echo "🏠 Dynamic Workflow App imported with ID: $APP_ID"

  echo "📢 Publishing Dynamic Workflow App..."
  curl -s -X POST "$APS_URL/activiti-app/api/enterprise/app-definitions/$APP_ID/publish" \
    -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" \
    -H "Content-Type: application/json" \
    -d '{"comment":""}'

  ########################################
  # 📁 Import Contract Workflow Definition
  ########################################
  echo "📦 Importing Contract App..."
  CONTRACT_APP_RESPONSE=$(curl -s -X POST "$APS_URL/activiti-app/api/enterprise/app-definitions/import?renewIdmEntries=true" \
    -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" \
    -F "file=@\"$CONTRACT_DEFINITION_FILE\"")
  APP_ID=$(echo "$CONTRACT_APP_RESPONSE" | grep -o '"id":[0-9]*' | head -n1 | cut -d ':' -f 2)
  echo "📁 Contract App imported with ID: $APP_ID"

  echo "📢 Publishing Contract App..."
  curl -s -X POST "$APS_URL/activiti-app/api/enterprise/app-definitions/$APP_ID/publish" \
    -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" \
    -H "Content-Type: application/json" \
    -d '{"comment":""}'

  ########################################
  # 🔧 Configure Alfresco Repository
  ########################################
  echo "🔧 Configuring Alfresco Repository..."
  ALFRESCO_REPO_RESPONSE=$(curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/integration/alfresco" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "ACS",
      "tenantId": 1,
      "alfrescoTenantId": "-default-",
      "repositoryUrl": "http://alfresco:8080/alfresco",
      "shareUrl": "http://share:8080/share",
      "version": "6.1.1",
      "authenticationType": "basic",
      "sitesFolder": "Sites"
    }')
  ALFRESCO_REPO_ID=$(echo "$ALFRESCO_REPO_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)



  ########################################
  # 🔐 Basic Auth and Endpoint Config
  ########################################
  echo "🔑 Creating Basic Auth for ACS..."
  BASIC_AUTH_RESPONSE=$(curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/basic-auths" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "ACS",
      "username": "admin",
      "password": "admin",
      "tenantId": 1
    }')
  BASIC_AUTH_ID=$(echo "$BASIC_AUTH_RESPONSE" | grep -o '"id":[0-9]*' | cut -d ':' -f 2)

  echo "🔗 Registering DIGISIGN endpoint..."
  curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/endpoints" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "DIGISIGN",
      "protocol": "HTTP",
      "host": "alfresco",
      "port": "8080",
      "path": "alfresco/s/crest/digisign",
      "basicAuthId": '$BASIC_AUTH_ID',
      "tenantId": 1
    }'

  echo "🔗 Registering ACS-OOTB-API endpoint..."
  curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/admin/endpoints" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "ACS-OOTB-API",
      "protocol": "HTTP",
      "host": "alfresco",
      "port": "8080",
      "path": "alfresco",
      "basicAuthId": '$BASIC_AUTH_ID',
      "tenantId": 1
    }'
  echo "🪜 Linking ACS repo for Admin user..."
  curl -s -u "$APS_ADMIN_USER:$APS_ADMIN_PASS" -X POST "$APS_URL/activiti-app/api/enterprise/integration/alfresco/$ALFRESCO_REPO_ID/account" \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "admin"}'

  echo "🪜 Linking ACS repo for dummy user..."
  curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST "$APS_URL/activiti-app/api/enterprise/integration/alfresco/$ALFRESCO_REPO_ID/account" \
    -H "Content-Type: application/json" \
    -d '{"username": "'$DUMMY_USER'", "password": "'$DUMMY_PASSWORD'"}'
else
  echo "❌ Workflow group already exists. Skipping APS configuration."
fi

