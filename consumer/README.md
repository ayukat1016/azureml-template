# azコマンドによる手動デプロイ

- ワークスペース作成からジョブ実行までのazコマンドの実行手順を記載

## サブスクリプション切替
- サブスクリプション2の指定

```sh
# ログイン
az login
# サブスクリプション一覧を取得
az account list --output table
# 利用者（デプロイ先）のサブスクリプションを選択
az account set --subscription '153a38d1-2342-4e80-a56a-c0b0ae9c7c50'
```

## 新規ワークスペース登録

- 新規のリソースグループを作成
```sh
az group create --name 'dev-ml-template-rg203' --location 'japaneast'
```

- 新規のリソースグループを指定して、ワークスペースを作成
```sh
az ml workspace create --name 'dev-ml-template-ws203' --resource-group 'dev-ml-template-rg203'
```

- 参考
  - https://learn.microsoft.com/ja-jp/azure/machine-learning/how-to-manage-workspace-cli?tabs=createnewresources

## 新規コンピューティングリソース登録

-  Compute Clusterの登録

```sh
az ml compute create --type 'AmlCompute' --name 'cpu-cluster' --min-instances 0 --max-instances 1 --size 'Standard_DS11_v2' --resource-group 'dev-ml-template-rg203' --workspace-name 'dev-ml-template-ws203'
```

- 参考
    - https://learn.microsoft.com/ja-jp/cli/azure/ml/compute?view=azure-cli-latest#az-ml-compute-create
    - https://learn.microsoft.com/ja-jp/azure/machine-learning/v1/how-to-create-attach-compute-cluster?tabs=azure-cli
    - https://learn.microsoft.com/ja-jp/azure/machine-learning/how-to-create-attach-compute-cluster

## データの登録

- データ資産登録
```sh
az ml data create --type uri_folder --name 'dev-ml-template-dataset' --description 'dev-ml-template-dataset' --path './dataset' --resource-group 'dev-ml-template-rg203' --workspace-name 'dev-ml-template-ws203'
```

- 参考
  - https://learn.microsoft.com/ja-jp/azure/machine-learning/how-to-create-data-assets

## テンプレートジョブの登録

- ジョブ実行登録
```sh
az ml job create --file 'pipelines/pipeline.yml' --resource-group 'dev-ml-template-rg203' --workspace-name 'dev-ml-template-ws203'
```

- 参考
    - https://learn.microsoft.com/ja-jp/azure/machine-learning/how-to-share-models-pipelines-across-workspaces-with-registries?tabs=cli
    - https://learn.microsoft.com/ja-jp/azure/machine-learning/how-to-read-write-data-v2?tabs=cli


# ARMテンプレートによる自動デプロイ
## テンプレートスペックの作成

- 利用者がARMテンプレートを使ってデプロイできるようテンプレートスペックの作成方法を記載


### テンプレートスペックのjsonファイルにデプロイスクリプトを埋め込む

- 以下コマンドを叩くとARMテンプレートのjsonファイル `make_aml_ws_template.json` の `scriptContent` にシェル `deploy.sh` を埋め込んだjsonファイル `make_aml_ws.json` が生成される

- シェル `deploy.sh` は上記の手動実行のazコマンドを一覧化したもので、デプロイスクリプト `Microsoft.Resources/deploymentScripts` はユーザマネージドID `dev-ml-template-managedid` でシェル `deploy.sh` を実行する

- ARMテンプレートはデプロイスクリプト実行前にマネージドID `dev-ml-template-managedid` に対して、`Microsoft.Authorization/roleAssignments` でデプロイ先RGの `共同作成者` の権限を付与し、デプロイスクリプトはデプロイ先RGに書き込み可能にする（権限付与は `マネージドIDオペレーター` の権限を付与された利用者のみ可能）


```sh
make gen-ts
```

- 参考
  - https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/templates/deployment-script-template

  - https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/templates/template-tutorial-deployment-script?tabs=CLI

  - https://learn.microsoft.com/ja-jp/azure/role-based-access-control/role-assignments-template


### テンプレートスペックを登録
- 以下コマンドを叩くと提供者のリソースグループにデプロイ用のテンプレートスペック `make_aml_ws` が登録される

```sh
make create-ts
```

- azコマンドでも実行可能
```sh
az ts create --name 'make_aml_ws' --template-file './make_aml_ws.json' --version 1 --resource-group 'dev-ml-template-rg103' --subscription 'f9928460-8ada-4f70-983d-a98b5653e039'
```

## 利用者へのテンプレートスペック実行の権限追加
- 利用者は利用者のサブスクリプションに対して、 `所有者` の権限を持っていることを確認する（テンプレートスペック実行時にロールアサインメントでマネージドIDに `マネージドIDオペレーター` の権限を付与するので `共同作成者` の権限だと実行できない）

- 利用者に提供者サブスクリプションの以下リソースの権限を付与する
  - テンプレートスペックの `閲覧者`
  - AMLレジストリの `閲覧者`
  - マネージドIDの `マネージドIDオペレーター`

### 利用者へのテンプレートスペックの閲覧権限追加

- 利用者にテンプレートスペックの `閲覧者` のロールを付与する
- 結果、利用者はテンプレートスペックを照会でき、デプロイ画面まで進むことができる

```sh
# 利用者のプリンシパルID確認
az ad user list --query "[?mail == 'sample@example.com'].id" --output 'tsv'

# 利用者に テンプレートスペックの `閲覧者` ロールを付与
az role assignment create --assignee '利用者のプリンシパルID' --role '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7' --scope '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/resourceGroups/dev-ml-template-rg103/providers/Microsoft.Resources/templateSpecs/make_aml_ws'
```

- 以下コマンドを叩いても実行することも可能、実行前にmakeファイルのメールアドレスを変更すること

```sh
make create-role-assignment-user
```

### 利用者へのAMLレジストリの閲覧権限追加

- 利用者にAMLレジストリの `閲覧者` のロールを付与する
- 結果、利用者はAMLレジストリを照会できるようになる

```sh
# 利用者のプリンシパルID確認
az ad user list --query "[?mail == 'sample@example.com'].id" --output 'tsv'

# 利用者に AMLレジストリへの '閲覧者' ロールを付与
az role assignment create --assignee '利用者のプリンシパルID' --role '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7' --scope '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/resourceGroups/dev-ml-template-rg103/providers/Microsoft.MachineLearningServices/registries/dev-ml-template-registry103'
```

### 利用者へのマネージドIDの権限付与の権限追加

- 利用者にマネージドIDの `マネージドIDオペレーター` のロールを付与する
- 結果、利用者はテンプレートスペックのデプロイ実行時に、マネージドIDにデプロイ先RGの更新権限を付与できる


```sh
# 利用者のプリンシパルID確認
az ad user list --query "[?mail == 'sample@example.com'].id" --output 'tsv'

# 利用者に マネージドIDの `マネージドIDオペレータ` ロールを付与
az role assignment create --assignee '利用者のプリンシパルID' --role '/subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830' --scope 'subscriptions/f9928460-8ada-4f70-983d-a98b5653e039/resourcegroups/dev-ml-template-rg103/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-ml-template-managedid'
```
- 参考
  - https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/templates/deployment-script-template#configure-the-minimum-permissions


## テンプレートスペックを使ったデプロイ
- 利用者は提供者のリソースグループに作成されたデプロイ用のテンプレートスペック `make_aml_ws` を選択し、リソースグループ名とワークスペース名を指定して実行する。


## ARMテンプレートのjsonファイルを使ったデプロイ

- テンプレートスペックを使用せず、ARMテンプレートのjsonファイルを使って直接デプロイすることも可能

- 以下コマンドを叩くとjsonファイルから利用者のリソースグループにワークスペースがデプロイされる

```sh
make create-deployment-group
```

- azコマンドでも実行可能
```sh
az deployment group create --resource-group 'dev-ml-template-rg203' --template-file './make_aml_ws.json' --subscription '153a38d1-2342-4e80-a56a-c0b0ae9c7c50'
```

- 参考
  - https://learn.microsoft.com/ja-jp/azure/machine-learning/how-to-create-workspace-template?view=azureml-api-2&tabs=azcli
