dirs="fish omf thefuck phpcbf"

[ ! -d ~/.config/ ] && mkdir ~/.config/

printf "\n"
for dir in $dirs; do
  printf "${GREEN}>> Linking config '$dir' directory ${NC}\n"

  [ -L ~/.config/$dir ] && unlink ~/.config/$dir
  [ -d ~/.config/$dir ] && ${RM_CMD} ~/.config/$dir

	ln -svf $DOTFILES_DIR/content/config/$dir ~/.config/$dir
done
