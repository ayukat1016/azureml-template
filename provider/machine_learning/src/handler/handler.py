from src.usecase.evaluate_usecase import EvaluateUsecase
from src.usecase.predict_usecase import PredictUsecase
from src.usecase.preprocess_usecase import PreprocessUsecase
from src.usecase.train_usecase import TrainUsecase


class Handler:
    def __init__(self):
        pass

    def preprocess(self, data, X_train, X_test, y_train, y_test):
        """
        前処理
        """
        PreprocessUsecase(data, X_train, X_test, y_train, y_test).execute()

    def train(self, model, X_train, y_train):
        """
        学習
        """
        TrainUsecase(model, X_train, y_train).execute()

    def predict(self, model, X_test, y_test_pred):
        """
        予測
        """
        PredictUsecase(model, X_test, y_test_pred).execute()

    def evaluate(self, y_test, y_test_pred):
        """
        評価
        """
        EvaluateUsecase(y_test, y_test_pred).execute()
