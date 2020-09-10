def hello_world(event):
    return f"Hello, World!"

def hello_bucket(event, context):
    return f"A new file was uploaded to the bucket"