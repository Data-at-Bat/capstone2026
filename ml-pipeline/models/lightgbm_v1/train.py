import pandas as pd
import lightgbm as lgb
from sklearn.model_selection import train_test_split

df = pd.read_csv("data/processed/model_dataset.csv")

X = df.drop(columns=["home_win"])
y = df["home_win"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

model = lgb.LGBMClassifier(
    n_estimators=500,
    learning_rate=0.01,
    num_leaves=31
)

model.fit(X_train, y_train)

print("Accuracy:", model.score(X_test, y_test))