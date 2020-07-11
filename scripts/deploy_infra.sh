#!/bin/bash

#######################################################
# VALIDAR SI AWS CLI ESTA INSTALADO
if ! [ -x "$(command -v aws)" ]; then
    date=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$date [ ERROR ] aws cli not found"
    exit 1
fi

# VALIDAR SI SAM CLI ESTA INSTALADO
if ! [ -x "$(command -v sam)" ]; then
    date=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$date [ ERROR ] sam cli not found"
    exit 1
fi

# VALIDAR SI NPM ESTA INSTALADO
if ! [ -x "$(command -v npm)" ]; then
    date=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$date [ ERROR ] npm not found"
    exit 1
fi
#######################################################


#######################################################
# DESCOMENTAR, CAMBIAR LOS VALORES Y EJECUTAR LOCALMENTE:

export AWS_PROFILE="sandbox" ## UTILIZAR EL QUE ESTA EN .aws/credentials
export BUCKET="tesla-arch-deploy-1" ## NOMBRE DEL BUCKET EN S3

export ENV="predev"
export STACK="Test"
export PROJECT="Test" ## ESTE ES PARA SE USADO EN LOS NOMBRE DE LOS RECURSOS EN EL CLOUDFORMATION
export LOG_LEVEL="debug"

# DE SER NECESARIO DEFINIR MAS VARIABLES, HACERLA EN ESTA SECCION
#######################################################


#######################################################
# SE CONFIGURA LAS VARIABLES A USAR EN EL PROCESO

ENV=${ENV}
AWS_PROFILE=${AWS_PROFILE}
BUCKET=$ENV-${BUCKET}
STACK=$ENV-${STACK}
PROJECT=${PROJECT}

ROOT_PATH="$(pwd)"
SOURCE="$ROOT_PATH/cloudformations"
FUNCTIONS="$ROOT_PATH/functions/*"
BUILD_PATH="$ROOT_PATH/.aws-sam/build/"
LOG_LEVEL="$LOG_LEVEL"
LOG_RETENTION_IN_DAYS=5
UUID=$$

LAYERS="$ROOT_PATH/layers"

# DE SER NECESARIO SETTEAR MAS VARIABLES, HACERLA EN ESTA SECCION
#######################################################


#######################################################
# PROCESO DE CONFIGURACION DE LAYERS
# LAMENTABLEMENTE ESTE PROCESO HAY QUE HACERLO A MANO, SAM NI AWS CLI, NO CONTEMPLA
# LA INSTALACION DE DEPENDENCIAS DE LAS LAYERS

if [ -d "$LAYERS" ]; then
   for folder in $LAYERS; do
      for platform in $folder/*; do
         name=${platform##*/}
         if [[ "$(ls -A $platform)" && $name != "README.md" ]]; then
            date=$(date '+%Y-%m-%d %H:%M:%S')
            echo -e "$date [ INFO ] :: BUILDING LAYERS FOR: $name"
            cd $platform

            case $platform in
               *node)
                  date=$(date '+%Y-%m-%d %H:%M:%S')
                  nodeModules="$platform/npm/nodejs/node_modules"
                  tmpNodeModules="$platform/npm/nodejs/tmp_node_modules"
                  mkdir -p $nodeModules

                  for layer in $platform/*; do
                     layerName=${layer##*/}
                     if [[ "$(ls -A $layer)" && $layerName != "README.md" ]]; then
                        echo -e "$date [ INFO ] :: BUILDING LAYER: $layerName"
                        [[ $layerName == "npm" ]] && cd "$layer/nodejs/" || cd "$layer/nodejs/node_modules/$layerName/"

                        if [ -f package.json ]; then
                           yarn install --modules-folder $tmpNodeModules --prod
                           cp -R $tmpNodeModules/* $nodeModules/
                        else
                           echo "$date [ ERROR ] :: package.json NOT FOUND IN $layerName/"
                        fi
                     fi
                  done
                  rm -rf $tmpNodeModules
               ;;
               *python)
                  if [[ -f requirements.txt ]]; then
                     echo -e "$date [ INFO ] :: INSTALLING PYTHON LIB FOR LAYERS"
                     pip install -r requirements.txt -t .
                  else
                     echo "$date [ ERROR ] :: REQUIREMENTS.TXT NOT FOUND IN $platform"
                  fi
               ;;
               *java)
                  if [[ -f POM.xml ]]; then
                     echo -e "$date [ INFO ] :: INSTALLING JAVA LIB FOR LAYERS"
                     mvn install
                  fi
               ;;
            esac
         fi
      done
   done
else
  date=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$date [ WARN ] :: THE DIRECTORY 'LAYERS' DOES NOT EXIST, THE PROCESS OF LAYER INSTALLATION WILL NOT TAKE PLACE IN THIS DEPLOYMENT"
fi

cd $ROOT_PATH

#######################################################


#######################################################
# VALIDACIÓN DEL CLOUDFORMATION SOURCE/cloudformations/template.yaml

if [ $ENV == 'predev' ] || [ $ENV == 'noprod' ]; then
   date=$(date '+%Y-%m-%d %H:%M:%S')
   echo "$date [ INFO ] :: VALIDATING TEMPLATE ${SOURCE}/cloudformations/template.yaml"
   sam validate \
     --template "$SOURCE/template.yaml" \
     --profile ${AWS_PROFILE}
fi
#######################################################


#######################################################
# PROCESO DE BUILDING DEL CLOUDFORMATION SOURCE/cloudformations/template.yaml

date=$(date '+%Y-%m-%d %H:%M:%S')
echo "$date [ INFO ] :: BUILDING SAM ${SOURCE}/cloudformations/template.yaml"
sam build -t "$SOURCE/template.yaml"
#######################################################


#######################################################
# PROCESO DE PACKAGING DEL PROJECTO

date=$(date '+%Y-%m-%d %H:%M:%S')
echo "$date [ INFO ] :: PACKAGING SAM PROJECT"
sam package \
    --profile $AWS_PROFILE  \
    --template-file "$BUILD_PATH/template.yaml" \
    --output-template-file "template_$UUID.yaml" \
    --s3-bucket $BUCKET
#######################################################


#######################################################
# PREOCESO DE DESPLIEGUE DE PROYECTO EN AWS

date=$(date '+%Y-%m-%d %H:%M:%S')
echo "$date [ INFO ] :: DEPLOYING SAM PROJECT"
sam deploy \
    --profile $AWS_PROFILE \
    --template-file "template_$UUID.yaml" \
    --stack-name $STACK \
    --capabilities CAPABILITY_NAMED_IAM \
    --tags Project=$PROJECT \
    --s3-bucket $BUCKET \
    --parameter-overrides \
        Project=$PROJECT \
        DeployBucket=$BUCKET \
        Environment=$ENV \
        LogLevel=$LOG_LEVEL \
        RetentionInDays=$LOG_RETENTION_IN_DAYS \
        StackName=$STACK \
        UUID=$UUID
#######################################################


#######################################################
# LIMPIEZA DE PRECESO DE DESPLIEGUE
rm "template_$UUID.yaml"
rm -rf "$(pwd)/.aws-sam"
#######################################################
