# machine_learning

## Installs

```shell
sudo apt update
sudo apt-get install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev

# pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

source ~/.zshrc

pyenv install 3.9.16
pyenv global 3.9.16

pip install poetry

# Ubuntu22 の場合 poetry install するとエラーになる
# デフォルトでインストールされる LLVM v14 だと依存関係が解決できない
# python3-numba を予めインストールすると解決
sudo apt install python3-numba

# 依存関係をインストール
poetry install

# Install Azure CLI
# https://learn.microsoft.com/ja-jp/cli/azure/install-azure-cli-linux?pivots=apt
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Usage

```shell
# 静的解析
make vet

# MLモデル作成のコマンドをまとめて実行
make run

# 過去実行時のファイル削除の実行例
rm -rf ./tmp/*
rm -rf ./mlruns

# MLモデル作成のコマンド実行例
# 前処理
poetry run python -m src preprocess data tmp/X_train.csv tmp/X_test.csv tmp/y_train.csv tmp/y_test.csv
# 学習
poetry run python -m src train tmp/model tmp/X_train.csv tmp/y_train.csv
# 予測
poetry run python -m src predict tmp/model tmp/X_test.csv tmp/y_test_pred.csv
# 評価
poetry run python -m src evaluate tmp/y_test.csv tmp/y_test_pred.csv

# Docker image build
make docker_build

# Docker run
make docker_run

# Dockerコンテナ実行のコマンド実行例
docker run -it --rm -v $PWD:/app dev-ml-template-registry.azurecr.io/lightgbm:latest bash

# Dockerコンテナの中でのコマンド実行例
# 過去実行時のファイル削除
rm -rf ./tmp/*
rm -rf ./mlruns
# 前処理
python -m src preprocess data tmp/X_train.csv tmp/X_test.csv tmp/y_train.csv tmp/y_test.csv
# 学習
python -m src train tmp/model tmp/X_train.csv tmp/y_train.csv
# 予測
python -m src predict tmp/model tmp/X_test.csv tmp/y_test_pred.csv
# 評価
python -m src evaluate tmp/y_test.csv tmp/y_test_pred.csv

# Azure Container Registry へログイン
make acr_login

# Azure Container Registry へPush
# Makefile 内の REGISTRY_NAME は環境に合わせて変更する必要あり
make acr_push
```
