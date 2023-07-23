import boto3
import datetime

# Initialize AWS clients
ssm_client = boto3.client('ssm')
dynamodb = boto3.resource('dynamodb')
s3 = boto3.resource('s3')

# import the table name from parameter stor
dynamodb_parameter = ssm_client.get_parameter(
    Name='dynamodb_table_name', WithDecryption=True)
table_name = dynamodb_parameter['Parameter']['Value']
table = dynamodb.Table(table_name)

bucket_name = 'cf-templates-9qfnmzt02w6g-us-east-1'


def upload_file_to_s3(bucket_name, file_name, file_content):
    bucket = s3.Bucket(bucket_name)
    bucket.put_object(Key=file_name, Body=file_content.encode('utf-8'))
    print(f"File '{file_name}' uploaded to '{bucket_name}'.")


def lambda_handler(event, context):
    try:
        user_name = event['userName']
        user_create_date = datetime.datetime.utcnow().isoformat()
        user_email = event['request']['userAttributes'].get(
            'email')  # Get the 'email' attribute if available

        # Prepare the item to be inserted into DynamoDB
        item = {
            'Email': user_email,
            'username': user_name,
            'UserCreateDate': user_create_date
        }

        # Put the item into DynamoDB
        table.put_item(Item=item)

        # Create the file content with the current time
        current_time = datetime.datetime.now().isoformat()
        file_content = current_time

        # Create the file name as "user_name.txt"
        file_name = f"{user_email}.txt"

        # Upload the file to the S3 bucket with the current time as its content
        upload_file_to_s3(bucket_name, file_name, file_content)

        return event
    except Exception as e:
        print('Error:', e)
        raise e
