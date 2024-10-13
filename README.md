# finance_tracker


## AZ FUNC APP

#### Cloud development

- content of terraform/ folder deploys function app resource
- it uses .zip package deployment, that does remote build (creating image during remote host runtime, using dependenices from requirements.txt and other configurations)
- remote deployment is recommended
- when cloud resources deployed, you can deploy even from local environment, rewriting the configuration asssembled by IaC (refer to the Az Function name in local publish command)

#### Local DEV
Create func project

```bash
func init MyFuncProject --python -m v2
```

Create virualenv

```bash
python -m venv .venv
```

Activate .venv

```bash
. ./.venv/bin/activate
```

Execute remote build (take content of a folder and publishes it on the fintrack-function-app azfunc service on the cloud)

```bash
func azure functionapp publish fintrack-function-app
```

Note: "AzureWebJobsStorage": "UseDevelopmentStorage=true" in `host.json` enables to use "local" storage, no need to setup Storage acc on cloud during development

### Hierarchy of the Auth keys, top -> down
-  `_master` - superadmin
-  `default` - to all functions all together
- `function keys` - per each function (its displayed with default name, but can be used only for the one particular func)

Correct urls with keys can be get from the portal - "Get Function URL"
To use in the requests, keys should be included in headers ....... "x-functions-key": "<function-key>"
