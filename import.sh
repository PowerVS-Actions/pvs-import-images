#!/bin/bash

# Trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    echo "Bye!"
    exit 0
}

function check_dependencies() {

    DEPENDENCIES=(ibmcloud curl sh wget jq)
    check_connectivity
    for i in "${DEPENDENCIES[@]}"
    do
        if ! command -v "$i" &> /dev/null; then
            echo "$i could not be found, exiting!"
            exit
        fi
    done
}

function check_connectivity() {

    if ! curl --output /dev/null --silent --head --fail http://cloud.ibm.com; then
        echo
        echo "ERROR: please, check your internet connection."
        exit 1
    fi
}

function authenticate() {
    echo "authenticate"
    local APY_KEY="$1"

    if [ -z "$APY_KEY" ]; then
        echo "API KEY was not set."
        exit 1
    fi
    ibmcloud update -f > /dev/null 2>&1
    ibmcloud plugin update --all -f > /dev/null 2>&1
    ibmcloud login --no-region --apikey "$APY_KEY"
}

function set_powervs() {

    local CRN="$1"

    if [ -z "$CRN" ]; then
        echo "CRN was not set."
        exit 1
    fi
    ibmcloud pi st "$CRN"
}

function import(){

    # The new boot image name
    local IMAGE_NAME="$1"
    # The name of the image file in the object storage
    local IMAGE_FILE_NAME="$2"
    local OS_TYPE="$3"
    # tier1 or tier3
    local DISK_TYPE="$4"

    # object storage credentials
    local ACCESS_KEY="$5"
    local SECRET_KEY="$6"
    local BUCKET="$7"
    local BUCKET_ACCESS="$8"
    local REGION="$9"

    ibmcloud pi image-import "$IMAGE_NAME" --os-type "$OS_TYPE" --disk-type "$DISK_TYPE" --access-key "$ACCESS_KEY" --secret-key "$SECRET_KEY" --bucket-access "$BUCKET_ACCESS" --image-file-name "$IMAGE_FILE_NAME" --bucket "$BUCKET" --region "$REGION" --json
}

run(){

    if [ -z "$API_KEY" ]; then
        echo "API_KEY was not set."
        exit 1
    fi
    if [ -z "$POWERVS_CRN" ]; then
        echo "POWERVS was not set."
	    echo "ibmcloud pi service-list --json | jq '.[] | \"\(.CRN),\(.Name)\"'"
        exit 1
    fi
    if [ -z "$IMAGE_NAME" ]; then
        echo "IMAGE_NAME was not set."
      	exit 1
    fi
        if [ -z "$CLUSTER_ID" ]; then
        echo "CLUSTER_ID was not set."
      	exit 1
    fi
    if [ -z "$OS_TYPE" ]; then
        echo "OS_TYPE was not set."
      	exit 1
    fi
    if [ -z "$DISK_TYPE" ]; then
        echo "DISK_TYPE was not set."
      	exit 1
    fi
    if [ -z "$ACCESS_KEY" ]; then
        echo "ACCESS_KEY was not set."
      	exit 1
    fi
    if [ -z "$SECRET_KEY" ]; then
        echo "SECRET_KEY was not set."
      	exit 1
    fi
    if [ -z "$BUCKET_ACCESS" ]; then
        echo "BUCKET_ACCESS was not set."
      	exit 1
    fi
    if [ -z "$IMAGE_FILE_NAME" ]; then
        echo "IMAGE_FILE_NAME was not set."
      	exit 1
    fi
    if [ -z "$BUCKET" ]; then
        echo "BUCKET was not set."
      	exit 1
    fi
    if [ -z "$REGION" ]; then
        echo "REGION was not set."
      	exit 1
    fi

    check_dependencies
    check_connectivity
    authenticate "$API_KEY"
    set_powervs "$POWERVS_CRN"

    import "$IMAGE_NAME" "$IMAGE_FILE_NAME" "$OS_TYPE" "$DISK_TYPE" "$ACCESS_KEY" "$SECRET_KEY" "$BUCKET" "$BUCKET_ACCESS" "$REGION"
}