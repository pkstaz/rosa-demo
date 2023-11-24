#!/bin/sh
export CLUSTER_NAME=
export PREFIX_NAME=
export OIDC_ID=

#### CLUSTER NAME ####
read -p "Cluster Name: [$CLUSTER_NAME]: " name
CLUSTER_NAME=${name:-$CLUSTER_NAME}
echo 'your cluster named' $CLUSTER_NAME

#### ROLES PREFIX ####
read -p "Role Prefix: [$PREFIX_NAME]: " prefix
PREFIX_NAME=${prefix:-$PREFIX_NAME}
echo 'your role prefix' $PREFIX_NAME

#### ROLES PREFIX ####
read -p "OIDC ID: [$OIDC_ID]: " oidcid
OIDC_ID=${oidcid:-$OIDC_ID}
echo 'OIDC ID' $OIDC_ID



# rosa delete cluster --cluster=$CLUSTER_NAME --yes 
rosa delete operator-roles --mode auto --prefix $PREFIX_NAME --yes 
rosa delete account-roles --prefix $PREFIX_NAME --yes --mode auto
rosa delete oidc-config --mode=auto  --yes --oidc-config-id=$OIDC_ID

rm -rf terraform-vpc-example/