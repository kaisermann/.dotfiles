dirs="fish omf thefuck phpcbf"

[ ! -d ~/.myfiles.bk/.config/ ] && mkdir ~/.myfiles.bk/.config/
[ ! -d ~/.config/ ] && mkdir ~/.config/

printf "\n"
for dir in $dirs; do
  printf "${GREEN}>> Linking config '$dir' directory ${NC}\n"

  [ -L ~/.config/$dir ] && unlink ~/.config/$dir
  [ -d ~/.config/$dir ] && mv ~/.config/$dir ~/.myfiles.bk/.config/

	ln -svf $DOTFILES_DIR/content/config/$dir ~/.config/$dir
done
