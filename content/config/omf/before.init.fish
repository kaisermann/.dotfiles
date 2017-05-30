# Adds all relevant paths
for p in /opt/bin /opt/local/bin ~/.config/fish/bin /usr/bin /usr/local/bin
	if test -d $p
		set -x PATH $p $PATH
	end
end
# Adds yarn's default global packages 'bin' path
command -v yarn > /dev/null; and set -x PATH (yarn global bin) $PATH

# Adds coreutils path
[ -d /usr/local/opt/coreutils/libexec/gnubin ]; and set -x PATH /usr/local/opt/coreutils/libexec/gnubin $PATH

# Adds NVM path
if test -d "/usr/local/opt/nvm"
  set -q NVM_DIR; or set -gx NVM_DIR ~/.nvm
end

set -g Z_SCRIPT_PATH /usr/local/etc/profile.d/z.sh
