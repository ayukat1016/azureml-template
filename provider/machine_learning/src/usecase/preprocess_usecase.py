import os

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder


class PreprocessUsecase:
    def __init__(self, data_path, X_train_path, X_test_path, y_train_path, y_test_path):
        self.data_path = data_path
        self.X_train_path = X_train_path
        self.X_test_path = X_test_path
        self.y_train_path = y_train_path
        self.y_test_path = y_test_path

    def execute(self):
        # データセットの読み込み
        print("files in input_data path: ")
        arr = os.listdir(self.data_path)
        print(arr)

        for filename in arr:
            print("reading file: %s ..." % filename)
            df = pd.read_csv(os.path.join(self.data_path, filename), index_col=0)
            print(df.shape)  # データの形状
            # print(df.head())  # 先頭5行

        # 外れ値除外の前処理
        df = df.drop(df[(df["x"] == 0) | (df["y"] == 0) | (df["z"] == 0)].index, axis=0)
        df = df.drop(df[(df["x"] >= 10) | (df["y"] >= 10) | (df["z"] >= 10)].index, axis=0)
        df.reset_index(inplace=True, drop=True)
        print(df.shape)
        # print(df.head())  # 先頭5行

        # 特徴量と目的変数の設定
        X = df.drop("price", axis=1)
        y = df["price"]
        print(X.head())
        print(y.head())

        # 学習データとテストデータの分割
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=True, random_state=0)
        print(
            "X_trainの形状：",
            X_train.shape,
            " y_trainの形状：",
            y_train.shape,
            " X_testの形状：",
            X_test.shape,
            " y_testの形状：",
            y_test.shape,
        )
        # print(X_train.head())
        # print(y_train.head())

        # カテゴリ変数のlabel encoding
        cat_cols = ["cut", "color", "clarity"]

        for c in cat_cols:
            le = LabelEncoder()
            le.fit(X_train[c])
            X_train[c] = le.transform(X_train[c])
            X_test[c] = le.transform(X_test[c])

        # 学習データとテストデータの保存
        X_train.to_csv(self.X_train_path)
        X_test.to_csv(self.X_test_path)
        y_train.to_csv(self.y_train_path)
        y_test.to_csv(self.y_test_path)
