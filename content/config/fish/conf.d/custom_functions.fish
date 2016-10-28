
function reload
    source ~/.config/fish/config.fish
end

function ll
    ls -lhG $argv
end

function la
    ls -lahG $argv
end

function mvln --description "mvln src tgt"
  if math "2 ==" (count $argv) > /dev/null
    mv $argv[1] $argv[2]
    ln -sfv $argv[2] $argv[1]
  end
end
