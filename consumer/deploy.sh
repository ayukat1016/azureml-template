set -ex

# Installs
pip install --upgrade azure-core azure-ai-ml
az extension show --name ml || az extension add --name ml
apk add gettext

# sleep
sleep $DELAY_SECONDS

# get storage account key
STORAGE_ACCOUNT_KEY=$(az storage account keys list --subscription ${PROVIDER_SUB} --resource-group ${PROVIDER_RG} --account-name ${STORAGE_ACCOUNT_NAME} --query \"[?keyName == 'key1'].value\" --output tsv)

# データ資産登録
ASSET_DIR=./dataset
ASSET_NAME=dev-ml-template-dataset
ASSET_DESC=dev-ml-template-dataset
ASSET_VERSION=1
ASSET_PATH=${ASSET_DIR}/diamonds.csv

mkdir $ASSET_DIR
az storage blob download --subscription ${PROVIDER_SUB} -f ${ASSET_PATH} -c ${STORAGE_CONTAINER} -n ${OBJECT_DATA} --account-name ${STORAGE_ACCOUNT_NAME} --account-key ${STORAGE_ACCOUNT_KEY}
az ml data create --type uri_folder --name ${ASSET_NAME} --description ${ASSET_DESC} --path ${ASSET_DIR} --version ${ASSET_VERSION} --subscription ${CONSUMER_SUB} --resource-group ${CONSUMER_RG} --workspace-name ${CONSUMER_WS}

# 新規コンピューティングリソース登録
az ml compute create --type AmlCompute -n ${CLUSTER_NAME} --min-instances 0 --max-instances 1 --size ${CLUSTER_SIZE} --subscription ${CONSUMER_SUB} --resource-group ${CONSUMER_RG} --workspace-name ${CONSUMER_WS}

# ジョブ実行登録
JOB_DIR=./pipelines
JOB_TEMPLATE_PATH=${JOB_DIR}/pipeline_template.yml
JOB_PATH=${JOB_DIR}/pipeline.yml

# Set environment variables for apply envsubst to job template
export DATA_PATH=azureml:${ASSET_NAME}:${ASSET_VERSION}

mkdir $JOB_DIR

az storage blob download --subscription ${PROVIDER_SUB} -f ${JOB_TEMPLATE_PATH} -c ${STORAGE_CONTAINER} -n ${OBJECT_PIPELINE} --account-name ${STORAGE_ACCOUNT_NAME} --account-key ${STORAGE_ACCOUNT_KEY}

echo '--- env ----------------------------------------------------------------------------------------------------------------------'
env
echo '-------------------------------------------------------------------------------------------------------------------------'

envsubst '$COMPUTE_PATH $DATA_PATH $COMPONENT_PREPROCESS_PATH $COMPONENT_TRAIN_PATH $COMPONENT_PREDICT_PATH $COMPONENT_EVALUATE_PATH' < ${JOB_TEMPLATE_PATH} > ${JOB_PATH}

echo '+++ pipeline.yaml ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
cat ${JOB_PATH}
echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'

sleep $DELAY_SECONDS

az ml job create --file ${JOB_PATH} --subscription ${CONSUMER_SUB} --resource-group ${CONSUMER_RG} --workspace-name ${CONSUMER_WS}

echo '{\"result\":\"OK\"}' > $AZ_SCRIPTS_OUTPUT_PATH

