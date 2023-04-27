function help() {
  cat <<- EOH

		Usage: ./$me [cmd...]

		img
		  build     : create USB disk image
		  write     : write disk image to USB

		vm
		  img
		    up      : boot VM from image disk
		    destroy : destroy image disk VM
		  usb
		    up      : boot VM from passthrough usb
		    destroy : destroy image disk VM

	EOH
}

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
me="$(basename ${BASH_SOURCE[0]})"

cmd0="$1" ; shift 1
if [ -z "$cmd0" ] ; then help ; exit 1 ; fi

case "$cmd0" in
'img')
  cmd1="$1" ; shift 1

  case "$cmd1" in
  'build')
    function _() {
      echo "TODO"
      # LOOP_DIR="$here/.loop_usb"
      # ZARF_PKG="$here/.downloads/zarf-package*"

      # $me vm destroy
      # rm -rf "$LOOP_DIR" "$ZARF_PKG"
      # $here/10_loop_usb.sh
    }
    time _
  ;;

  'write')
    function _() {
      echo "TODO"
    }
    time _
  ;;

  *) help ;;
  esac
;;  

'vm')
  cmd1="$1" ; shift 1

  case "$cmd1" in
  'img')
    cmd2="$1" ; shift 1
    POOL_DIR="$here/.loop_usb"
    POOL_NAME=$( basename "$POOL_DIR" )

    case "$cmd2" in
    'up')
      function _() {
        # create directory-based storage pool (if not exist)
        if ! $( virsh pool-list --name --all | grep --silent "$POOL_NAME" ) ; then
          virsh pool-define-as \
            --name "$POOL_NAME" \
            --type dir \
            --target "$POOL_DIR"
        fi
        if $( virsh pool-list --name --inactive | grep --silent "$POOL_NAME" ) ; then
          virsh pool-start "$POOL_NAME"
        fi

        VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant up
      }
      time _
    ;;  

    'destroy')
      function _() {
        VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant destroy -f

        # remove directory-based storage pool
        if $( virsh pool-list --name | grep --silent "$POOL_NAME" ) ; then
          virsh pool-destroy "$POOL_NAME"
        fi
        if $( virsh pool-list --name --all | grep --silent "$POOL_NAME" ) ; then
          virsh pool-undefine "$POOL_NAME"
        fi
      }
      time _
    ;;

    *) help ;;
    esac
  ;;

  'usb')
    cmd2="$1" ; shift 1

    case "$cmd2" in
    'up')
      function _() {
        echo "TODO"
      }
      time _
    ;;  

    'destroy')
      function _() {
        echo "TODO"
      }
      time _
    ;;

    *) help ;;
    esac
  ;;

  *) help ;;
  esac
;;

*) help ;;
esac

# 'img')
#     function _() {
#       VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant up
#     }
#     time _
#   ;;  

#   'img_dest')
#     function _() {
#       # add a new libvirt storage pool & put img in it before startup..?
#       # TODO
#       VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant destroy -f
#     }
#     time _
#   ;;