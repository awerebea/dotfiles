#!/usr/bin/env bash

creds="$HOME/.aws/credentials"
creds_temp="$HOME/.aws/tmp-creds/tmp.credentials"
creds_addon="$HOME/.aws/credentials_addon"
creds_temp_dir="$(dirname "$creds_temp")"

mkdir -p "$creds_temp_dir" 2> /dev/null
echo > "$creds_temp"
for i in torana-shared torana-dev
do
  aws-vault exec $i --json > "$creds_temp_dir"/$i.json
  echo "[$i]" >> "$creds_temp"
  echo -n aws_access_key_id= >> "$creds_temp"
  cat "$creds_temp_dir"/$i.json | jq .AccessKeyId >> "$creds_temp"
  echo >> "$creds_temp"
  echo -n aws_secret_access_key= >> "$creds_temp"
  cat "$creds_temp_dir"/$i.json | jq .SecretAccessKey >> "$creds_temp"
  echo >> "$creds_temp"
  echo -n aws_session_token= >> "$creds_temp"
  cat "$creds_temp_dir"/$i.json | jq .SessionToken >> "$creds_temp"
  echo >> "$creds_temp"
done
cp "$creds_temp" "$creds"

[ -f "$creds_addon" ] && echo >> "$creds_temp" && cat "$creds_addon" >> "$creds"
