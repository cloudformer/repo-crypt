# repo-crypt


# generate key
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# link env
mkdir -p "$HOME/Library/Application Support/sops"
ln -sfn ~/.config/sops/age \
  "$HOME/Library/Application Support/sops/age"

ls -ld "$HOME/Library/Application Support/sops/age"          # verify link env

# crypt
sops -e environment/prod.tfvars > environment/prod.tfvars.enc
rm environment/prod.tfvars   # 删除明文

# decode
sops -d environment/prod.tfvars.enc > environment/prod.tfvars

sops -e environment/config.json > environment/config.json.enc \
  && rm environment/config.json
sops -e environment/config.ymal > environment/config.ymal.enc \
  && rm environment/config.ymal
sops -e environment/prod.tfvars > environment/prod.tfvars.enc \
  && rm environment/prod.tfvars

sops -d environment/prod.tfvars.enc > environment/prod.tfvars
sops -d environment/config.json.enc > environment/config.json
sops -d environment/config.yaml.enc > environment/config.yaml