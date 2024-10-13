import azure.functions as func
import datetime
import json
import logging

app = func.FunctionApp()

@app.function_name("FirstHTTPFunction")
@app.route(route="myroute", auth_level=func.AuthLevel.ANONYMOUS) ## this enables to run it without Auth keys on the cloud
def test_function(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")
    return func.HttpResponse(
        "Wow this first HTTP shit works girl!!!",
        status_code=200
    )

@app.function_name('SecondHTTPFunction')
@app.route(route="newroute")
def test_function(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Starting the second HTTP Function request.')
    
    name = req.params.get('name')
    if name:
        message = f"Hello, {name}, so glad this Function worked!!"
    else:
        message = "Hello, so glad this Function worked!!"
    return func.HttpResponse(
        message,
        status_code=200
    )
