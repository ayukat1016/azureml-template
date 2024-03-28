# azureml-template
本リポジトリはAzure Machine Learningの環境構築のテンプレートになります。テンプレートはAzure MLワークスペースで機械学習パイプラインを実行し、ダイヤモンド価格の予測モデルの前処理→学習→予測→評価を実行します。


## テンプレートの仕様
- 技術提供者が技術利用者にML技術の実行環境を提供する。
- 提供者と利用者は異なるサブスクリプションでもデプロイ可能とする。（同じサブスクリプションでも可）
- [provider/README.md](./provider/README.md)は提供者のサブスクリプションでの操作を想定
- [consumer/README.md](./consumer/README.md)は利用者のサブスクリプションでの操作を想定
- ML技術は[provider/machine_learning](./provider/machine_learning)で管理し、提供したいML技術をAzure MLレジストリに登録する。
- Azure MLワークスペースはAzure MLレジストリのコンポーネントを参照し、利用者に登録済みのML技術を提供する。
- Azure MLワークスペースはテンプレートスペックを実行して自動デプロイする。（azコマンドによる手動デプロイも可）
- テンプレートスペックは権限管理され、権限付与された利用者のみ実行可能。


## テンプレートの構成
- [provider](./provider)
    - 既存のリソースグループ `dev-ml-template-rg101` に新規レジストリ `dev-ml-template-registry101` を登録
    - 作成したレジストリに環境とコンポーネントを登録
    - ストレージアカウント`devmlst101`およびコンテナ`devmlstc101`を登録し、データおよびジョブ定義ファイルを格納
    - リソース名の末尾は1xxで管理
- [consumer](./consumer)
    - 新規のリソースグループ `dev-ml-template-rg201` を作成して、ワークスペース `dev-ml-template-ws201` を作成
    - テンプレートのジョブで使用するデータセットをデータ資産に登録
    - テンプレートのジョブを登録
    - リソース名の末尾は2xxで管理

 ## テンプレート実行の前提
 - Azureサブスクリプションを契約済み

 ## テンプレートの実行
- 本リポジトリのルートディレクトリに移動します。
```sh
# 現在のディレクトリの表示(「/xxx/repository」はユーザにより異なります。)
$ pwd
/home/xxx/repository/azureml-template
```
- [Makefile](./Makefile)の`template2work`のリソース連番の下2桁を変更して実行（同じリソース名で何度もリソースを作成すると挙動が不安定になるため）

- 以下は`01`から`14`に変更し場合で例示

```sh
# 連番を変更して、workにコピー
$ make template2work
rm -rf ./work
mkdir -p ./work
cp -rf consumer provider ./work
# aml registry rg
find ./work -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg101/dev-ml-template-rg114/g"
# aml registry name
find ./work -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-registry101/dev-ml-template-registry114/g"
# storage account name
find ./work -type f -print0 | xargs -0 sed -i -e "s/devmlst101/devmlst114/g"
# storage container name
find ./work -type f -print0 | xargs -0 sed -i -e "s/devmlstc101/devmlstc114/g"
# consumer rg
find ./work -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg201/dev-ml-template-rg214/g"
# workspace
find ./work -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-ws201/dev-ml-template-ws214/g"

```
- workの中のproviderディレクトリを移動して、[provider/README.md](./provider/README.md)のazコマンドを実行する。

```sh
# ディレクトリの移動
$ cd work/provider/

# ディレクトリの表示
$ pwd
/home/xxx/repository/azureml-template/work/provider
```

- workの中のconsumerディレクトリを移動して、[consumer/README.md](./provider/README.md)のazコマンドを実行する。

```sh
# ディレクトリの移動
$ cd work/consumer/

# ディレクトリの表示
$ pwd
/home/xxx/repository/azureml-template/work/consumer
```
