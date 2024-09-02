source .env

az ad sp create-for-rbac --name deployment-app > ignored/spn.json
APP_ID=$(jq -r '.appId' ignored/spn.json)

az role assignment create --assignee $APP_ID \
                          --role Contributor \
                          --scope /subscriptions/$SUBSCRIPTION_ID

az ad app federated-credential create \
  --id $APP_ID \
  --parameters "{\"name\": \"autoDevelopmentFederatedCredential\", \"issuer\": \"https://token.actions.githubusercontent.com\", \"subject\": \"repo:vilamgmgh/finance_tracker:environment:development\", \"audiences\": [\"api://AzureADTokenExchange\"]}"