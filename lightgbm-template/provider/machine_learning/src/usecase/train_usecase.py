import lightgbm as lgb
import mlflow
import pandas as pd
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import train_test_split

# https://mlflow.org/docs/latest/python_api/mlflow.lightgbm.html
# https://mlflow.org/docs/latest/python_api/mlflow.lightgbm.html#mlflow.lightgbm.autolog
# https://mlflow.org/docs/latest/python_api/mlflow.lightgbm.html#mlflow.lightgbm.save_model


class TrainUsecase:
    def __init__(self, model_path, X_train_path, y_train_path):
        self.model_path = model_path
        self.X_train_path = X_train_path
        self.y_train_path = y_train_path

    def execute(self):
        def print_auto_logged_info(run):
            tags = {k: v for k, v in run.data.tags.items() if not k.startswith("mlflow.")}
            artifacts = [
                f.path for f in mlflow.MlflowClient().list_artifacts(run.info.run_id, "model")
            ]
            feature_importances = [
                f.path
                for f in mlflow.MlflowClient().list_artifacts(run.info.run_id)
                if f.path != "model"
            ]
            print(f"run_id: {run.info.run_id}")
            print(f"artifacts: {artifacts}")
            print(f"feature_importances: {feature_importances}")
            print(f"params: {run.data.params}")
            print(f"metrics: {run.data.metrics}")
            print(f"tags: {tags}")

        # 学習データの読み込み
        X_train = pd.read_csv(self.X_train_path, index_col=0)
        y_train = pd.read_csv(self.y_train_path, index_col=0)
        print(X_train.head())
        print(y_train.head())

        # カテゴリ変数のデータ型をcategory型に変換
        cat_cols = ["cut", "color", "clarity"]

        for c in cat_cols:
            X_train[c] = X_train[c].astype("category")

        # 学習データの一部を検証データに分割
        X_tr, X_va, y_tr, y_va = train_test_split(X_train, y_train, test_size=0.2, shuffle=True, random_state=0)
        print("X_trの形状：", X_tr.shape, " y_trの形状：", y_tr.shape, " X_vaの形状：", X_va.shape, " y_vaの形状：", y_va.shape)

        # ハイパーパラメータの設定
        lgb_train = lgb.Dataset(X_tr, y_tr)
        lgb_eval = lgb.Dataset(X_va, y_va, reference=lgb_train)

        params = {
            "objective": "mae",
            "seed": 0,
            "verbose": -1,
        }

        # 誤差プロットの格納用データ
        evals_result = {}

        # mlflow 自動ログ
        mlflow.lightgbm.autolog()

        # モデルの学習
        with mlflow.start_run() as run:
            model = lgb.train(
                params,
                lgb_train,
                num_boost_round=10000,
                valid_sets=[lgb_train, lgb_eval],
                valid_names=["train", "valid"],
                callbacks=[lgb.early_stopping(100), lgb.log_evaluation(500), lgb.record_evaluation(evals_result)],
            )
        # 実験の出力
        print_auto_logged_info(mlflow.get_run(run_id=run.info.run_id))

        # 検証データの評価
        y_va_pred = model.predict(X_va, num_iteration=model.best_iteration)
        score = mean_absolute_error(y_va, y_va_pred)
        print(f"MAE valid: {score:.2f}")

        # モデルの保存
        mlflow.lightgbm.save_model(model, self.model_path)
