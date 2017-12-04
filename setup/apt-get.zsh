echo "Add SSH keys"
ssh-keygen -t rsa -b 4096 -C "siriniok@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
