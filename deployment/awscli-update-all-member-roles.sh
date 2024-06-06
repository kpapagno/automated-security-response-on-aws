#!/bin/bash
# This is an autogenerated file by sync-to-s3.sh
# Generated date and time: Thu Jun  6 11:27:45 EDT 2024
aws cloudformation update-stack-set --stack-set-name AWSControlTower-SHARR-MemberRoles --description "(SO0111) AWS Security Hub Automated Response & Remediation ROLES Stack, automated-security-response-on-aws v2.1.1.cnxc.3" --template-url "https://sharr-deploy-645520830401-reference.s3.amazonaws.com/automated-security-response-on-aws/v2.1.1.cnxc.3/aws-sharr-member-roles.template" --parameters ParameterKey=SecHubAdminAccount,UsePreviousValue=true --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --tags Key=Solution,Value=automated-security-response-on-aws Key=Version,Value=v2.1.1.cnxc.3 Key=App,Value=SHARR --operation-preferences FailureToleranceCount=49,MaxConcurrentCount=50,RegionConcurrencyType=PARALLEL --permission-model SERVICE_MANAGED --call-as SELF 
