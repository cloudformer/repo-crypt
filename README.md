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

# convert tfvars -> json
hcl2json dev.tfvars > dev.json

# test AWS env and permission
CIPHERTEXT=$(aws kms encrypt \
  --key-id alias/Staging-repo-encrypt-key \
  --plaintext fileb://<(echo -n "test123") \
  --profile "$ENVIRONMENT_ADMIN_ROLE" \
  --output text --query CiphertextBlob)

aws kms decrypt \
  --ciphertext-blob fileb://<(echo "$CIPHERTEXT" | base64 --decode) \
  --profile "$ENVIRONMENT_ADMIN_ROLE" \
  --output text --query Plaintext | base64 --decode

# test sops kms
export AWS_PROFILE=ohstaging
SOPS_NO_CONFIG=1 sops -e \
  --kms "arn:aws:kms:ap-southeast-1:225989376155:key/1a09ab10-13eb-4325-8c09-f6be5da97214" \
  tmp.txt > tmp.txt.enc

SOPS_NO_CONFIG=1 sops -d tmp.txt.enc > tmp_decrypted.txt

https://devops.datenkollektiv.de/using-sops-with-age-and-git-like-a-pro.html