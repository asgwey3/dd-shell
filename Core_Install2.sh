#!/bin/bash

## License: GPL
## This is the magically modified version of the one-click reload script.
## It can reinstall CentOS, Debian, Ubuntu and other Linux systems (continuously added) over the network in one click.
## It can reinstall Windwos 2003, 7, 2008R2, 2012R2, 2016, 2019 and other Windows systems (continuously added) via the network in one click.
## Support GRUB or GRUB2 for installing a clean minimal system.
## Technical support is provided by the CXT (CXTHHHHH.com). (based on the original version of Vicer)

## WebUI Modify version author:
## Default root password: Same as Magic Modified Version
## Written By Flyqie

## Magic Modify version author:
## Default root password: cxthhhhh.com
## WebSite: https://www.cxthhhhh.com
## Written By CXT (CXTHHHHH.com)

## Original version author:
## Blog: https://moeclub.org
## Written By Vicer (MoeClub.org)


export tmpVER=''
export tmpDIST=''
export tmpURL=''
export tmpWORD=''
export tmpMirror=''
export tmpSSL=''
export tmpINS=''
export ipAddr=''
export ipMask=''
export ipGate=''
export ipDNS='8.8.8.8'
export IncDisk='default'
export interface=''
export interfaceSelect=''
export Relese=''
export sshPORT='22'
export ddMode='0'
export setNet='0'
export setRDP='0'
export setIPv6='0'
export isMirror='0'
export FindDists='0'
export loaderMode='0'
export IncFirmware='0'
export SpikCheckDIST='0'
export setInterfaceName='0'
export UNKNOWHW='0'
export UNVER='6.4'
# --- Flyqie ---
export ddWebBinUrl='https://github.com/asgwey3/dd-web/releases/download/1/dd-WEB-binary'
export retryNum='0'
export errorExit=''
export successExit='-successexit'
export ddWebAddr='0.0.0.0:2333'
export ddWebAuthKey=''
# --- Flyqie ---

while [[ $# -ge 1 ]]; do
  case $1 in
    -v|--ver)
      shift
      tmpVER="$1"
      shift
      ;;
    # --- Flyqie ---
    --retry-num)
      shift
      retryNum="$1"
      shift
      ;;
    --with-error-exit)
      shift
      errorExit='-errorexit'
      ;;
    --without-success-exit)
      shift
      successExit=''
      ;;
    --dd-web-addr)
      shift
      ddWebAddr="$1"
      shift
      ;;
    --dd-web-authkey)
      shift
      ddWebAuthKey="$1"
      shift
      ;;
    --dd-web-bin-url)
      shift
      ddWebBinUrl="$1"
      shift
      ;;
    # --- Flyqie ---
    -d|--debian)
      shift
      Relese='Debian'
      tmpDIST="$1"
      shift
      ;;
    -u|--ubuntu)
      shift
      Relese='Ubuntu'
      tmpDIST="$1"
      shift
      ;;
    -c|--centos)
      shift
      Relese='CentOS'
      tmpDIST="$1"
      shift
      ;;
    -dd|--image)
      shift
      ddMode='1'
      tmpURL="$1"
      shift
      ;;
    -p|--password)
      shift
      tmpWORD="$1"
      shift
      ;;
    -i|--interface)
      shift
      interface="$1"
      shift
      ;;
    --ip-addr)
      shift
      ipAddr="$1"
      shift
      ;;
    --ip-mask)
      shift
      ipMask="$1"
      shift
      ;;
    --ip-gate)
      shift
      ipGate="$1"
      shift
      ;;
    --ip-dns)
      shift
      ipDNS="$1"
      shift
      ;;
    --dev-net)
      shift
      setInterfaceName='1'
      ;;
    --loader)
      shift
      loaderMode='1'
      ;;
    --prefer)
      shift
      tmpPrefer="$1"
      shift
      ;;
    -a|--auto)
      shift
      tmpINS='auto'
      ;;
    -m|--manual)
      shift
      tmpINS='manual'
      ;;
    -apt|-yum|--mirror)
      shift
      isMirror='1'
      tmpMirror="$1"
      shift
      ;;
    -rdp)
      shift
      setRDP='1'
      WinRemote="$1"
      shift
      ;;
    -cmd)
      shift
      setCMD="$1"
      shift
      ;;
    -console)
      shift
      setConsole="$1"
      shift
      ;;
    -firmware)
      shift
      IncFirmware="1"
      ;;
    -port)
      shift
      sshPORT="$1"
      shift
      ;;
    --noipv6)
      shift
      setIPv6='1'
      ;;
    -a|--auto|-m|--manual|-ssl)
      shift
      ;;
    *)
      if [[ "$1" != 'error' ]]; then echo -ne "\nInvaild option: '$1'\n\n"; fi
      echo -ne " Usage:\n\tbash $(basename $0)\t-d/--debian [\033[33m\033[04mdists-name\033[0m]\n\t\t\t\t-u/--ubuntu [\033[04mdists-name\033[0m]\n\t\t\t\t-c/--centos [\033[04mdists-name\033[0m]\n\t\t\t\t-v/--ver [32/i386|64/\033[33m\033[04mamd64\033[0m] [\033[33m\033[04mdists-verison\033[0m]\n\t\t\t\t--ip-addr/--ip-gate/--ip-mask\n\t\t\t\t-apt/-yum/--mirror\n\t\t\t\t-dd/--image\n\t\t\t\t-p [linux password]\n\t\t\t\t-port [linux ssh port]\n"
      exit 1;
      ;;
    esac
  done

[[ "$EUID" -ne '0' ]] && echo "Error:This script must be run as root!" && exit 1;

function dependence(){
  Full='0';
for BIN_DEP in `echo "$1" |sed 's/,/\n/g'`
  do
    if [[ -n "$BIN_DEP" ]]; then
        Found='0';
      for BIN_PATH in `echo "$PATH" |sed 's/:/\n/g'`
        do
          ls $BIN_PATH/$BIN_DEP >/dev/null 2>&1;
          if [ $? == '0' ]; then
              Found='1';
            break;
          fi
        done
        if [ "$Found" == '1' ]; then
        echo -en "[\033[32mok\033[0m]\t";
      else
          Full='1';
        echo -en "[\033[31mNot Install\033[0m]";
      fi
      echo -en "\t$BIN_DEP\n";
    fi
  done
  if [ "$Full" == '1' ]; then
  echo -ne "\n\033[31mError! \033[0mPlease use '\033[33mapt-get\033[0m' or '\033[33myum\033[0m' install it.\n\n\n"
  exit 1;
fi
}

function selectMirror(){
  [ $# -ge 3 ] || exit 1
  Relese=$(echo "$1" |sed -r 's/(.*)/\L\1/')
  DIST=$(echo "$2" |sed 's/\ //g' |sed -r 's/(.*)/\L\1/')
  VER=$(echo "$3" |sed 's/\ //g' |sed -r 's/(.*)/\L\1/')
  New=$(echo "$4" |sed 's/\ //g')
  [ -n "$Relese" ] && [ -n "$DIST" ] && [ -n "$VER" ] || exit 1
  if [ "$Relese" == "debian" ] || [ "$Relese" == "ubuntu" ]; then
    [ "$DIST" == "focal" ] && legacy="legacy-" || legacy=""
    TEMP="SUB_MIRROR/dists/${DIST}/main/installer-${VER}/current/${legacy}images/netboot/${Relese}-installer/${VER}/initrd.gz"
  elif [ "$Relese" == "centos" ]; then
    TEMP="SUB_MIRROR/${DIST}/os/${VER}/isolinux/initrd.img"
  fi
  [ -n "$TEMP" ] || exit 1
  mirrorStatus=0
  declare -A MirrorBackup
  MirrorBackup=(["debian0"]="" ["debian1"]="http://deb.debian.org/debian" ["debian2"]="http://archive.debian.org/debian" ["ubuntu0"]="" ["ubuntu1"]="http://archive.ubuntu.com/ubuntu" ["ubuntu2"]="http://ports.ubuntu.com" ["centos0"]="" ["centos1"]="http://mirror.centos.org/centos" ["centos2"]="http://vault.centos.org")
  echo "$New" |grep -q '^http://\|^https://\|^ftp://' && MirrorBackup[${Relese}0]="$New"
  for mirror in $(echo "${!MirrorBackup[@]}" |sed 's/\ /\n/g' |sort -n |grep "^$Relese")
    do
      Current="${MirrorBackup[$mirror]}"
      [ -n "$Current" ] || continue
      MirrorURL=`echo "$TEMP" |sed "s#SUB_MIRROR#${Current}#g"`
      wget --no-check-certificate --spider --timeout=3 -o /dev/null "$MirrorURL"
      [ $? -eq 0 ] && mirrorStatus=1 && break
    done
  [ $mirrorStatus -eq 1 ] && echo "$Current" || exit 1
}

function netmask() {
  n="${1:-32}"
  b=""
  m=""
  for((i=0;i<32;i++)){
    [ $i -lt $n ] && b="${b}1" || b="${b}0"
  }
  for((i=0;i<4;i++)){
    s=`echo "$b"|cut -c$[$[$i*8]+1]-$[$[$i+1]*8]`
    [ "$m" == "" ] && m="$((2#${s}))" || m="${m}.$((2#${s}))"
  }
  echo "$m"
}

function getInterface(){
  interface=""
  Interfaces=`cat /proc/net/dev |grep ':' |cut -d':' -f1 |sed 's/\s//g' |grep -iv '^lo\|^sit\|^stf\|^gif\|^dummy\|^vmnet\|^vir\|^gre\|^ipip\|^ppp\|^bond\|^tun\|^tap\|^ip6gre\|^ip6tnl\|^teql\|^ocserv\|^vpn'`
  defaultRoute=`ip route show default |grep "^default"`
  for item in `echo "$Interfaces"`
    do
      [ -n "$item" ] || continue
      echo "$defaultRoute" |grep -q "$item"
      [ $? -eq 0 ] && interface="$item" && break
    done
  echo "$interface"
}

function getDisk(){
  disks=`lsblk | sed 's/[[:space:]]*$//g' |grep "disk$" |cut -d' ' -f1 |grep -v "fd[0-9]*\|sr[0-9]*" |head -n1`
  [ -n "$disks" ] || echo ""
  echo "$disks" |grep -q "/dev"
  [ $? -eq 0 ] && echo "$disks" || echo "/dev/$disks"
}

function diskType(){
  echo `udevadm info --query all "$1" 2>/dev/null |grep 'ID_PART_TABLE_TYPE' |cut -d'=' -f2`
}

function getGrub(){
  Boot="${1:-/boot}"
  folder=`find "$Boot" -type d -name "grub*" 2>/dev/null |head -n1`
  [ -n "$folder" ] || return
  fileName=`ls -1 "$folder" 2>/dev/null |grep '^grub.conf$\|^grub.cfg$'`
  if [ -z "$fileName" ]; then
    ls -1 "$folder" 2>/dev/null |grep -q '^grubenv$'
    [ $? -eq 0 ] || return
    folder=`find "$Boot" -type f -name "grubenv" 2>/dev/null |xargs dirname |grep -v "^$folder" |head -n1`
    [ -n "$folder" ] || return
    fileName=`ls -1 "$folder" 2>/dev/null |grep '^grub.conf$\|^grub.cfg$'`
  fi
  [ -n "$fileName" ] || return
  [ "$fileName" == "grub.cfg" ] && ver="0" || ver="1"
  echo "${folder}:${fileName}:${ver}"
}

function lowMem(){
  mem=`grep "^MemTotal:" /proc/meminfo 2>/dev/null |grep -o "[0-9]*"`
  [ -n "$mem" ] || return 0
  [ "$mem" -le "524288" ] && return 1 || return 0
}

if [[ "$loaderMode" == "0" ]]; then
  Grub=`getGrub "/boot"`
  [ -z "$Grub" ] && echo -ne "Error! Not Found grub.\n" && exit 1;
  GRUBDIR=`echo "$Grub" |cut -d':' -f1`
  GRUBFILE=`echo "$Grub" |cut -d':' -f2`
  GRUBVER=`echo "$Grub" |cut -d':' -f3`
fi

[ -n "$Relese" ] || Relese='Debian'
linux_relese=$(echo "$Relese" |sed 's/\ //g' |sed -r 's/(.*)/\L\1/')
clear && echo -e "\n\033[36m# Check Dependence\033[0m\n"

if [[ "$ddMode" == '1' ]]; then
  dependence iconv;
  linux_relese='debian';
  tmpDIST='bullseye';
  tmpVER='amd64';
fi

[ -n "$ipAddr" ] && [ -n "$ipMask" ] && [ -n "$ipGate" ] && setNet='1';
if [ "$setNet" == "0" ]; then
  dependence ip
  [ -n "$interface" ] || interface=`getInterface`
  iAddr=`ip addr show dev $interface |grep "inet.*" |head -n1 |grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,2\}'`
  echo "$iAddr" |grep '^10\.' |grep '/32$' >/dev/null && iAddr=`echo "$iAddr" |sed 's/\/32/\/24/'` # Fix GCP
  ipAddr=`echo ${iAddr} |cut -d'/' -f1`
  ipMask=`netmask $(echo ${iAddr} |cut -d'/' -f2)`
  ipGate=`ip route show default |grep "^default" |grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' |head -n1`
fi
if [ -z "$interface" ]; then
    dependence ip
    [ -n "$interface" ] || interface=`getInterface`
fi
IPv4="$ipAddr"; MASK="$ipMask"; GATE="$ipGate";

[ -n "$IPv4" ] && [ -n "$MASK" ] && [ -n "$GATE" ] && [ -n "$ipDNS" ] || {
  echo -ne '\nError: Invalid network config\n\n'
  bash $0 error;
  exit 1;
}

if [[ "$Relese" == 'Debian' ]] || [[ "$Relese" == 'Ubuntu' ]]; then
  dependence wget,awk,grep,sed,cut,cat,lsblk,cpio,gzip,find,dirname,basename;
elif [[ "$Relese" == 'CentOS' ]]; then
  dependence wget,awk,grep,sed,cut,cat,lsblk,cpio,gzip,find,dirname,basename,file,xz;
fi
[ -n "$tmpWORD" ] && dependence openssl
[[ -n "$tmpWORD" ]] && myPASSWORD=`openssl passwd -1 "$tmpWORD"`;
[[ -z "$myPASSWORD" ]] && myPASSWORD='$1$4BJZaD0A$y1QykUnJ6mXprENfwpseH0';

tempDisk=`getDisk`; [ -n "$tempDisk" ] && IncDisk="$tempDisk"

case `uname -m` in aarch64|arm64) VER="arm64";; x86|i386|i686) VER="i386";; x86_64|amd64) VER="amd64";; *) VER="";; esac
  tmpVER="$(echo "$tmpVER" |sed -r 's/(.*)/\L\1/')";
if [[ "$VER" != "arm64" ]] && [[ -n "$tmpVER" ]]; then
  case "$tmpVER" in i386|i686|x86|32) VER="i386";; amd64|x86_64|x64|64) [[ "$Relese" == 'CentOS' ]] && VER='x86_64' || VER='amd64';; *) VER='';; esac
fi

if [[ ! -n "$VER" ]]; then
  echo "Error! Not Architecture."
  bash $0 error;
  exit 1;
fi

if [[ -z "$tmpDIST" ]]; then
  [ "$Relese" == 'Debian' ] && tmpDIST='buster';
  [ "$Relese" == 'Ubuntu' ] && tmpDIST='bionic';
  [ "$Relese" == 'CentOS' ] && tmpDIST='6.10';
fi

if [[ -n "$tmpDIST" ]]; then
  if [[ "$Relese" == 'Debian' ]]; then
    SpikCheckDIST='0'
    DIST="$(echo "$tmpDIST" |sed -r 's/(.*)/\L\1/')";
    echo "$DIST" |grep -q '[0-9]';
    [[ $? -eq '0' ]] && {
      isDigital="$(echo "$DIST" |grep -o '[\.0-9]\{1,\}' |sed -n '1h;1!H;$g;s/\n//g;$p' |cut -d'.' -f1)";
      [[ -n $isDigital ]] && {
        [[ "$isDigital" == '7' ]] && DIST='wheezy';
        [[ "$isDigital" == '8' ]] && DIST='jessie';
        [[ "$isDigital" == '9' ]] && DIST='stretch';
        [[ "$isDigital" == '10' ]] && DIST='buster';
        [[ "$isDigital" == '11' ]] && DIST='bullseye';
        [[ "$isDigital" == '12' ]] && DIST='bookworm';
      }
    }
    LinuxMirror=$(selectMirror "$Relese" "$DIST" "$VER" "$tmpMirror")
  fi
  if [[ "$Relese" == 'Ubuntu' ]]; then
    SpikCheckDIST='0'
    DIST="$(echo "$tmpDIST" |sed -r 's/(.*)/\L\1/')";
    echo "$DIST" |grep -q '[0-9]';
    [[ $? -eq '0' ]] && {
      isDigital="$(echo "$DIST" |grep -o '[\.0-9]\{1,\}' |sed -n '1h;1!H;$g;s/\n//g;$p')";
      [[ -n $isDigital ]] && {
        [[ "$isDigital" == '12.04' ]] && DIST='precise';
        [[ "$isDigital" == '14.04' ]] && DIST='trusty';
        [[ "$isDigital" == '16.04' ]] && DIST='xenial';
        [[ "$isDigital" == '18.04' ]] && DIST='bionic';
        [[ "$isDigital" == '20.04' ]] && DIST='focal';
        # [[ "$isDigital" == '22.04' ]] && DIST='jammy';
      }
    }
    LinuxMirror=$(selectMirror "$Relese" "$DIST" "$VER" "$tmpMirror")
  fi
  if [[ "$Relese" == 'CentOS' ]]; then
    SpikCheckDIST='1'
    DISTCheck="$(echo "$tmpDIST" |grep -o '[\.0-9]\{1,\}' |head -n1)";
    LinuxMirror=$(selectMirror "$Relese" "$DISTCheck" "$VER" "$tmpMirror")
    ListDIST="$(wget --no-check-certificate -qO- "$LinuxMirror/dir_sizes" |cut -f2 |grep '^[0-9]')"
    DIST="$(echo "$ListDIST" |grep "^$DISTCheck" |head -n1)"
    [[ -z "$DIST" ]] && {
      echo -ne '\nThe dists version not found in this mirror, Please check it! \n\n'
      bash $0 error;
      exit 1;
    }
    wget --no-check-certificate -qO- "$LinuxMirror/$DIST/os/$VER/.treeinfo" |grep -q 'general';
    [[ $? != '0' ]] && {
        echo -ne "\nThe version not found in this mirror, Please change mirror try again! \n\n";
        exit 1;
    }
  fi
fi

if [[ -z "$LinuxMirror" ]]; then
  echo -ne "\033[31mError! \033[0mInvaild mirror! \n"
  [ "$Relese" == 'Debian' ] && echo -en "\033[33mexample:\033[0m http://deb.debian.org/debian\n\n";
  [ "$Relese" == 'Ubuntu' ] && echo -en "\033[33mexample:\033[0m http://archive.ubuntu.com/ubuntu\n\n";
  [ "$Relese" == 'CentOS' ] && echo -en "\033[33mexample:\033[0m http://mirror.centos.org/centos\n\n";
  bash $0 error;
  exit 1;
fi

if [[ "$SpikCheckDIST" == '0' ]]; then
  DistsList="$(wget --no-check-certificate -qO- "$LinuxMirror/dists/" |grep -o 'href=.*/"' |cut -d'"' -f2 |sed '/-\|old\|Debian\|experimental\|stable\|test\|sid\|devel/d' |grep '^[^/]' |sed -n '1h;1!H;$g;s/\n//g;s/\//\;/g;$p')";
  for CheckDEB in `echo "$DistsList" |sed 's/;/\n/g'`
    do
      [[ "$CheckDEB" == "$DIST" ]] && FindDists='1' && break;
    done
  [[ "$FindDists" == '0' ]] && {
    echo -ne '\nThe dists version not found, Please check it! \n\n'
    bash $0 error;
    exit 1;
  }
fi

if [[ "$ddMode" == '1' ]]; then
  if [[ -n "$tmpURL" ]]; then
    DDURL="$tmpURL"
    echo "$DDURL" |grep -q '^http://\|^ftp://\|^https://';
    [[ $? -ne '0' ]] && echo 'Please input vaild URL,Only support http://, ftp:// and https:// !' && exit 1;
    [[ -n "$tmpSSL" ]] && SSL_SUPPORT="$tmpSSL";
  else
    echo 'Please input vaild image URL! ';
    exit 1;
  fi
fi

clear && echo -e "\n\033[36m# Install\033[0m\n"

ASKVNC(){
  inVNC='y';
  [[ "$ddMode" == '0' ]] && {
    echo -ne "\033[34mDo you want to install os manually?\033[0m\e[33m[\e[32my\e[33m/n]\e[0m "
    read tmpinVNC
    [[ -n "$inVNCtmp" ]] && inVNC="$tmpinVNC"
  }
  [ "$inVNC" == 'y' -o "$inVNC" == 'Y' ] && inVNC='y';
  [ "$inVNC" == 'n' -o "$inVNC" == 'N' ] && inVNC='n';
}

[ "$inVNC" == 'y' -o "$inVNC" == 'n' ] || ASKVNC;
[[ "$ddMode" == '0' ]] && { 
  [[ "$inVNC" == 'y' ]] && echo -e "\033[34mManual Mode\033[0m insatll [\033[33m$Relese\033[0m] [\033[33m$DIST\033[0m] [\033[33m$VER\033[0m] in VNC. "
  [[ "$inVNC" == 'n' ]] && echo -e "\033[34mAuto Mode\033[0m insatll [\033[33m$Relese\033[0m] [\033[33m$DIST\033[0m] [\033[33m$VER\033[0m]. "
}
[[ "$ddMode" == '1' ]] && {
  echo -ne "\033[34mAuto Mode\033[0m insatll \033[33mWindows\033[0m\n[\033[33m$DDURL\033[0m]\n"
}

if [[ "$linux_relese" == 'centos' ]]; then
  if [[ "$DIST" != "$UNVER" ]]; then
    awk 'BEGIN{print '${UNVER}'-'${DIST}'}' |grep -q '^-'
    if [ $? != '0' ]; then
      UNKNOWHW='1';
      echo -en "\033[33mThe version lower then \033[31m$UNVER\033[33m may not support in auto mode! \033[0m\n";
      if [[ "$inVNC" == 'n' ]]; then
        echo -en "\033[35mYou can connect VNC with \033[32mPublic IP\033[35m and port \033[32m1\033[35m/\033[32m5901\033[35m in vnc viewer.\033[0m\n"
        read -n 1 -p "Press Enter to continue..." INP
        [[ "$INP" != '' ]] && echo -ne '\b \n\n';
      fi
    fi
    awk 'BEGIN{print '${UNVER}'-'${DIST}'+0.59}' |grep -q '^-'
    if [ $? == '0' ]; then
      echo -en "\n\033[31mThe version higher then \033[33m6.10 \033[31mis not support in current! \033[0m\n\n"
      exit 1;
    fi
  fi
fi

echo -e "\n[\033[33m$Relese\033[0m] [\033[33m$DIST\033[0m] [\033[33m$VER\033[0m] Downloading..."

if [[ "$linux_relese" == 'debian' ]] || [[ "$linux_relese" == 'ubuntu' ]]; then
  [ "$DIST" == "focal" ] && legacy="legacy-" || legacy=""
  wget --no-check-certificate -qO '/tmp/initrd.img' "${LinuxMirror}/dists/${DIST}/main/installer-${VER}/current/${legacy}images/netboot/${linux_relese}-installer/${VER}/initrd.gz"
    [[ $? -ne '0' ]] && echo -ne "\033[31mError! \033[0mDownload 'initrd.img' for \033[33m$linux_relese\033[0m failed! \n" && exit 1
  wget --no-check-certificate -qO '/tmp/vmlinuz' "${LinuxMirror}/dists/${DIST}${inUpdate}/main/installer-${VER}/current/${legacy}images/netboot/${linux_relese}-installer/${VER}/linux"
    [[ $? -ne '0' ]] && echo -ne "\033[31mError! \033[0mDownload 'vmlinuz' for \033[33m$linux_relese\033[0m failed! \n" && exit 1
  MirrorHost="$(echo "$LinuxMirror" |awk -F'://|/' '{print $2}')";
  MirrorFolder="$(echo "$LinuxMirror" |awk -F''${MirrorHost}'' '{print $2}')";
  [ -n "$MirrorFolder" ] || MirrorFolder="/"
elif [[ "$linux_relese" == 'centos' ]]; then
  wget --no-check-certificate -qO '/tmp/initrd.img' "${LinuxMirror}/${DIST}/os/${VER}/isolinux/initrd.img"
  [[ $? -ne '0' ]] && echo -ne "\033[31mError! \033[0mDownload 'initrd.img' for \033[33m$linux_relese\033[0m failed! \n" && exit 1
  wget --no-check-certificate -qO '/tmp/vmlinuz' "${LinuxMirror}/${DIST}/os/${VER}/isolinux/vmlinuz"
  [[ $? -ne '0' ]] && echo -ne "\033[31mError! \033[0mDownload 'vmlinuz' for \033[33m$linux_relese\033[0m failed! \n" && exit 1
else
  bash $0 error;
  exit 1;
fi
if [[ "$linux_relese" == 'debian' ]]; then
  if [[ "$IncFirmware" == '1' ]]; then
    wget --no-check-certificate -qO '/tmp/firmware.cpio.gz' "http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/${DIST}/current/firmware.cpio.gz"
    [[ $? -ne '0' ]] && echo -ne "\033[31mError! \033[0mDownload 'firmware' for \033[33m$linux_relese\033[0m failed! \n" && exit 1
  fi
  if [[ "$ddMode" == '1' ]]; then
    vKernel_udeb=$(wget --no-check-certificate -qO- "http://$DISTMirror/dists/$DIST/main/installer-$VER/current/images/udeb.list" |grep '^acpi-modules' |head -n1 |grep -o '[0-9]\{1,2\}.[0-9]\{1,2\}.[0-9]\{1,2\}-[0-9]\{1,2\}' |head -n1)
    [[ -z "vKernel_udeb" ]] && vKernel_udeb="4.19.0-17"
  fi
fi

if [[ "$loaderMode" == "0" ]]; then
  [[ ! -f "${GRUBDIR}/${GRUBFILE}" ]] && echo "Error! Not Found ${GRUBFILE}. " && exit 1;

  [[ ! -f "${GRUBDIR}/${GRUBFILE}.old" ]] && [[ -f "${GRUBDIR}/${GRUBFILE}.bak" ]] && mv -f "${GRUBDIR}/${GRUBFILE}.bak" "${GRUBDIR}/${GRUBFILE}.old";
  mv -f "${GRUBDIR}/${GRUBFILE}" "${GRUBDIR}/${GRUBFILE}.bak";
  [[ -f "${GRUBDIR}/${GRUBFILE}.old" ]] && cat "${GRUBDIR}/${GRUBFILE}.old" >"${GRUBDIR}/${GRUBFILE}" || cat "${GRUBDIR}/${GRUBFILE}.bak" >"${GRUBDIR}/${GRUBFILE}";
else
  GRUBVER='-1'
fi

[[ "$GRUBVER" == '0' ]] && {
  READGRUB='/tmp/grub.read'
  cat $GRUBDIR/$GRUBFILE |sed -n '1h;1!H;$g;s/\n/%%%%%%%/g;$p' |grep -om 1 'menuentry\ [^{]*{[^}]*}%%%%%%%' |sed 's/%%%%%%%/\n/g' >$READGRUB
  LoadNum="$(cat $READGRUB |grep -c 'menuentry ')"
  if [[ "$LoadNum" -eq '1' ]]; then
    cat $READGRUB |sed '/^$/d' >/tmp/grub.new;
  elif [[ "$LoadNum" -gt '1' ]]; then
    CFG0="$(awk '/menuentry /{print NR}' $READGRUB|head -n 1)";
    CFG2="$(awk '/menuentry /{print NR}' $READGRUB|head -n 2 |tail -n 1)";
    CFG1="";
    for tmpCFG in `awk '/}/{print NR}' $READGRUB`
      do
        [ "$tmpCFG" -gt "$CFG0" -a "$tmpCFG" -lt "$CFG2" ] && CFG1="$tmpCFG";
      done
    [[ -z "$CFG1" ]] && {
      echo "Error! read $GRUBFILE. ";
      exit 1;
    }

    sed -n "$CFG0,$CFG1"p $READGRUB >/tmp/grub.new;
    [[ -f /tmp/grub.new ]] && [[ "$(grep -c '{' /tmp/grub.new)" -eq "$(grep -c '}' /tmp/grub.new)" ]] || {
      echo -ne "\033[31mError! \033[0mNot configure $GRUBFILE. \n";
      exit 1;
    }
  fi
  [ ! -f /tmp/grub.new ] && echo "Error! $GRUBFILE. " && exit 1;
  sed -i "/menuentry.*/c\menuentry\ \'Install OS \[$DIST\ $VER\]\'\ --class debian\ --class\ gnu-linux\ --class\ gnu\ --class\ os\ \{" /tmp/grub.new
  sed -i "/echo.*Loading/d" /tmp/grub.new;
  INSERTGRUB="$(awk '/menuentry /{print NR}' $GRUBDIR/$GRUBFILE|head -n 1)"
}

[[ "$GRUBVER" == '1' ]] && {
  CFG0="$(awk '/title[\ ]|title[\t]/{print NR}' $GRUBDIR/$GRUBFILE|head -n 1)";
  CFG1="$(awk '/title[\ ]|title[\t]/{print NR}' $GRUBDIR/$GRUBFILE|head -n 2 |tail -n 1)";
  [[ -n $CFG0 ]] && [ -z $CFG1 -o $CFG1 == $CFG0 ] && sed -n "$CFG0,$"p $GRUBDIR/$GRUBFILE >/tmp/grub.new;
  [[ -n $CFG0 ]] && [ -z $CFG1 -o $CFG1 != $CFG0 ] && sed -n "$CFG0,$[$CFG1-1]"p $GRUBDIR/$GRUBFILE >/tmp/grub.new;
  [[ ! -f /tmp/grub.new ]] && echo "Error! configure append $GRUBFILE. " && exit 1;
  sed -i "/title.*/c\title\ \'Install OS \[$DIST\ $VER\]\'" /tmp/grub.new;
  sed -i '/^#/d' /tmp/grub.new;
  INSERTGRUB="$(awk '/title[\ ]|title[\t]/{print NR}' $GRUBDIR/$GRUBFILE|head -n 1)"
}

if [[ "$loaderMode" == "0" ]]; then
[[ -n "$(grep 'linux.*/\|kernel.*/' /tmp/grub.new |awk '{print $2}' |tail -n 1 |grep '^/boot/')" ]] && Type='InBoot' || Type='NoBoot';

LinuxKernel="$(grep 'linux.*/\|kernel.*/' /tmp/grub.new |awk '{print $1}' |head -n 1)";
[[ -z "$LinuxKernel" ]] && echo "Error! read grub config! " && exit 1;
LinuxIMG="$(grep 'initrd.*/' /tmp/grub.new |awk '{print $1}' |tail -n 1)";
[ -z "$LinuxIMG" ] && sed -i "/$LinuxKernel.*\//a\\\tinitrd\ \/" /tmp/grub.new && LinuxIMG='initrd';

  [[ "$setInterfaceName" == "1" ]] && Add_OPTION="net.ifnames=0 biosdevname=0" || Add_OPTION=""
  [[ "$setIPv6" == "1" ]] && Add_OPTION="$Add_OPTION ipv6.disable=1"
  
  lowMem || Add_OPTION="$Add_OPTION lowmem=+2"

if [[ "$linux_relese" == 'debian' ]] || [[ "$linux_relese" == 'ubuntu' ]]; then
    BOOT_OPTION="auto=true $Add_OPTION hostname=$linux_relese domain=$linux_relese quiet"
elif [[ "$linux_relese" == 'centos' ]]; then
    BOOT_OPTION="ks=file://ks.cfg $Add_OPTION ksdevice=$interfaceSelect"
fi
  
  [ -n "$setConsole" ] && BOOT_OPTION="$BOOT_OPTION --- console=$setConsole"

[[ "$Type" == 'InBoot' ]] && {
  sed -i "/$LinuxKernel.*\//c\\\t$LinuxKernel\\t\/boot\/vmlinuz $BOOT_OPTION" /tmp/grub.new;
  sed -i "/$LinuxIMG.*\//c\\\t$LinuxIMG\\t\/boot\/initrd.img" /tmp/grub.new;
}

[[ "$Type" == 'NoBoot' ]] && {
  sed -i "/$LinuxKernel.*\//c\\\t$LinuxKernel\\t\/vmlinuz $BOOT_OPTION" /tmp/grub.new;
  sed -i "/$LinuxIMG.*\//c\\\t$LinuxIMG\\t\/initrd.img" /tmp/grub.new;
}

sed -i '$a\\n' /tmp/grub.new;
fi

[[ "$inVNC" == 'n' ]] && {
GRUBPATCH='0';

if [[ "$loaderMode" == "0" ]]; then
[ -f '/etc/network/interfaces' -o -d '/etc/sysconfig/network-scripts' ] || {
  echo "Error, Not found interfaces config.";
  exit 1;
}

sed -i ''${INSERTGRUB}'i\\n' $GRUBDIR/$GRUBFILE;
sed -i ''${INSERTGRUB}'r /tmp/grub.new' $GRUBDIR/$GRUBFILE;
[[ -f  $GRUBDIR/grubenv ]] && sed -i 's/saved_entry/#saved_entry/g' $GRUBDIR/grubenv;
fi

[[ -d /tmp/boot ]] && rm -rf /tmp/boot;
mkdir -p /tmp/boot;
cd /tmp/boot;

if [[ "$linux_relese" == 'debian' ]] || [[ "$linux_relese" == 'ubuntu' ]]; then
  COMPTYPE="gzip";
elif [[ "$linux_relese" == 'centos' ]]; then
  COMPTYPE="$(file ../initrd.img |grep -o ':.*compressed data' |cut -d' ' -f2 |sed -r 's/(.*)/\L\1/' |head -n1)"
  [[ -z "$COMPTYPE" ]] && echo "Detect compressed type fail." && exit 1;
fi
CompDected='0'
for COMP in `echo -en 'gzip\nlzma\nxz'`
  do
    if [[ "$COMPTYPE" == "$COMP" ]]; then
      CompDected='1'
      if [[ "$COMPTYPE" == 'gzip' ]]; then
        NewIMG="initrd.img.gz"
      else
        NewIMG="initrd.img.$COMPTYPE"
      fi
      mv -f "/tmp/initrd.img" "/tmp/$NewIMG"
      break;
    fi
  done
[[ "$CompDected" != '1' ]] && echo "Detect compressed type not support." && exit 1;
[[ "$COMPTYPE" == 'lzma' ]] && UNCOMP='xz --format=lzma --decompress';
[[ "$COMPTYPE" == 'xz' ]] && UNCOMP='xz --decompress';
[[ "$COMPTYPE" == 'gzip' ]] && UNCOMP='gzip -d';

$UNCOMP < /tmp/$NewIMG | cpio --extract --verbose --make-directories --no-absolute-filenames >>/dev/null 2>&1

# --- Flyqie ---
[[ "$ddMode" == '1' ]] && {
  wget --no-check-certificate -qO '/tmp/boot/dd_web' "$ddWebBinUrl"
  [[ $? -ne '0' ]] && echo -ne "\033[31mError! \033[0mDownload 'dd_web' failed! \n" && exit 1

  [[ -z "$ddWebAuthKey" ]] && {
    ddWebAuthKey=`< /dev/urandom tr -dc 0-9-a-z-|head -c ${1:-12};echo`
  }
}
# --- Flyqie ---

if [[ "$linux_relese" == 'debian' ]] || [[ "$linux_relese" == 'ubuntu' ]]; then
CurrentKernelVersion=`ls -1 ./lib/modules 2>/dev/null |head -n1`
[ -n "$CurrentKernelVersion" ] && SelectLowmem="di-utils-exit-installer,driver-injection-disk-detect,fdisk-udeb,netcfg-static,parted-udeb,partman-auto,partman-ext3,ata-modules-${CurrentKernelVersion}-di,efi-modules-${CurrentKernelVersion}-di,sata-modules-${CurrentKernelVersion}-di,scsi-modules-${CurrentKernelVersion}-di,scsi-nic-modules-${CurrentKernelVersion}-di" || SelectLowmem=""
cat >/tmp/boot/preseed.cfg<<EOF
d-i debian-installer/locale string en_US.UTF-8
d-i debian-installer/country string US
d-i debian-installer/language string en

d-i console-setup/layoutcode string us

d-i keyboard-configuration/xkb-keymap string us
d-i lowmem/low note
d-i anna/choose_modules_lowmem multiselect $SelectLowmem

d-i netcfg/choose_interface select $interfaceSelect

d-i netcfg/disable_autoconfig boolean true
d-i netcfg/dhcp_failed note
d-i netcfg/dhcp_options select Configure network manually
d-i netcfg/get_ipaddress string $IPv4
d-i netcfg/get_netmask string $MASK
d-i netcfg/get_gateway string $GATE
d-i netcfg/get_nameservers string 8.8.8.8
d-i netcfg/no_default_route boolean true
d-i netcfg/confirm_static boolean true

d-i hw-detect/load_firmware boolean true

d-i mirror/country string manual
d-i mirror/http/hostname string $MirrorHost
d-i mirror/http/directory string $MirrorFolder
d-i mirror/http/proxy string
d-i apt-setup/services-select multiselect

d-i passwd/root-login boolean ture
d-i passwd/make-user boolean false
d-i passwd/root-password-crypted password $myPASSWORD
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

d-i clock-setup/utc boolean true
d-i time/zone string US/Eastern
d-i clock-setup/ntp boolean true

d-i preseed/early_command string anna-install libfuse2-udeb fuse-udeb ntfs-3g-udeb fuse-modules-${vKernel_udeb}-amd64-di
d-i partman/early_command string [[ -n "\$(blkid -t TYPE='vfat' -o device)" ]] && umount "\$(blkid -t TYPE='vfat' -o device)"; \
debconf-set partman-auto/disk "\$(list-devices disk |head -n1)"; \
chmod 755 /dd_web; /dd_web -ddurl='$DDURL' $errorExit $successExit -addr='$ddWebAddr' -authkey='$ddWebAuthKey' -retrynum=$retryNum -ddof="\$(list-devices disk |head -n1)" \
mount.ntfs-3g \$(list-devices partition |head -n1) /mnt; \
cd '/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs'; \
cd Start* || cd start*; \
cp -f '/net.bat' './net.bat'; \
/sbin/reboot; \
debconf-set grub-installer/bootdev string "\$(list-devices disk |head -n1)"; \
umount /media || true; \

d-i partman/mount_style select uuid
d-i partman-auto/init_automatically_partition select Guided - use entire disk
d-i partman-auto/choose_recipe select All files in one partition (recommended for new users)
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

d-i debian-installer/allow_unauthenticated boolean true

tasksel tasksel/first multiselect minimal
d-i pkgsel/update-policy select none
d-i pkgsel/include string openssh-server
d-i pkgsel/upgrade select none

popularity-contest popularity-contest/participate boolean false

d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev string default
d-i finish-install/reboot_in_progress note
d-i debian-installer/exit/reboot boolean true
d-i preseed/late_command string	\
sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin yes/g' /target/etc/ssh/sshd_config; \
sed -ri 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/g' /target/etc/ssh/sshd_config;
EOF

[[ "$loaderMode" != "0" ]] && AutoNet='1'

[[ "$setNet" == '0' ]] && [[ "$AutoNet" == '1' ]] && {
  sed -i '/netcfg\/disable_autoconfig/d' /tmp/boot/preseed.cfg
  sed -i '/netcfg\/dhcp_options/d' /tmp/boot/preseed.cfg
  sed -i '/netcfg\/get_.*/d' /tmp/boot/preseed.cfg
  sed -i '/netcfg\/confirm_static/d' /tmp/boot/preseed.cfg
}

[[ "$DIST" == 'trusty' ]] && GRUBPATCH='1'
[[ "$DIST" == 'wily' ]] && GRUBPATCH='1'
[[ "$DIST" == 'xenial' ]] && {
  sed -i 's/^d-i\ clock-setup\/ntp\ boolean\ true/d-i\ clock-setup\/ntp\ boolean\ false/g' /tmp/boot/preseed.cfg
}

[[ "$GRUBPATCH" == '1' ]] && {
  sed -i 's/^d-i\ grub-installer\/bootdev\ string\ default//g' /tmp/boot/preseed.cfg
}
[[ "$GRUBPATCH" == '0' ]] && {
  sed -i 's/debconf-set\ grub-installer\/bootdev.*\"\;//g' /tmp/boot/preseed.cfg
}

[[ "$linux_relese" == 'debian' ]] && {
  sed -i '/user-setup\/allow-password-weak/d' /tmp/boot/preseed.cfg
  sed -i '/user-setup\/encrypt-home/d' /tmp/boot/preseed.cfg
  sed -i '/pkgsel\/update-policy/d' /tmp/boot/preseed.cfg
  sed -i 's/umount\ \/media.*true\;\ //g' /tmp/boot/preseed.cfg
}
[[ "$linux_relese" == 'debian' ]] && [[ -f '/boot/firmware.cpio.gz' ]] && {
  gzip -d < /boot/firmware.cpio.gz | cpio --extract --verbose --make-directories --no-absolute-filenames >>/dev/null 2>&1
}

[[ "$ddMode" == '1' ]] && {
WinNoDHCP(){
  echo -ne "for\0040\0057f\0040\0042tokens\00753\0052\0042\0040\0045\0045i\0040in\0040\0050\0047netsh\0040interface\0040show\0040interface\0040\0136\0174more\0040\00533\0040\0136\0174findstr\0040\0057I\0040\0057R\0040\0042本地\0056\0052\0040以太\0056\0052\0040Local\0056\0052\0040Ethernet\0042\0047\0051\0040do\0040\0050set\0040EthName\0075\0045\0045j\0051\r\nnetsh\0040\0055c\0040interface\0040ip\0040set\0040address\0040name\0075\0042\0045EthName\0045\0042\0040source\0075static\0040address\0075$IPv4\0040mask\0075$MASK\0040gateway\0075$GATE\r\nnetsh\0040\0055c\0040interface\0040ip\0040add\0040dnsservers\0040name\0075\0042\0045EthName\0045\0042\0040address\00758\00568\00568\00568\0040index\00751\0040validate\0075no\r\n\r\n" >>'/tmp/boot/net.tmp';
}
WinRDP(){
  echo -ne "netsh\0040firewall\0040set\0040portopening\0040protocol\0075ALL\0040port\0075$WinRemote\0040name\0075RDP\0040mode\0075ENABLE\0040scope\0075ALL\0040profile\0075ALL\r\nnetsh\0040firewall\0040set\0040portopening\0040protocol\0075ALL\0040port\0075$WinRemote\0040name\0075RDP\0040mode\0075ENABLE\0040scope\0075ALL\0040profile\0075CURRENT\r\nreg\0040add\0040\0042HKLM\0134SYSTEM\0134CurrentControlSet\0134Control\0134Network\0134NewNetworkWindowOff\0042\0040\0057f\r\nreg\0040add\0040\0042HKLM\0134SYSTEM\0134CurrentControlSet\0134Control\0134Terminal\0040Server\0042\0040\0057v\0040fDenyTSConnections\0040\0057t\0040reg\0137dword\0040\0057d\00400\0040\0057f\r\nreg\0040add\0040\0042HKLM\0134SYSTEM\0134CurrentControlSet\0134Control\0134Terminal\0040Server\0134Wds\0134rdpwd\0134Tds\0134tcp\0042\0040\0057v\0040PortNumber\0040\0057t\0040reg\0137dword\0040\0057d\0040$WinRemote\0040\0057f\r\nreg\0040add\0040\0042HKLM\0134SYSTEM\0134CurrentControlSet\0134Control\0134Terminal\0040Server\0134WinStations\0134RDP\0055Tcp\0042\0040\0057v\0040PortNumber\0040\0057t\0040reg\0137dword\0040\0057d\0040$WinRemote\0040\0057f\r\nreg\0040add\0040\0042HKLM\0134SYSTEM\0134CurrentControlSet\0134Control\0134Terminal\0040Server\0134WinStations\0134RDP\0055Tcp\0042\0040\0057v\0040UserAuthentication\0040\0057t\0040reg\0137dword\0040\0057d\00400\0040\0057f\r\nFOR\0040\0057F\0040\0042tokens\00752\0040delims\0075\0072\0042\0040\0045\0045i\0040in\0040\0050\0047SC\0040QUERYEX\0040TermService\0040\0136\0174FINDSTR\0040\0057I\0040\0042PID\0042\0047\0051\0040do\0040TASKKILL\0040\0057F\0040\0057PID\0040\0045\0045i\r\nFOR\0040\0057F\0040\0042tokens\00752\0040delims\0075\0072\0042\0040\0045\0045i\0040in\0040\0050\0047SC\0040QUERYEX\0040UmRdpService\0040\0136\0174FINDSTR\0040\0057I\0040\0042PID\0042\0047\0051\0040do\0040TASKKILL\0040\0057F\0040\0057PID\0040\0045\0045i\r\nSC\0040START\0040TermService\r\n\r\n" >>'/tmp/boot/net.tmp';
}
  echo -ne "\0100ECHO\0040OFF\r\n\r\ncd\0056\0076\0045WINDIR\0045\0134GetAdmin\r\nif\0040exist\0040\0045WINDIR\0045\0134GetAdmin\0040\0050del\0040\0057f\0040\0057q\0040\0042\0045WINDIR\0045\0134GetAdmin\0042\0051\0040else\0040\0050\r\necho\0040CreateObject\0136\0050\0042Shell\0056Application\0042\0136\0051\0056ShellExecute\0040\0042\0045\0176s0\0042\0054\0040\0042\0045\0052\0042\0054\0040\0042\0042\0054\0040\0042runas\0042\0054\00401\0040\0076\0076\0040\0042\0045temp\0045\0134Admin\0056vbs\0042\r\n\0042\0045temp\0045\0134Admin\0056vbs\0042\r\ndel\0040\0057f\0040\0057q\0040\0042\0045temp\0045\0134Admin\0056vbs\0042\r\nexit\0040\0057b\00402\0051\r\n\r\n" >'/tmp/boot/net.tmp';
  [[ "$setNet" == '1' ]] && WinNoDHCP;
  [[ "$setNet" == '0' ]] && [[ "$AutoNet" == '0' ]] && WinNoDHCP;
  [[ "$setRDP" == '1' ]] && [[ -n "$WinRemote" ]] && WinRDP
  echo -ne "ECHO\0040SELECT\0040VOLUME\0075\0045\0045SystemDrive\0045\0045\0040\0076\0040\0042\0045SystemDrive\0045\0134diskpart\0056extend\0042\r\nECHO\0040EXTEND\0040\0076\0076\0040\0042\0045SystemDrive\0045\0134diskpart\0056extend\0042\r\nSTART\0040/WAIT\0040DISKPART\0040\0057S\0040\0042\0045SystemDrive\0045\0134diskpart\0056extend\0042\r\nDEL\0040\0057f\0040\0057q\0040\0042\0045SystemDrive\0045\0134diskpart\0056extend\0042\r\n\r\n" >>'/tmp/boot/net.tmp';
  echo -ne "cd\0040\0057d\0040\0042\0045ProgramData\0045\0057Microsoft\0057Windows\0057Start\0040Menu\0057Programs\0057Startup\0042\r\ndel\0040\0057f\0040\0057q\0040net\0056bat\r\n\r\n\r\n" >>'/tmp/boot/net.tmp';
  iconv -f 'UTF-8' -t 'GBK' '/tmp/boot/net.tmp' -o '/tmp/boot/net.bat'
  rm -rf '/tmp/boot/net.tmp'
  echo "$DDURL" |grep -q '^https://'
  [[ $? -eq '0' ]] && {
    echo -ne '\nAdd ssl support...\n'
    [[ -n $SSL_SUPPORT ]] && {
      wget --no-check-certificate -qO- "$SSL_SUPPORT" |tar -x
      [[ ! -f  /tmp/boot/usr/bin/wget ]] && echo 'Error! SSL_SUPPORT.' && exit 1;
      sed -i 's/wget\ -qO-/\/usr\/bin\/wget\ --no-check-certificate\ --retry-connrefused\ --tries=7\ --continue\ -qO-/g' /tmp/boot/preseed.cfg
      [[ $? -eq '0' ]] && echo -ne 'Success! \n\n'
    } || {
    echo -ne 'Not ssl support package! \n\n';
    exit 1;
    }
  }
}

[[ "$ddMode" == '0' ]] && {
  sed -i '/anna-install/d' /tmp/boot/preseed.cfg
  sed -i 's/wget.*\/sbin\/reboot\;\ //g' /tmp/boot/preseed.cfg
}

elif [[ "$linux_relese" == 'centos' ]]; then
cat >/tmp/boot/ks.cfg<<EOF
#platform=x86, AMD64, or Intel EM64T
firewall --enabled --ssh
install
url --url="$LinuxMirror/$DIST/os/$VER/"
rootpw --iscrypted $myPASSWORD
auth --useshadow --passalgo=sha512
firstboot --disable
lang en_US
keyboard us
selinux --disabled
logging --level=info
reboot
text
unsupported_hardware
vnc
skipx
timezone --isUtc Asia/Hong_Kong
#ONDHCP network --bootproto=dhcp --onboot=on
#NODHCP network --bootproto=static --ip=$IPv4 --netmask=$MASK --gateway=$GATE --nameserver=8.8.8.8 --onboot=on
bootloader --location=mbr --append="rhgb quiet crashkernel=auto"
zerombr
clearpart --all --initlabel 
autopart

%packages
@base
%end

%post --interpreter=/bin/bash
rm -rf /root/anaconda-ks.cfg
rm -rf /root/install.*log
%end

EOF

[[ "$setNet" == '0' ]] && [[ "$AutoNet" == '1' ]] && {
  sed -i 's/#ONDHCP\ //g' /tmp/boot/ks.cfg
} || {
  sed -i 's/#NODHCP\ //g' /tmp/boot/ks.cfg
}
[[ "$UNKNOWHW" == '1' ]] && sed -i 's/^unsupported_hardware/#unsupported_hardware/g' /tmp/boot/ks.cfg
[[ "$(echo "$DIST" |grep -o '^[0-9]\{1\}')" == '5' ]] && sed -i '0,/^%end/s//#%end/' /tmp/boot/ks.cfg
fi

find . | cpio -H newc --create --verbose | gzip -9 > /boot/initrd.img;
rm -rf /tmp/boot;
}

# --- Flyqie ---
[[ "$ddMode" == '1' ]] && {
  if [[ "$ddWebAddr" == '0.0.0.0:2333' ]]; then
    ddProgressVisitUrl="http://[SERVER IPv4]:2333/$ddWebAuthKey/"
  else
    ddProgressVisitUrl="http://$ddWebAddr/$ddWebAuthKey/"
  fi
  echo -e "\033[35m You Can Visit This Url To Visit The DD Progress: $ddProgressVisitUrl \033[0m"
}
# --- Flyqie ---

[[ "$inVNC" == 'y' ]] && {
  sed -i '$i\\n' $GRUBDIR/$GRUBFILE
  sed -i '$r /tmp/grub.new' $GRUBDIR/$GRUBFILE
  echo -e "\n\033[33m\033[04mIt will reboot! \nPlease connect VNC! \nSelect\033[0m\033[32m Install OS [$DIST $VER] \033[33m\033[4mto install system.\033[04m\n\n\033[31m\033[04mThere is some information for you.\nDO NOT CLOSE THE WINDOW! \033[0m\n"
  echo -e "\033[35mIPv4\t\tNETMASK\t\tGATEWAY\033[0m"
  echo -e "\033[36m\033[04m$IPv4\033[0m\t\033[36m\033[04m$MASK\033[0m\t\033[36m\033[04m$GATE\033[0m\n\n"

  read -n 1 -p "Press Enter to reboot..." INP
  [[ "$INP" != '' ]] && echo -ne '\b \n\n';
}

chown root:root $GRUBDIR/$GRUBFILE
chmod 444 $GRUBDIR/$GRUBFILE

if [[ "$loaderMode" == "0" ]]; then
  sleep 3 && reboot >/dev/null 2>&1
else
  rm -rf "$HOME/loader"
  mkdir -p "$HOME/loader"
  cp -rf "/boot/initrd.img" "$HOME/loader/initrd.img"
  cp -rf "/boot/vmlinuz" "$HOME/loader/vmlinuz"
  [[ -f "/boot/initrd.img" ]] && rm -rf "/boot/initrd.img"
  [[ -f "/boot/vmlinuz" ]] && rm -rf "/boot/vmlinuz"
  echo && ls -AR1 "$HOME/loader"
fi
