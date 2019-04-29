#!/bin/bash

# Copyright 2012-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -ex

backup_s3_bucket="${1}"
codecommitrepo="${2}"

trap 'rm -rf "${codecommitrepo}"; [[ -n "${zipfile:-}" ]] && rm -f "${zipfile}"' EXIT

echo "[===== Cloning repository: ${codecommitrepo} =====]"
git clone "https://git-codecommit.${AWS_DEFAULT_REGION}.amazonaws.com/v1/repos/${codecommitrepo}"

dt=$(date -u "+%Y_%m_%d_%H_%M")
zipfile="${codecommitrepo}_backup_${dt}_UTC.tar.gz"
echo "Compressing repository: ${codecommitrepo} into file: ${zipfile} and uploading to S3 bucket: ${backup_s3_bucket}/${codecommitrepo}"

tar -zcvf "${zipfile}" "${codecommitrepo}/"
aws s3 cp "${zipfile}" "s3://${backup_s3_bucket}/${codecommitrepo}/${zipfile}" --region $AWS_DEFAULT_REGION

