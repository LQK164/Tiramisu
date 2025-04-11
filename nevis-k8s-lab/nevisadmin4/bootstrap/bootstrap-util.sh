#!/usr/bin/env bash
ZIP_DIR="assets"
TARGET_DIR="../target"
ADMIN_USER="admin"
COMMON_CURL_OPTIONS=('--http1.1' '--retry' '10' '--retry-connrefused' '--retry-delay' '5' '-k' '--fail' '-sS')


gitea-setup() {
    timeout 180 bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' '$GIT_DOMAIN')" != "200" ]]; do sleep 15; done'
    echo "Creating gitea repository"
    curl -u "$GIT_USER":"$GIT_PASSWORD" "${COMMON_CURL_OPTIONS[@]}" -X POST "$GIT_DOMAIN/api/v1/admin/users/$GIT_USER/repos" \
    	      -d "{\"name\":\"deploy\",\"description\":\"repository used for k8s deployments\",\"private\": true,\"auto_init\": true,\"default_branch\": \"master\"}" \
    				-H "accept: application/json" -H  "content-type: application/json"
    curl -u "$GIT_USER":"$GIT_PASSWORD" "${COMMON_CURL_OPTIONS[@]}" -X POST "$GIT_DOMAIN/api/v1/admin/users/$GIT_USER/repos" \
    	      -d "{\"name\":\"config\",\"description\":\"repository used for nevisAdmin 4 configuration\",\"private\": true,\"auto_init\": true,\"default_branch\": \"master\"}" \
    				-H "accept: application/json" -H  "content-type: application/json"
    if [ -s keys/key.pub ]; then
        echo "Adding public key to gitea repository"
        local public_key
        public_key=$(cat keys/key.pub)
        curl -u "$GIT_USER":"$GIT_PASSWORD" "${COMMON_CURL_OPTIONS[@]}" -X POST "$GIT_DOMAIN/api/v1/admin/users/$GIT_USER/keys" \
        	      -d "{\"title\":\"admin-$RANDOM\",\"key\":\"$public_key\",\"read_only\":false}" \
        				-H "accept: application/json" -H  "content-type: application/json"
    fi
}

import-projects() {
    timeout 180 bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' '${DOMAIN}'/nevisadmin/)" != "200" ]]; do sleep 15; done'
    local selector
    # create regex based selector for the projects/inventories, PROJECT_ARRAY is a string representation of an array, for example:'["one","two"]'
    if [ "$IMPORT_PROJECTS" = 'true' ]; then
        selector='TEMPLATE\|'$(echo "$PROJECT_ARRAY" | tr -d '"[]' | sed 's/,/\\|/g')
    else
        selector="TEMPLATE"
    fi
    echo "Getting token"
    local secret token

    echo "Getting authorization token"
    local auth_body
    auth_body=$(jq --null-input \
      --arg user "$ADMIN_USER" \
      --arg password "$NEVISADMIN4_PASSWORD" \
      '{"userKey": $user, "password": $password}')
    token=$( curl -XPOST "${COMMON_CURL_OPTIONS[@]}" -d "$auth_body" \
                        -H "Content-Type: application/json;charset=utf-8" \
				                -H "accept: application/json" \
                        "${DOMAIN}/nevisadmin/api/v1/login?tokenType=bearer" \
                       | jq -r ".token" );

    mkdir -p "$TARGET_DIR"
    cp -r "$ZIP_DIR/." "$TARGET_DIR/"
    local projects version
    # list files then filter based on the selector, don't fail in case of no results
    # ignore spellcheck as zip names are always alphanumeric
    # shellcheck disable=SC2010,SC2015
    projects=$( cd "$ZIP_DIR" && ls ./*project*zip | grep "$selector" || [[ $? == 1 ]] )
    version=$(curl -XGET "${COMMON_CURL_OPTIONS[@]}" -H "Authorization: Bearer $token" \
         "${DOMAIN}/nevisadmin/api/v1/bundles" | jq -r '.items[0] | split(":")[1]');
    echo "Starting project imports"
    for project in $projects; do
        local project_zip project_key_stripped project_key
        project_zip="$TARGET_DIR/$project"
        project_key_stripped=$(echo "$project" | cut -f 2 -d_)
        project_key="DEFAULT-$project_key_stripped"

        echo "Importing project: $project_key_stripped"
        curl -XPOST "${COMMON_CURL_OPTIONS[@]}" -o /dev/null -F "project=@$project_zip;type=application/x-zip-compressed" \
             -H "Authorization: Bearer $token" \
             "${DOMAIN}/nevisadmin/api/v1/projects/file-import?projectKey=$project_key";
        echo "Setting bundles for project: $project_key_stripped"
        sleep 20
        curl -XPUT "${COMMON_CURL_OPTIONS[@]}" -o /dev/null -H "Authorization: Bearer $token" \
         -H "Content-Type: application/json" \
         -d '{"items":["nevisadmin-plugin-nevisdp:'"$version"'","nevisadmin-plugin-base-generation:'"$version"'","nevisadmin-plugin-nevisproxy:'"$version"'","nevisadmin-plugin-nevisauth:'"$version"'","nevisadmin-plugin-nevisidm:'"$version"'","nevisadmin-plugin-mobile-auth:'"$version"'","nevisadmin-plugin-nevisdetect:'"$version"'","nevisadmin-plugin-oauth:'"$version"'","nevisadmin-plugin-authcloud:'"$version"'"]}' \
         "${DOMAIN}/nevisadmin/api/v1/projects/$project_key/bundles";
    done;
    local inventories
    # shellcheck disable=SC2010,SC2015
    inventories=$( cd "$ZIP_DIR" && ls ./*inventory*zip | grep "$selector" || [[ $? == 1 ]] )
    echo "Starting inventory imports"
    for inventory in $inventories; do
        inventory_zip="$TARGET_DIR/$inventory"
        inventory_key_stripped=$(echo "$inventory" | cut -f 2 -d_)
        inventory_key="DEFAULT-$inventory_key_stripped"

        echo "Importing inventory: $inventory_key_stripped"
        curl -XPOST "${COMMON_CURL_OPTIONS[@]}" -o /dev/null -F "inventory=@$inventory_zip;type=application/x-zip-compressed" \
             -H "Authorization: Bearer $token" \
             "${DOMAIN}/nevisadmin/api/v1/inventories/file-import?inventoryKey=$inventory_key";

        echo "Creating token inventory secret"
        sleep 10 # could result in 404 if called right after inventory creation
        local secret
        secret=$(curl "${COMMON_CURL_OPTIONS[@]}" "${DOMAIN}/nevisadmin/api/v1/inventories/$inventory_key/secrets" \
            -H "Authorization: Bearer $token" -H 'content-type: application/json' \
            --data-binary '{"value":"'"$AZURE_TOKEN"'"}' --compressed \
            | jq -r ".secretId");

        modify_zips "$secret" "$selector";

        echo "Updating inventory $inventory_key_stripped with secret token"
        curl -XPOST "${COMMON_CURL_OPTIONS[@]}" -o /dev/null -F "inventory=@$inventory_zip;type=application/x-zip-compressed" \
             -H "Authorization: Bearer $token" \
             "${DOMAIN}/nevisadmin/api/v1/inventories/file-import?inventoryKey=$inventory_key";
    done;

    echo "Logging out"
    curl -XGET "${COMMON_CURL_OPTIONS[@]}" -o /dev/null -H "Authorization: Bearer $token" \
         "${DOMAIN}/nevisadmin/api/v1/logout";
}

modify_zips() {
    local secret cwd inventories
    secret=${1};
    cwd=$( pwd )
    cd "$TARGET_DIR";

    # shellcheck disable=SC2010,SC2015
    inventories=$( ls ./*inventory*zip | grep "$2" || [[ $? == 1 ]])
    for zipfile in $inventories; do
        local directory
        directory="${zipfile%.*}";
        mkdir -p "$directory";
        cd "$directory";
        unzip -q "../$zipfile" 2> /dev/null;
        for fname in *.yml; do
            sed -i -e 's#examplehostname#https://'"$PROXY_HOST"'#g' "$fname" # edit host exampledbhost
            sed -i -e 's#exampledbhost#'"$DB_SERVER"'#g' "$fname" # edit host dbhost
            sed -i -e 's#examplegiturl#'"$GIT_URL"'#g' "$fname" #edit git url
            sed -i -e 's#examplenamespace#'"$DEPLOYMENT_NAMESPACE"'#g' "$fname" #edit namespace
            sed -i -e "s#.*token:.*#  token: secret://$secret#g" "$fname" #edit token
        done
        zip -qr "../$zipfile" .;
        cd ..;
        rm -rf "$directory";
    done

    cd "$cwd";
}

### MAIN
set -e
case $1 in
"gitea-setup")
    gitea-setup;
    ;;
"import-projects")
    import-projects;
    ;;
esac
