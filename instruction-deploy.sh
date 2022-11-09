# Instalar rosa-cli
#
# hacer login 
rosa login
az configure
#
#
# creacion de roles
rosa create account-roles --mode auto --yes
rosa create ocm-role --mode auto --admin --yes
rosa create user-role --mode auto --yes
#
# Instalar desde cloud.redhat.com
#
# rosa create cluster --cluster-name demo-rosa --sts --mode auto --yes