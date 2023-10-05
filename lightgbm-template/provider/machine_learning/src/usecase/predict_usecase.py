import mlflow
import pandas as pd

mlflow.lightgbm.autolog()


class PredictUsecase:
    def __init__(self, model_path, X_test_path, y_test_pred_path):
        self.model_path = model_path
        self.X_test_path = X_test_path
        self.y_test_pred_path = y_test_pred_path

    def execute(self):
        # データの読み込み
        X_test = pd.read_csv(self.X_test_path, index_col=0)
        print(X_test.head())

        # モデルの読み込み
        model = mlflow.lightgbm.load_model(self.model_path)

        # 予測の実行
        y_test_pred = model.predict(X_test)
        print(y_test_pred)

        # 予測の保存
        df_y_test_pred = pd.DataFrame(y_test_pred, columns=["Y_PRED"])
        df_y_test_pred.to_csv(self.y_test_pred_path)