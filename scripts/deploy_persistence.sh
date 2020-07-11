#!/bin/bash
if ! which -s sam ; then
    echo "sam not found"
    exit 1
fi

ENV=predev
AWS_PROFILE=xxxxxxxxx
SOURCE="$(pwd)/cloudformations"
UUID=$$
BUCKET=$ENV-xxxxxxxxx

STACK=$ENV-XXXXXXXXXXXXXXXX
PROJECT=XXXXXXXXXXXXXXXXXX

echo 'Building SAM package and uploading cloudformation'
sam package --profile $AWS_PROFILE  --template-file "${SOURCE}/persistence.yaml" --output-template-file "persistence_$UUID.yaml" --s3-bucket $BUCKET
sam deploy --profile $AWS_PROFILE  --template-file "persistence_$UUID.yaml" --stack-name $STACK --tags Project=$PROJECT --capabilities CAPABILITY_NAMED_IAM --parameter-overrides Environment=$ENV
rm "persistence_$UUID.yaml"
