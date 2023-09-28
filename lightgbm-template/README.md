# lightgbm_template

## [provider](./provider/README.md)

- AIIPFのサブスクリプションでの操作を想定

## [consumer](./consumer/README.md)

- 技術利用者のサブスクリプションでの操作を想定

## シナリオ

- provider
    - 提供者のサブスクリプション `f9928460-8ada-4f70-983d-a98b5653e039` を使用
    - 既存のリソースグループ `dev-ml-template-rg103` に新規レジストリ `dev-ml-template-registry103` を登録
    - 作成したレジストリに環境とコンポーネントを登録
    - ストレージアカウント`devmlst103`およびコンテナ`devmlstc103`を登録し、データおよびジョブ定義ファイルを格納
- consumer
    - 利用者のサブスクリプション `153a38d1-2342-4e80-a56a-c0b0ae9c7c50` を使用
    - 新規のリソースグループ `dev-ml-template-rg203` を作成して、ワークスペース `dev-ml-template-ws203` を作成
    - テンプレートのジョブで使用するデータセットをデータ資産に登録
    - テンプレートのジョブを登録
