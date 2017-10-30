files=".gitconfig .gitignore.global .bash_profile .dircolors .vimrc .vim"

printf "\n"
for file in $files; do
  printf "${GREEN}>> Linking '$file' file ${NC}\n"

  [ -L ~/$file ] && unlink ~/$file
  [ -f ~/$file ] && ${RM_CMD} ~/$file

  ln -svf $DOTFILES_DIR/content/home/$file ~/$file
done

printf "${RED}>> Remember to edit the '.gitconfig' file ${NC}\n"
open -e ~/.gitconfig
