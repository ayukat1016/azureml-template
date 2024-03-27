SUB ?= f9928460-8ada-4f70-983d-a98b5653e039
RG ?= dev-ml-template-rg101
TS_NAME ?= make_aml_ws
TS_VERSION ?= 1
USER_ADDR ?= sample@example.com

CONSUMER_SUB ?= 153a38d1-2342-4e80-a56a-c0b0ae9c7c50
CONSUMER_RG ?= dev-ml-template-rg201

# テンプレート仕様の定義ファイルを生成
.PHONY: gen-ts
gen-ts:
	echo "generating make_aml_ws.json"
	$(shell sh ./gen_ts.sh)

# サブスクリプション切替
.PHONY: set-subscription1
set-subscription1:
	az account set --subscription $(SUB)

# サブスクリプション切替
.PHONY: set-subscription2
set-subscription2:
	az account set --subscription $(CONSUMER_SUB)

# テンプレートスペックを登録
.PHONY: create-ts
create-ts: set-subscription1
	az ts create --name $(TS_NAME) --template-file ./make_aml_ws.json --version $(TS_VERSION) --resource-group $(RG) --subscription $(SUB)

# テンプレートスペックのjsonファイルから直接展開
.PHONY: create-deployment-group
create-deployment-group: set-subscription2
	az deployment group create --template-file ./make_aml_ws.json --resource-group $(CONSUMER_RG) --subscription $(CONSUMER_SUB)

# 利用者にテンプレートスペックの `閲覧者` ロールを付与
# 利用者にAMLレジストリの `閲覧者` ロールを付与
# 利用者にマネージドIDの `マネージドIDオペレータ` ロールを付与
.PHONY: create-role-assignment-user
create-role-assignment-user: set-subscription1
	az role assignment create \
		--assignee "`az ad user list --query "[?mail == '$(USER_ADDR)'].id" --output tsv`" \
		--role "/subscriptions/$(SUB)/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7" \
		--scope "/subscriptions/$(SUB)/resourceGroups/$(RG)/providers/Microsoft.Resources/templateSpecs/$(TS_NAME)"
	az role assignment create \
		--assignee "`az ad user list --query "[?mail == '$(USER_ADDR)'].id" --output tsv`" \
		--role '/subscriptions/$(SUB)/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7' \
		--scope '/subscriptions/$(SUB)/resourceGroups/$(RG)/providers/Microsoft.MachineLearningServices/registries/$(AML_REGISTRY)'
	az role assignment create \
		--assignee "`az ad user list --query "[?mail == '$(USER_ADDR)'].id" --output tsv`" \
		--role '/subscriptions/$(SUB)/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830' \
		--scope '/subscriptions/$(SUB)/resourcegroups/$(RG)/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$(IDENTITY_NAME)'
