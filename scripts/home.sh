files=".gitconfig .gitignore.global .bash_profile .dircolors.256 .vimrc .vim"

printf "\n"
for file in $files; do
  printf "${GREEN}>> Linking '$file' file ${NC}\n"

  [ -L ~/$file ] && unlink ~/$file
  [ -f ~/$file ] && mv ~/$file ~/.myfiles.bk/

  ln -svf $DOTFILES_DIR/content/home/$file ~/$file
done

printf "${RED}>> Remember to edit your .gitconfig file ${NC}\n"
open -e ~/.gitconfig
