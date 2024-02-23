import datetime
import json
import boto3
import uuid

def lambda_handler(event, context):
    # Get the current date and time
    current_datetime = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # DynamoDB table configuration
    dynamodb = boto3.resource('dynamodb')
    table_name = "tats_project_table"  # Replace with your actual DynamoDB table name
    table = dynamodb.Table(table_name)

    # Generate a UUID for each item
    unique_id = str(uuid.uuid4())

    # Prepare the item to be written to DynamoDB
    dynamodb_item = {
        'ID': unique_id,  # Replace with a unique identifier for each item 
        'DateTime': current_datetime, 
        'message': 'Your current datetime with ID {} is DateTime {}'.format(unique_id, current_datetime)
    }

    # Write the item to DynamoDB
    table.put_item(Item=dynamodb_item)

    # Prepare the response
    response = {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Your current datetime with ID {} is DateTime {}'.format(unique_id,current_datetime)
        })
    }

    return response

    