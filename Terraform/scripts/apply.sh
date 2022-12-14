cd ../
# ls -a
echo "arg: $1"

if [[ "$1" == "dev" || "$1" == "stage" || "$1" == "prod" ]]; 
    then
        # echo "Plan n Apply for environement: $1"
        # terraform plan -var-file=terraform.$1.tfvars

        echo "Apply for environement: $1"
        terraform apply -var-file=terraform.$1.tfvars -auto-approve
    else
        echo "Wrong Argument"
        echo "Pass 'dev', 'stage' or 'prod' only."
fi 