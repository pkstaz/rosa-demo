#!/bin/sh
#### WHEN YOU EXECUTE THIS, YOU CAN CHANGE VARIABLES ####
export CLUSTER_NAME=
export REGION=us-east-2
export PREFIX_NAME=
export AWS_SECRET_ACCESS_KEY=
export AWS_SECRET_ACCESS_KEY=

#### AWS ACCESS KEY ID ####
read -p "AWS ACCESS KEY ID: [$AWS_ACCESS_KEY_ID]: " awsid
AWS_ACCESS_KEY_ID=${awsid:-$AWS_ACCESS_KEY_ID}
echo 'your id' $AWS_ACCESS_KEY_ID

#### AWS ACCESS SECRET ID ####
read -p "AWS ACCESS SECRET ID: [$AWS_SECRET_ACCESS_KEY]: " awssecret
AWS_SECRET_ACCESS_KEY=${awssecret:-$AWS_SECRET_ACCESS_KEY}
echo 'your secret' $AWS_SECRET_ACCESS_KEY

#### CLUSTER NAME ####
read -p "Cluster Name: [$CLUSTER_NAME]: " name
CLUSTER_NAME=${name:-$CLUSTER_NAME}
echo 'your cluster named' $CLUSTER_NAME

#### ROLES PREFIX ####
read -p "Role Prefix: [$PREFIX_NAME]: " prefix
PREFIX_NAME=${prefix:-$PREFIX_NAME}
echo 'your role prefix' $PREFIX_NAME

#### INSTALL REGION ####
echo 'Regiones disponibles para instala ROSA HCP...'
rosa list regions --hosted-cp

read -p "Region ID: [$REGION]: " region
REGION=${region:-$REGION}
echo 'your region:' $REGION

git clone https://github.com/openshift-cs/terraform-vpc-example
cd terraform-vpc-example
terraform init
terraform plan -out rosa.tfplan -var region=$REGION -var cluster_name=$CLUSTER_NAME
terraform apply rosa.tfplan


export SUBNET_IDS=$(terraform output -raw cluster-subnets-string)
echo 'SUBNET_IDS: ' $SUBNET_IDS

rosa create account-roles --mode auto --hosted-cp --prefix $PREFIX_NAME --yes 

export OIDC_ID=$(rosa create oidc-config --mode auto --managed --yes -o json | jq -r '.id')
echo 'oidc_id:' $OIDC_ID

rosa create operator-roles --mode auto --hosted-cp --prefix $PREFIX_NAME --oidc-config-id $OIDC_ID --yes 
rosa create cluster --cluster-name=$CLUSTER_NAME --sts --mode=auto --hosted-cp --operator-roles-prefix $PREFIX_NAME --oidc-config-id $OIDC_ID --subnet-ids=$SUBNET_IDS

cd ..
rm -rf terraform-vpc-example/


echo 'Important facts to remember:'
echo 'Cluster Name:' $CLUSTER_NAME
echo 'OIDC ID:' $OIDC_ID
echo 'Prefix Name:' $PREFIX_NAME
