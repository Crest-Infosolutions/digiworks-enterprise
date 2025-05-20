#!/bin/bash

### === CONFIGURATION ===
ALFRESCO_URL="http://localhost:8080"
ADMIN_USER="admin"
ADMIN_PASS="admin"
DUMMY_USER="johndoe@crestsolution.com"
DUMMY_PASSWORD="Crest@123"
CORPORATE_FILE_TO_UPLOAD="/usr/local/bin/corporate-contract.docx"
CORPORATE_FILENAME="corporate-contract.docx"
LEGAL_FILE_TO_UPLOAD="/usr/local/bin/legal-contract.docx"
LEGAL_FILENAME="legal-contract.docx"
FILES_TO_UPLOAD=(
  "/usr/local/bin/documentReminder.html.ftl"
  "/usr/local/bin/folderReminder.html"
)

### === FUNCTIONS ===

wait_for_alfresco() {
  until curl -s -u "$ADMIN_USER:$ADMIN_PASS" "$ALFRESCO_URL/alfresco/api/-default-/public/authentication/versions/1/tickets" > /dev/null; do
    echo "Waiting for Alfresco to start..."
    sleep 10
  done
  echo "✅ Alfresco is up"
}

extract_id() {
  echo "$1" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\{0,1\}\([^",}]*\)".*/\1/p'
}

create_group() {
  curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/groups" \
    -H "Content-Type: application/json" \
    -d '{"id": "aev_users"}'
}


create_folder_and_upload_templates() {
  local new_folder_name="crestpublicLink"
  
  echo "🔎 Searching for 'Email Templates' folder..."
 
  search_response=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" \
    "$ALFRESCO_URL/alfresco/api/-default-/public/search/versions/1/search" \
    -H "Content-Type: application/json" \
    -d '{
      "query": {
        "query": "PATH:\"/app:company_home/app:dictionary/app:email_templates\""
      }
    }')
  echo "search_response:$search_response"

  extract_entry_id() {
    echo "$1" | \
    # Extract content inside "entry":{...} block (non-greedy is hard with sed, this works for your case)
    sed -n 's/.*"entry":{\(.*\)}}].*/\1/p' | \
    # Extract all "id":"..." fields
    grep -o '"id":"[^"]*"' | \
    # Filter out common system/admin ids (adjust if needed)
    grep -vE '"id":"System"|"id":"admin"|"id":"Administrator"' | \
    # Pick first matching id
    head -1 | \
    sed 's/"id":"\([^"]*\)"/\1/'
  }

  parent_id=$(extract_entry_id "$search_response")

  if [ -z "$parent_id" ]; then
    echo "❌ Failed to find 'Email Templates' folder via search."
    return
  fi

  echo "📁 'Email Templates' folder found. Creating '$new_folder_name' inside..."

  folder_response=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST \
    "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$parent_id/children" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$new_folder_name\", \"nodeType\": \"cm:folder\"}")

  new_folder_id=$(extract_id "$folder_response")
  if [ -z "$new_folder_id" ]; then
    echo "❌ Failed to create folder."
    return
  fi

  echo "✅ Folder created. Uploading files to folder ID: $new_folder_id ..."

  for file in "${FILES_TO_UPLOAD[@]}"; do
    if [ -f "$file" ]; then
      file_name=$(basename "$file")
      upload=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST \
        "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$new_folder_id/children" \
        -F "filedata=@$file" -F "name=$file_name" -F "nodeType=cm:content")

      upload_id=$(extract_id "$upload")
      if [ -n "$upload_id" ]; then
        echo "✅ Uploaded: $file_name"
      else
        echo "❌ Failed to upload: $file_name"
      fi
    else
      echo "⚠️ File not found: $file"
    fi
  done
}




create_user_and_add_to_group() {
  curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/people" \
    -H "Content-Type: application/json" \
    -d "{
      \"id\": \"$DUMMY_USER\",
      \"firstName\": \"John\",
      \"lastName\": \"Doe\",
      \"email\": \"$DUMMY_USER\",
      \"password\": \"$DUMMY_PASSWORD\"
    }"

  curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/groups/GROUP_aev_users/members" \
    -H "Content-Type: application/json" \
    -d "{
      \"id\": \"$DUMMY_USER\",
      \"memberType\": \"PERSON\"
    }"

  echo "✅ User created and added to group"
}

configure_digital_signature() {
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
  echo "✅ Digital signature entry added"
}

create_site_and_upload_contract() {
  local site_id=$1
  local site_title=$2
  local file_path=$3
  local file_name=$4
  local node_type=$5

  echo "🌐 Creating site: $site_title"
  site_response=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST \
    "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/sites?skipConfiguration=false&skipAddToFavorites=false" \
    -H "Content-Type: application/json" \
    -d "{
      \"id\": \"$site_id\",
      \"title\": \"$site_title\",
      \"description\": \"$site_title\",
      \"visibility\": \"PRIVATE\"
    }")

  echo "$site_response"

  echo "📁 Getting document library folder ID for $site_title"
  doc_id=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" \
    "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/sites/$site_id/containers/documentLibrary" \
    | sed -n 's/.*\"id\"[[:space:]]*:[[:space:]]*\"\([^"]*\)\".*/\1/p')

  echo "📂 Document Library Folder ID: $doc_id"

  if [ -z "$doc_id" ]; then
    echo "❌ Failed to get documentLibrary node ID."
    return
  fi

  echo "📁 Creating Templates folder in $site_title"
  folder_node=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST \
    "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$doc_id/children" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Templates",
      "nodeType": "cm:folder"
    }')

  echo "📦 Folder creation response: $folder_node"

  folder_id=$(echo "$folder_node" | sed -n 's/.*\"id\"[[:space:]]*:[[:space:]]*\"\([^"]*\)\".*/\1/p')

  if [ -z "$folder_id" ]; then
    echo "❌ Failed to create Templates folder."
    return
  fi

  echo "📤 Uploading $file_name to Templates from $file_path"
  upload_response=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X POST \
    "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$folder_id/children" \
    -F "filedata=@$file_path" -F "name=$file_name" -F "nodeType=cm:content")

  echo "📨 Upload response: $upload_response"

  file_id=$(echo "$upload_response" | sed -n 's/.*\"id\"[[:space:]]*:[[:space:]]*\"\([^"]*\)\".*/\1/p')

  if [[ -n "$file_id" ]]; then
    echo "✅ File uploaded. Updating node type to $node_type..."
    update_response=$(curl -s -u "$DUMMY_USER:$DUMMY_PASSWORD" -X PUT \
      "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/nodes/$file_id" \
      -H "Content-Type: application/json" \
      -d "{\"nodeType\": \"$node_type\"}")
    echo "🔁 Update response: $update_response"
  else
    echo "❌ Upload failed for $file_name"
  fi
}



### === MAIN EXECUTION ===

wait_for_alfresco

user_check=$(curl -s -o /dev/null -w "%{http_code}" -u "$ADMIN_USER:$ADMIN_PASS" \
  "$ALFRESCO_URL/alfresco/api/-default-/public/alfresco/versions/1/people/$DUMMY_USER")

if [[ "$user_check" == 404 ]]; then
  echo "🔧 $DUMMY_USER not found. Applying initial configuration..."

  create_group
  create_user_and_add_to_group
  echo "Waiting for 30 sec for ES to Index...."
  sleep 30
  create_folder_and_upload_templates
  configure_digital_signature
  create_site_and_upload_contract "contract-management" "Contract Management" "$LEGAL_FILE_TO_UPLOAD" "$LEGAL_FILENAME" "con:contract"
  create_site_and_upload_contract "Hello-Insurance" "Hello Insurance" "$CORPORATE_FILE_TO_UPLOAD" "$CORPORATE_FILENAME" "corporate:contract"
else
  echo "ℹ️ User already exists. Skipping initial configuration."
fi
