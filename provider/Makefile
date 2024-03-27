LOCATION ?= japaneast
SUB ?= f9928460-8ada-4f70-983d-a98b5653e039
RG ?= dev-ml-template-rg103
# Must be unique name in global
AML_REGISTRY ?= dev-ml-template-registry103
# Must be unique name in global
STORAGE_ACCOUNT_NAME ?= devmlst103
STORAGE_CONTAINER_NAME ?= devmlstc103
IDENTITY_NAME ?= dev-ml-template-managedid

# サブスクリプション切替
.PHONY: set-subscription
set-subscription:
	az account set --subscription $(SUB)

# リソースグループ作成
.PHONY: create-rg
create-rg: set-subscription
	az group create --name $(RG) --location $(LOCATION)

# AMLレジストリ作成
.PHONY: create-registry
create-registry: set-subscription
	az ml registry create --file registry.yml --name $(AML_REGISTRY) --resource-group $(RG)

# 環境の登録
.PHONY: create-environment
create-environment: set-subscription
	mkdir -p build
	rm -rf build/*
	cp machine_learning/Dockerfile build/
	cp machine_learning/pyproject.toml build/
	cp machine_learning/poetry.lock build/
	az ml environment create --file environment.yml --resource-group $(RG) --registry-name $(AML_REGISTRY)

# コンポーネントの登録
.PHONY: create-component
create-component: set-subscription
	mkdir -p dist
	rm -rf dist/*
	rsync -ahv machine_learning/src dist --exclude '__pycache__'
	az ml component create --file components/preprocess.yml --registry-name $(AML_REGISTRY)
	az ml component create --file components/train.yml --registry-name $(AML_REGISTRY)
	az ml component create --file components/predict.yml --registry-name $(AML_REGISTRY)
	az ml component create --file components/evaluate.yml --registry-name $(AML_REGISTRY)

# ストレージアカウント作成
.PHONY: create-storage
create-storage: set-subscription
	az storage account create \
		--name $(STORAGE_ACCOUNT_NAME) \
		--resource-group $(RG) \
		--location $(LOCATION) \
		--sku Standard_ZRS \
		--encryption-services blob

# ストレージコンテナー作成
.PHONY: create-container
create-container: set-subscription
	az storage container create \
		--name $(STORAGE_CONTAINER_NAME) \
		--account-name $(STORAGE_ACCOUNT_NAME) \
		--auth-mode login

# コンテナーにファイルを追加
.PHONY: upload-files
upload-files: set-subscription
	mkdir -p dataset
	rm -rf dataset/*
	cp machine_learning/data/diamonds.csv dataset/
	az storage blob upload \
		--file dataset/diamonds.csv \
		--overwrite \
		--name diamonds.csv \
		--container-name $(STORAGE_CONTAINER_NAME) \
		--account-name $(STORAGE_ACCOUNT_NAME) \
		--account-key "`az storage account keys list --subscription $(SUB) --resource-group $(RG) --account-name $(STORAGE_ACCOUNT_NAME) --query "[?keyName == 'key1'].value" --output tsv`"
	az storage blob upload \
		--file pipelines/pipeline_template.yml \
		--overwrite \
		--name pipeline_template.yml \
		--container-name $(STORAGE_CONTAINER_NAME) \
		--account-name $(STORAGE_ACCOUNT_NAME) \
		--account-key "`az storage account keys list --subscription $(SUB) --resource-group $(RG) --account-name $(STORAGE_ACCOUNT_NAME) --query "[?keyName == 'key1'].value" --output tsv`"

# マネージドID作成
.PHONY: create-identity
create-identity:
	az identity create --name $(IDENTITY_NAME) --resource-group $(RG)

# マネージドIDにAMLレジストリの `閲覧者` ロールを付与
# マネージドIDにストレージの `閲覧者とデータアクセス` ロールを付与
.PHONY: create-role-assignment-identity
create-role-assignment-identity:
	az role assignment create \
		--assignee "`az identity list --query "[?name == '$(IDENTITY_NAME)'].principalId" --output tsv`" \
		--role '/subscriptions/$(SUB)/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7' \
		--scope '/subscriptions/$(SUB)/resourceGroups/$(RG)/providers/Microsoft.MachineLearningServices/registries/$(AML_REGISTRY)'
	az role assignment create \
		--assignee "`az identity list --query "[?name == '$(IDENTITY_NAME)'].principalId" --output tsv`" \
		--role '/subscriptions/$(SUB)/providers/Microsoft.Authorization/roleDefinitions/c12c1c16-33a1-487b-954d-41c89c60f349' \
		--scope '/subscriptions/$(SUB)/resourceGroups/$(RG)/providers/Microsoft.Storage/storageAccounts/$(STORAGE_ACCOUNT_NAME)'

