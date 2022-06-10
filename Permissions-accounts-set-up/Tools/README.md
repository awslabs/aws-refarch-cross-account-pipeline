# Purpose 

> Below steps are optional if your IAM user have not enough permissions cloudformation, s3 and kms services to create all required resources from
> [main script](../../single-click-cross-account-pipeline.sh) 
> Here we will configure permissions for tools account for IAM role only for this particular permission.

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
aws sts assume-role --role-arn "arn:aws:iam::{YOUR_TOOLS_ACCOUNT_ID}:role/aws-refarch-cross-account-pipeline-service-role-2" --role-session-name AWSCLI-Session --profile tools_admin
```

Example ouput:


- Paste the following text in your AWS credentials file (typically found at ~/.aws/credentials). 
```sh
[tools_admin_deployer]
aws_access_key_id = accessKeyIdValue
aws_secret_access_key = secretAccessKeyValue
aws_session_token = sessionTokenValue

```

- verify 
```sh
aws sts get-caller-identity --profile tools_admin_deployer
```
Example output
```json
{
    "UserId": "AROAVOS2MKF2GKH3OSZBB:AWSCLI-Session",
    "Account": "{YOUR_TOOLS_ACCOUNT_ID}",
    "Arn": "arn:aws:sts::{YOUR_TOOLS_ACCOUNT_ID}:assumed-role/aws-refarch-cross-account-pipeline-service-role-2/AWSCLI-Session"
}
```
# Finish

tools_admin_deployer name should be used as profile name for [main script](../../single-click-cross-account-pipeline.sh) 

# References

[Video abou STS](https://www.youtube.com/watch?v=-uogKFE1r60)

