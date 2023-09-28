import lightgbm as lgb
import mlflow
import pandas as pd
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import train_test_split

mlflow.lightgbm.autolog()


class TrainUsecase:
    def __init__(self, model_path, X_train_path, y_train_path):
        self.model_path = model_path
        self.X_train_path = X_train_path
        self.y_train_path = y_train_path

    def execute(self):
        # 学習データの読み込み
        X_train = pd.read_csv(self.X_train_path, index_col=0)
        y_train = pd.read_csv(self.y_train_path, index_col=0)
        print(X_train.head())
        print(y_train.head())

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

        # モデルの学習
        model = lgb.train(
            params,
            lgb_train,
            num_boost_round=10000,
            valid_sets=[lgb_train, lgb_eval],
            valid_names=["train", "valid"],
            callbacks=[lgb.early_stopping(100), lgb.log_evaluation(500), lgb.record_evaluation(evals_result)],
        )

        y_va_pred = model.predict(X_va, num_iteration=model.best_iteration)
        score = mean_absolute_error(y_va, y_va_pred)
        print(f"MAE valid: {score:.2f}")
        mlflow.lightgbm.save_model(model, self.model_path)
