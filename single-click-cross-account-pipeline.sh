#!/usr/bin/env bash

echo -n "Enter ToolsAccount > "
read ToolsAccount
echo -n "Enter ToolsAccount ProfileName for AWS Cli operations> "
read ToolsAccountProfile
echo -n "Enter Dev Account > "
read DevAccount
echo -n "Enter DevAccount ProfileName for AWS Cli operations> "
read DevAccountProfile
echo -n "Enter Test Account > "
read TestAccount
echo -n "Enter TestAccount ProfileName for AWS Cli operations> "
read TestAccountProfile
echo -n "Enter Prod Account > "
read ProdAccount
echo -n "Enter ProdAccount ProfileName for AWS Cli operations> "
read ProdAccountProfile
echo -n "Deploying pre-requisite stack to the tools account... "
aws cloudformation deploy --stack-name pre-reqs --template-file ToolsAcct/pre-reqs.yaml --parameter-overrides DevAccount=$DevAccount TestAccount=$TestAccount ProductionAccount=$ProdAccount --profile $ToolsAccountProfile
echo -n "Fetching S3 bucket and CMK ARN from CloudFormation automatically..."
get_s3_command="aws cloudformation describe-stacks --stack-name pre-reqs --profile $ToolsAccountProfile --query \"Stacks[0].Outputs[?OutputKey=='ArtifactBucket'].OutputValue\" --output text"
S3Bucket=$(eval $get_s3_command)
echo -n "Got S3 bucket name: $S3Bucket"

get_cmk_command="aws cloudformation describe-stacks --stack-name pre-reqs --profile $ToolsAccountProfile --query \"Stacks[0].Outputs[?OutputKey=='CMK'].OutputValue\" --output text"
CMKArn=$(eval $get_cmk_command)
echo -n "Got CMK ARN: $CMKArn"

echo -n "Executing in DEV Account"
aws cloudformation deploy --stack-name toolsacct-codepipeline-role --template-file DevAccount/toolsacct-codepipeline-codecommit.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides ToolsAccount=$ToolsAccount CMKARN=$CMKArn --profile $DevAccountProfile

echo -n "Executing in TEST Account"
aws cloudformation deploy --stack-name toolsacct-codepipeline-cloudformation-role --template-file TestAccount/toolsacct-codepipeline-cloudformation-deployer.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides ToolsAccount=$ToolsAccount CMKARN=$CMKArn  S3Bucket=$S3Bucket --profile $TestAccountProfile

echo -n "Executing in PROD Account"
aws cloudformation deploy --stack-name toolsacct-codepipeline-cloudformation-role --template-file TestAccount/toolsacct-codepipeline-cloudformation-deployer.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides ToolsAccount=$ToolsAccount CMKARN=$CMKArn  S3Bucket=$S3Bucket --profile $ProdAccountProfile

echo -n "Creating Pipeline in Tools Account"
aws cloudformation deploy --stack-name sample-lambda-pipeline --template-file ToolsAcct/code-pipeline.yaml --parameter-overrides DevAccount=$DevAccount TestAccount=$TestAccount ProductionAccount=$ProdAccount CMKARN=$CMKArn S3Bucket=$S3Bucket --capabilities CAPABILITY_NAMED_IAM --profile $ToolsAccountProfile

echo -n "Adding Permissions to the CMK"
aws cloudformation deploy --stack-name pre-reqs --template-file ToolsAcct/pre-reqs.yaml --parameter-overrides CodeBuildCondition=true --profile $ToolsAccountProfile

echo -n "Adding Permissions to the Cross Accounts"
aws cloudformation deploy --stack-name sample-lambda-pipeline --template-file ToolsAcct/code-pipeline.yaml --parameter-overrides CrossAccountCondition=true --capabilities CAPABILITY_NAMED_IAM --profile $ToolsAccountProfile