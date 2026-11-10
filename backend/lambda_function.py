import json
from datetime import datetime, timedelta, timezone

import boto3

table = boto3.resource("dynamodb").Table("visitor-count")

JST = timezone(timedelta(hours=9))


def log_visit(event):
    # 誰がいつ見たかを CloudWatch Logs に 1 行で残す（IP は自分で確認する用、公開しない）
    http = (event.get("requestContext") or {}).get("http") or {}
    headers = event.get("headers") or {}
    print(json.dumps({
        "type": "visit",
        "time_jst": datetime.now(JST).strftime("%Y-%m-%d %H:%M:%S"),
        "ip": http.get("sourceIp"),
        "page": headers.get("referer"),
        "user_agent": http.get("userAgent"),
    }, ensure_ascii=False))


def lambda_handler(event, context):
    log_visit(event)
    # count を 1 増やして、新しい値を受け取る
    response = table.update_item(
        Key={"id": "visitors"},
        UpdateExpression="ADD #c :inc",
        ExpressionAttributeNames={"#c": "count"},
        ExpressionAttributeValues={":inc": 1},
        ReturnValues="UPDATED_NEW",
    )
    count = int(response["Attributes"]["count"])
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"count": count}),
    }
