#
# OGR profile
#
# /etc/profile.d/ogr.sh # sh extension required for loading.
#

if
  [ -n "${BASH_VERSION:-}" -o -n "${ZSH_VERSION:-}" ] &&
  test "`\command \ps -p $$ -o ucomm=`" != dash &&
  test "`\command \ps -p $$ -o ucomm=`" != sh
then
  ogr_bin_path="/usr/lib/postgresql/9.3/bin"
  # Add $ogr_bin_path to $PATH if necessary
  if [[ -n "${ogr_bin_path}" && ! ":${PATH}:" == *":${ogr_bin_path}:"* ]]
  then PATH="${PATH}:${ogr_bin_path}"
  fi
fi
