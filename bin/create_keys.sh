#!/usr/bin/env bash

filenames=https
declare -a arr=( "certs/influxdb" "certs/nginx" )

Country_Name=ES
State_Name=Catalunya
Locality=Barcelona
Organization="Example Co"
Common_Name=www.example.com



function ssl_keys(){
  mkdir -p $1
  openssl genrsa -out $1/$2.key 2048
  # openssl ecparam -genkey -name secp384r1 -out $2.key
  openssl req -new -x509 -sha256 -days 3650 \
      -key $1/$2.key -out $1/$2.crt  \
      -subj "/C=$Country_Name/ST=$State_Name/L=$Locality/O=$Organization/CN=$Common_Name"
}

for i in "${arr[@]}"
do
  if [ ! -e "$i"/$filenames.key ]; then
    ssl_keys "$i" $filenames
  else
    echo ""$i"/$filenames.* Not created, files exists."
  fi
done
