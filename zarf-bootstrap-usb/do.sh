function help() {
  cat <<- 'EOH'

		Available commands (iso/img):
		  ???       : TODO
		  ???       : TODO

		Available commands (vagrant):
		  img_up    : boot VM from image disk
		  img_dest  : destroy image disk VM

	EOH
}

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
me="$(basename ${BASH_SOURCE[0]})"

# function add_etc_hosts() {
#   local nm="$1"
#   local ip="$2"
#   local mark="# $here/$me"

#   echo "$ip $nm $mark" \
#     | sudo tee --append /etc/hosts > /dev/null
# }

# function clean_etc_hosts() {
#   local mark="# $here/$me"
#   local escaped="$( echo "$mark" | sed -e 's/[]\/$*.^[]/\\&/g' )"

#   sudo sed -i "/$escaped/d" /etc/hosts
# }

cmd="$1" ; shift 1
if [ -z "$cmd" ] ; then help ; exit 1 ; fi

case "$cmd" in
  'img_up')
    function _() {
      VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant up
    }
    time _
  ;;  

  'img_dest')
    function _() {
      # add a new libvirt storage pool & put img in it before startup..?
      # TODO
      VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant destroy -f
    }
    time _
  ;;

  *) help ;;
esac