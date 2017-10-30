
printf "\n${GREEN}>> [WP-CLI] Configuring and installing extensions${NC}\n"
wp package install aaemnnosttv/wp-cli-dotenv-command
wp package install git@github.com:alwaysblank/blade-generate.git

printf "\n${GREEN}>> Installing PIP and PIP packages${NC}\n"
easy_install pip
pip install fabric Jinja2 pathspec autopep8 isort

printf "\n${GREEN}>> Configuring PHPCBF Standards${NC}\n"
phpcs --config-set installed_paths ~/.config/phpcbf/wpcs
