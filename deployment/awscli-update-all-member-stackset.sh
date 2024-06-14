#!/bin/bash
# This is an autogenerated file by sync-to-s3.sh
# Generated date and time: Fri Jun 14 09:02:08 EDT 2024
aws cloudformation update-stack-set --stack-set-name AWSControlTower-SHARR-Member --description "(SO0111) AWS Security Hub Automated Response & Remediation MEMBER Stack, automated-security-response-on-aws v2.1.1.cnxc.6" --template-url "https://sharr-deploy-645520830401-reference.s3.amazonaws.com/automated-security-response-on-aws/v2.1.1.cnxc.6/aws-sharr-member.template" --parameters ParameterKey=CreateS3BucketForRedshiftAuditLogging,UsePreviousValue=false,ParameterValue=no ParameterKey=LoadAFSBPMemberStack,UsePreviousValue=false,ParameterValue=no ParameterKey=LoadCIS120MemberStack,UsePreviousValue=false,ParameterValue=no ParameterKey=LoadCIS140MemberStack,UsePreviousValue=false,ParameterValue=no ParameterKey=LoadNIST80053MemberStack,UsePreviousValue=false,ParameterValue=no ParameterKey=LoadPCI321MemberStack,UsePreviousValue=false,ParameterValue=no ParameterKey=LoadSCMemberStack,UsePreviousValue=false,ParameterValue=yes ParameterKey=LogGroupName,UsePreviousValue=true ParameterKey=SecHubAdminAccount,UsePreviousValue=true --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --tags Key=Solution,Value=automated-security-response-on-aws Key=Version,Value=v2.1.1.cnxc.6 Key=App,Value=SHARR --operation-preferences FailureToleranceCount=49,MaxConcurrentCount=50,RegionConcurrencyType=PARALLEL --administration-role-arn arn:aws:iam::645520830401:role/service-role/AWSControlTowerStackSetRole --execution-role-name AWSControlTowerExecution --permission-model SELF_MANAGED --call-as SELF 
