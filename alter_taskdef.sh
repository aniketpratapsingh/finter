#!/bin/bash

set -x

while getopts e:b:c:s:f:u: opts; do
    case ${opts} in
      e) APP_ENVIRONMENT=${OPTARG} ;;
      b) BUILD_NUMBER=${OPTARG} ;;
      c) CLUSTER=${OPTARG} ;;
      s) SERVICE_NAME=${OPTARG} ;;
      f) FAMILY=${OPTARG} ;;
      u) IMAGE_REGISTRY_URL=${OPTARG} ;;
      \?) echo "Invalid option -$OPTARG . Usage sh alter_taskdef.sh -e <APP_ENVIRONMENT> -b <BUILD_NUMBER> -c <CLUSTER_NAME> -s <SERVICE_NAME> -f <FAMILY_NAME> -u <IMAGE_REGISTRY_URL>" >&2
   esac
done

#BUILD_NUMBER=$1
REGION=us-east-2
#IMAGE_URI=324929335620.dkr.ecr.us-west-2.amazonaws.com/vitals-analytics:${BUILD_NUMBER}
IMAGE_URI=${IMAGE_REGISTRY_URL}:${BUILD_NUMBER}
#CLUSTER=vitals-cluster
#SERVICE_NAME=va-service
IMAGE_NAME=finter_${BUILD_NUMBER}
#FAMILY=vitals_family
# App environment is the name of the folder inside which the taskdef.json exists
#APP_ENVIRONMENT=dev

#Replace the build number and respository URI placeholders with the constants above
sed -e "s;%FAMILY%;${FAMILY};g" -e "s;%IMAGE_URI%;${IMAGE_URI};g" ${APP_ENVIRONMENT}/fi_aws_taskdef.json > ${APP_ENVIRONMENT}_${IMAGE_NAME}.json
#Register the task definition in the repository
aws ecs register-task-definition --family ${FAMILY} --cli-input-json file://`pwd`/${APP_ENVIRONMENT}_${IMAGE_NAME}.json --region ${REGION}

#update the service
aws ecs update-service --cluster ${CLUSTER} --region ${REGION} --service ${SERVICE_NAME} --desired-count 1 --task-definition ${FAMILY}
