import boto3


ssm_client = boto3.client('ssm')
res = ssm_client.get_parameter(Name='demo', WithDecryption=True)

msg = res['Parameter']['Value']


def lambda_handler(event, context):
    body = f'''
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="utf-8">
        <title>Amazon API-Cognito</title>
    </head>
    <body>
        <center><h1>{msg} Misgav </h1></center>
        <center><p>We're sorry but this application doesn't include JavaScript.</p></center>
    </body>
    </html>'''

    response = {
        'statusCode': 200,
        'headers': {"Content-Type": "text/html"},
        'body': body
    }

    return response
