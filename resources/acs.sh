#!/bin/bash

ALFRESCO_URL="http://localhost:8080"
ADMIN_USER="admin"
ADMIN_PASS="admin"
DUMMY_USER="johndoe@crestsolution.com"
DUMMY_PASSWORD="Crest@123"
CORPORATE_FILE_TO_UPLOAD="/Users/kumarsaikat/code/Demo/digiworks-enterprise/resources/corporate-contract.docx"  # <-- Replace this with your actual file path
CORPORATE_FILENAME="corporate-contract.docx"
LEGAL_FILE_TO_UPLOAD="/Users/kumarsaikat/code/Demo/digiworks-enterprise/resources/legal-contract.docx"  # <-- Replace this with your actual file path
LEGAL_FILENAME="legal-contract.docx"


# Wait for Alfresco to start
until curl -s -u "$ADMIN_USER:$ADMIN_PASS" "$ALFRESCO_URL/alfresco/api/-default-/public/authentication/versions/1/tickets" > /dev/null; do
  echo "Waiting for Alfresco to start..."
  sleep 10
done

echo "Alfresco is up. Creating group and user..."

# Step 1: Create group `aev_users` (ignore error if exists)
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/groups" \
  -H "Content-Type: application/json" \
  -d '{"id": "aev_users"}'

# Step 2: Create user `johndoe`
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/people" \
  -H "Content-Type: application/json" \
  -d '{
    "id": '\"$DUMMY_USER\"',
    "firstName": "John",
    "lastName": "Doe",
    "email": '\"$DUMMY_USER\"',
    "password":  '\"$DUMMY_PASSWORD\"'
  }'

# Step 3: Add user `johndoe` to group `aev_users`
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/groups/GROUP_aev_users/members" \
  -H "Content-Type: application/json" \
  -d '{
  "id": '\"$DUMMY_USER\"',
  "memberType": "PERSON"
}'

echo "User 'johndoe' created and added to 'aev_users' group."

# Step 4: Add user `digital signature` `
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$ALFRESCO_URL/alfresco/s/components/console/digisignconsole" \
  -H "Content-Type: application/json" \
  -d '{
  "signtypevalue": "digisign",
    "apiKey": "4CC4BA3E305BDAAEDDED",
    "secret": "E8161DFA875914ACD75896C3219BF25FF55E5DDF",
    "apiurl": "https://agcdev.crestsolution.com:5474",
    "digiconfigenabled": true,
    "clientid": "clientid",
    "clientsecret": "clientsecret",
    "enterpriseToken": "enterpriseToken",
    "docOwnerPrivyId": "docOwnerPrivyId",
    "channelId": "channelId",
    "privyconfigenabled": false
}'

echo "digital signature entry added"

echo "Creating Contract Management site "
curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/sites?skipConfiguration=false&skipAddToFavorites=false" \
  -H "Content-Type: application/json" \
  -d '{
  "id": "contract-management",
  "title": "Contract Management",
  "description": "Contract Management",
  "visibility": "PRIVATE"
}'

echo "Created Contract Management site "


DOC_LIB_NODE=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" \
  "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/sites/contract-management/containers/documentLibrary")

DOC_LIB_ID=$(echo "$DOC_LIB_NODE" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

if [[ -n "$DOC_LIB_ID" ]]; then
  echo "documentLibrary node ID: $DOC_LIB_ID"
fi
# Step 7: Create Template folder in Demo site documentLibrary
DOC_LIB_NODE=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$DOC_LIB_ID/children" \
  -H "Content-Type: application/json" \
  -d '{
      "name": "Templates",
      "nodeType": "cm:folder"
    }')

echo "Template folder created in contract-management site."

DOC_LIB_ID=$(echo "$DOC_LIB_NODE" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

# Step 8: Upload file to Template folder
upload_response=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$DOC_LIB_ID/children" \
  -F "filedata=@$LEGAL_FILE_TO_UPLOAD" \
  -F "name=$LEGAL_FILENAME" \
  )

# Extract nodeId of the uploaded file
node_id=$(echo "$upload_response" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\{0,1\}\([^",}]*\)".*/\1/p')

if [[ -n "$node_id" ]]; then
  echo "File uploaded in contract-management,  Node ID: $node_id"

  # Step 8: Change type of the uploaded file to "corporate:contract"
  curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X PUT "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$node_id" \
    -H "Content-Type: application/json" \
    -d '{"nodeType": "con:contract"}'

  echo "Node type changed to corporate:contract."
else
  echo "Failed to upload file or extract node ID."
fi



echo "Creating Hello Insurance site "

curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/sites?skipConfiguration=false&skipAddToFavorites=false" \
  -H "Content-Type: application/json" \
  -d '{
  "id": "Hello-Insurance",
  "title": "Hello Insurance",
  "description": "Demo site for testing",
  "visibility": "PRIVATE"
}'

echo "Created Hello Insurance site "


DOC_LIB_NODE=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" \
  "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/sites/Hello-Insurance/containers/documentLibrary")

DOC_LIB_ID=$(echo "$DOC_LIB_NODE" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

if [[ -n "$DOC_LIB_ID" ]]; then
  echo "documentLibrary node ID: $DOC_LIB_ID"

fi
# Step 7: Create Template folder in Demo site documentLibrary
DOC_LIB_NODE=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$DOC_LIB_ID/children" \
  -H "Content-Type: application/json" \
  -d '{
      "name": "Templates",
      "nodeType": "cm:folder"
    }')

echo "Template folder created in  Hello Insurance site."

DOC_LIB_ID=$(echo "$DOC_LIB_NODE" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

# Step 8: Upload file to Template folder
upload_response=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$DOC_LIB_ID/children" \
  -F "filedata=@$CORPORATE_FILE_TO_UPLOAD" \
  -F "name=$CORPORATE_FILENAME" \
  )

# Extract nodeId of the uploaded file
node_id=$(echo "$upload_response" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\{0,1\}\([^",}]*\)".*/\1/p')

if [[ -n "$node_id" ]]; then
  echo "File uploaded in contract-management,  Node ID: $node_id"

  # Step 8: Change type of the uploaded file to "corporate:contract"
  curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X PUT "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$node_id" \
    -H "Content-Type: application/json" \
    -d '{"nodeType": "corporate:contract"}'

  echo "Node type changed to corporate:contract."
else
  echo "Failed to upload file or extract node ID."
fi

