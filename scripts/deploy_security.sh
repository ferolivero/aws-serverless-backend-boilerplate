#!/bin/bash
if ! which -s sam ; then
    echo "sam not found"
    exit 1
fi
export AWS_PROFILE="sandbox" ## UTILIZAR EL QUE ESTA EN .aws/credentials
export BUCKET="tesla-arch-deploy" ## NOMBRE DEL BUCKET EN S3

export ENV="predev"
export STACK="Test"
export PROJECT="Test" ## ESTE ES PARA SE USADO EN LOS NOMBRE DE LOS RECURSOS EN EL CLOUDFORMATION
export LOG_LEVEL="debug"

ENV=${ENV}
AWS_PROFILE=${AWS_PROFILE}
BUCKET=$ENV-${BUCKET}
STACK=$ENV-${STACK}
PROJECT=${PROJECT}

SOURCE="$(pwd)/cloudformations"
UUID=$$

echo 'Building SAM package and uploading cloudformation'
sam package --profile $AWS_PROFILE  --template-file "${SOURCE}/security.yaml" --output-template-file "security_$UUID.yaml" --s3-bucket $BUCKET
sam deploy --profile $AWS_PROFILE  --template-file "security_$UUID.yaml" --stack-name $STACK --tags Project=$PROJECT --capabilities CAPABILITY_NAMED_IAM --parameter-overrides Environment=$ENV Project=$PROJECT
rm "security_$UUID.yaml"
