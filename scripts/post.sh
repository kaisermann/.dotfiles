
printf "\n${GREEN}>> Configuring WP-CLI${NC}\n"
wp package install aaemnnosttv/wp-cli-dotenv-command

printf "\n${GREEN}>> Configuring python${NC}\n"
easy_install pip
pip install fabric Jinja2 pathspec autopep8 isort

printf "\n${GREEN}>> Configuring PHPCBF Standards${NC}\n"
phpcs --config-set installed_paths ~/.config/phpcbf/wpcs
