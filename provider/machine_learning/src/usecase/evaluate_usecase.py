import pandas as pd
from sklearn.metrics import mean_absolute_error


class EvaluateUsecase:
    def __init__(self, y_test_path, y_test_pred_path):
        self.y_test_path = y_test_path
        self.y_test_pred_path = y_test_pred_path

    def execute(self):
        # 実績と予測の読み込み
        y_test = pd.read_csv(self.y_test_path, index_col=0)
        y_test_pred = pd.read_csv(self.y_test_pred_path, index_col=0)

        print(y_test.head())
        print(y_test_pred.head())

        # 実績と予測の評価
        print("MAE test: %.2f" % (mean_absolute_error(y_test, y_test_pred)))
