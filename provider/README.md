# AMLレジストリ作成

## [machine_learning](./machine_learning/README.md)

- Azure MLレジストリに環境(Environment)を登録するために `Dockerfile` を用意

- Azure MLレジストリにコンポーネント(component)を登録するために ソースコード `src` を用意

- Azure MLワークスペースにデータ（data）を登録するため、学習データ `data` を用意

## サブスクリプション切替
- サブスクリプション1の指定
```sh
# ログイン
az login
# サブスクリプション一覧を取得
az account list --output table
# 提供者のサブスクリプションを選択
az account set --subscription 'f9928460-8ada-4f70-983d-a98b5653e039'
```

## リソースグループ作成

- 新規のリソースグループを作成
```sh
# 作成
az group create --name 'dev-ml-template-rg101' --location 'japaneast'
# 一覧取得
az group list --output table
```

## Azure MLレジストリ新規作成

- Azure MLのレジストリを作成

```sh
az extension add --name ml
az ml registry create --file 'registry.yml' --name 'dev-ml-template-registry101' --resource-group 'dev-ml-template-rg101'
```

- 参考
  - https://learn.microsoft.com/ja-jp/azure/machine-learning/how-to-manage-registries?tabs=cli

## AMLレジストリに環境とコンポーネントを登録

- 環境を登録

```sh
# Dockerfileを build にコピー
mkdir -p 'build'
rm -rf 'build/*'
cp 'machine_learning/Dockerfile' 'build/'
cp 'machine_learning/pyproject.toml' 'build/'
cp 'machine_learning/poetry.lock' 'build/'

# 環境を登録
az ml environment create --file 'environment.yml' --registry-name 'dev-ml-template-registry101' --resource-group 'dev-ml-template-rg101'
```

- コンポーネントを登録
```sh
# MLソースコードを dist にコピー
mkdir -p 'dist'
rm -rf 'dist/*'
rsync -ahv 'machine_learning/src' 'dist' --exclude '__pycache__'

# コンポーネントを登録
az ml component create --file 'components/preprocess.yml' --registry-name 'dev-ml-template-registry101' --resource-group 'dev-ml-template-rg101'
az ml component create --file 'components/train.yml' --registry-name 'dev-ml-template-registry101' --resource-group 'dev-ml-template-rg101'
az ml component create --file 'components/predict.yml' --registry-name 'dev-ml-template-registry101' --resource-group 'dev-ml-template-rg101'
az ml component create --file 'components/evaluate.yml' --registry-name 'dev-ml-template-registry101' --resource-group 'dev-ml-template-rg101'
```

- 参考
  - https://learn.microsoft.com/ja-jp/azure/machine-learning/how-to-share-models-pipelines-across-workspaces-with-registries?tabs=cli


# デプロイに使用するリソースの作成

## ストレージアカウント/コンテナーの作成
- デプロイに使用するファイルを格納するコンテナを作成

```shell
# ストレージアカウント作成
az storage account create --name 'devmlst101' --resource-group 'dev-ml-template-rg101' --location 'japaneast' --sku 'Standard_ZRS' --encryption-services 'blob'

# コンテナー作成
az storage container create --name 'devmlstc101' --account-name 'devmlst101' --resource-group 'dev-ml-template-rg101' --auth-mode 'login'
```
## ファイルをコンテナーに登録

- コンテナに使用するファイルを登録

```shell
# データを dataset にコピー
mkdir -p 'dataset'
rm -rf 'dataset/*'
cp 'machine_learning/data/diamonds.csv' 'dataset/'

# データをコンテナに配置
az storage blob upload --file 'dataset/diamonds.csv' --name 'diamonds.csv' --container-name 'devmlstc101' --account-name 'devmlst101' --auth-mode 'login'

# パイプラインのテンプレートをコンテナに配置
az storage blob upload --file 'pipelines/pipeline_template.yml' --name 'pipeline_template.yml' --container-name 'devmlstc101' --account-name 'devmlst101' --auth-mode 'login'
```

## マネージドIDの作成及びロール付与
- テンプレートスペックのデプロイスクリプト実行に使用するマネージドIDを作成し、権限を付与する

```shell
# マネージドID作成
az identity create --name 'dev-ml-template-managedid' --resource-group 'dev-ml-template-rg101'

# マネージドIDのプリンシパルID確認
az identity list --query "[?name == 'dev-ml-template-managedid'].principalId" --resource-group 'dev-ml-template-rg101' --output 'tsv'

# マネージドIDに AMLレジストリの `閲覧者` ロールを付与
az role assignment create --assignee 'マネージドIDのプリンシパルID' --role '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7' --scope '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/resourceGroups/dev-ml-template-rg101/providers/Microsoft.MachineLearningServices/registries/dev-ml-template-registry101'

# マネージドIDに ストレージの `閲覧者とデータアクセス` ロールを付与
az role assignment create --assignee 'マネージドIDのプリンシパルID' --role '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/providers/Microsoft.Authorization/roleDefinitions/c12c1c16-33a1-487b-954d-41c89c60f349' --scope '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/resourceGroups/dev-ml-template-rg101/providers/Microsoft.Storage/storageAccounts/devmlst101'
```
