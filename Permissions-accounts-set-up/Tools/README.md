# Purpose 

Here we will configure permissions for tools account

# Prereqisities

- AWS CLI insttalled
- URL for Organisation SSO Dashbard is known. It should be an output from step 4 from main ![](../../README.md)

# Configuration staps
- get programatic acess keys from tools account 
![](images/AWS-SSO-Dashboard.png)

- configure aws cli profile with ceredentials 
```sh
aws configure --profile tools
aws configure set aws_session_token "token_value_from_above_aws_sts_command" --profile tools

```

- verify identity
```sh
aws sts get-caller-identity --profile tools
```
- create IAM admin user
```sh
aws iam create-user --user-name admin --profile tools
```
- attach policy to user
```sh
aws iam create-policy --policy-name aws-refarch-cross-account-pipeline-sts-and-cloudformation-policy --policy-document file://Permissions-accounts-set-up/tools-admin-user-policy.json --profile tools
```
- attach policy to user
```sh
aws iam attach-user-policy --user-name admin  --policy-arn "arn:aws:iam::{tools_account_id}:policy/aws-refarch-cross-account-pipeline-sts-and-cloudformation-policy" --profile aleph_tools
```
- create IAM role
```sh
aws iam create-role --role-name aws-refarch-cross-account-pipeline-service-role --assume-role-policy-document file://Permissions-accounts-set-up/Tools/trust-relationship-policy.json
```
- attach policy to role
```sh
aws iam attach-role-policy --role-name aws-refarch-cross-account-pipeline-service-role --policy-arn "arn:aws:iam::374925447540:policy/aws-refarch-cross-account-pipeline-sts-and-cloudformation-policy" --profile tools
```
- verify 
```sh
aws iam list-attached-role-policies --role-name aws-refarch-cross-account-pipeline-service-role --profile tools
```
- create user credentials
```sh
aws iam create-access-key --user-name admin --profile tools_admin
```
- confi
```sh
aws configure
AWS Access Key ID [None]: ExampleAccessKeyID1
AWS Secret Access Key [None]: ExampleSecretKey1
Default region name [None]: eu-west-1
Default output format [None]: json
```
- verify
```sh
aws sts get-caller-identity --profile aleph_tools_admin
```
- asume role
```sh
aws sts assume-role --role-arn "arn:aws:iam::374925447540:role/aws-refarch-cross-account-pipeline-service-role-2" --role-session-name AWSCLI-Session --profile aleph_tools_admin
```
- export keys and tokens to environment variables
```sh
export AWS_ACCESS_KEY_ID=RoleAccessKeyID
export AWS_SECRET_ACCESS_KEY=RoleSecretKey
export AWS_SESSION_TOKEN=RoleSessionToken
```

# References

[Video abou STS](https://www.youtube.com/watch?v=-uogKFE1r60)

