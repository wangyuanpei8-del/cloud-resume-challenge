import json
import boto3

table = boto3.resource("dynamodb").Table("visitor-count")

def lambda_handler(event, context):
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
