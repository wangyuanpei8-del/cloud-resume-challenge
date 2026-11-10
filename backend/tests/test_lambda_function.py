# Lambda 関数のユニットテスト
# moto で DynamoDB を偽物（モック）にするので、本物の AWS には一切アクセスしない
import importlib
import json
import os
import shlex
import sys

import boto3
import pytest
from moto import mock_aws

# backend/ フォルダを import できるようにする
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

TABLE_NAME = "visitor-count"


@pytest.fixture
def lambda_module(monkeypatch, tmp_path):
    # ダミーの認証情報とリージョン（本物の鍵は使わない）
    monkeypatch.setenv("AWS_DEFAULT_REGION", "ap-southeast-2")
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")

    # 実環境の設定・認証ファイルに依存せず、既存のプロファイル名は維持する。
    profiles = {
        os.environ.get(name)
        for name in ("AWS_PROFILE", "AWS_DEFAULT_PROFILE")
        if os.environ.get(name)
    }
    config = tmp_path / "config"
    config.write_text(
        "[default]\nregion = ap-southeast-2\n"
        + "".join(
            f"[profile {shlex.quote(profile)}]\nregion = ap-southeast-2\n"
            for profile in sorted(profiles)
        ),
        encoding="utf-8",
    )
    credentials = tmp_path / "credentials"
    credentials.write_text("", encoding="utf-8")
    monkeypatch.setenv("AWS_CONFIG_FILE", str(config))
    monkeypatch.setenv("AWS_SHARED_CREDENTIALS_FILE", str(credentials))

    with mock_aws():
        # 本番と同じ形のテーブルを偽の DynamoDB に作る
        boto3.client("dynamodb").create_table(
            TableName=TABLE_NAME,
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        # モックが有効になってから Lambda のコードを読み込む
        import lambda_function
        importlib.reload(lambda_function)
        yield lambda_function


def call(module):
    return module.lambda_handler({}, None)


def test_returns_200_and_json(lambda_module):
    response = call(lambda_module)
    assert response["statusCode"] == 200
    assert response["headers"]["Content-Type"] == "application/json"
    assert "count" in json.loads(response["body"])


def test_first_visit_is_1(lambda_module):
    body = json.loads(call(lambda_module)["body"])
    assert body["count"] == 1


def test_count_increases_by_1_each_call(lambda_module):
    counts = [json.loads(call(lambda_module)["body"])["count"] for _ in range(3)]
    assert counts == [1, 2, 3]


def test_count_is_saved_in_dynamodb(lambda_module):
    call(lambda_module)
    call(lambda_module)
    item = boto3.resource("dynamodb").Table(TABLE_NAME).get_item(Key={"id": "visitors"})["Item"]
    assert item["count"] == 2
