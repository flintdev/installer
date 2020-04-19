#!/usr/bin/env bash

#####################################
# Author: Gaoxin Dai
# Version: v1.0.0
# Description: Command-line utility for workflow engine administrative tasks
# Usage: ./manage.sh <check|install|start|upgrade>
#####################################

# check if dependencies are installed
checkIfXcodeCommandLineToolsInstalled() {
  xcode-select -p &> /dev/null
  xcodeCommandLineToolsStatus=$?
  if [ "$xcodeCommandLineToolsStatus" == "0" ]; then
    isXcodeCommandLineToolsInstalled=true
  else
    isXcodeCommandLineToolsInstalled=false
  fi
}

checkIsHomebrewInstalled() {
  if [ -x "$(command -v brew)" ]; then
    isHomebrewInstalled=true
  else
    isHomebrewInstalled=false
  fi
}

checkIfMercurialInstalled() {
  brew list mercurial &> /dev/null
  mercurialStatus=$?
  if [ "$mercurialStatus" == "0" ]; then
    isMercurialInstalled=true
  else
    isMercurialInstalled=false
  fi
}

checkIsGVMInstalled() {
  # shellcheck source=src/lib.sh
  source "$HOME/.gvm/scripts/gvm" &> /dev/null
  gvm version &> /dev/null
  gvmVersionStatus=$?
  if [ "$gvmVersionStatus" == "0" ]; then
    isgvmInstalled=true
  else
    isgvmInstalled=false
  fi
}

checkIsDockerInstalled() {
  if [ -x "$(command -v docker)" ]; then
    isDockerInstalled=true
  else
    isDockerInstalled=false
  fi
}

checkIsDockerRunning() {
  curl -s --unix-socket /var/run/docker.sock http://ping &> /dev/null
  dockerStatus=$?
  if [ ! "$dockerStatus" == "7" ]; then
    isDockerRunning=true
  else
    isDockerRunning=false
  fi
}

checkIsKubectlInstalled() {
  if [ -x "$(command -v kubectl)" ]; then
    isKubectlInstalled=true
  else
    isKubectlInstalled=false
  fi
}

checkIsKindInstalled(){
  if [ -x "$(command -v kind)" ]; then
    isKindInstalled=true
  else
    isKindInstalled=false
  fi
}

checkIsClusterRunning() {
  kubectl cluster-info &> /dev/null
  clusterStatus=$?
  if [ ! "$clusterStatus" == "0" ]; then
    isClusterRunning=false
  else
    isClusterRunning=true
  fi
}

outputCheckJson() {
  echo -e "{\"package\":{\"Homebrew\":\"$isHomebrewInstalled\", \"GVM\":\"$isgvmInstalled\", \
\"Mercurial\":\"$isMercurialInstalled\", \"Xcode Command Line Tools\":\"$isXcodeCommandLineToolsInstalled\", \
\"Docker\":\"$isDockerInstalled\", \"Kubectl\":\"$isKubectlInstalled\", \"Kind\":\"$isKindInstalled\"}, \
\"state\":{\"Docker\":\"$isDockerRunning\", \"Cluster\":\"$isClusterRunning\"}}"
}

check() {
  checkIfXcodeCommandLineToolsInstalled
  checkIsHomebrewInstalled
  checkIfMercurialInstalled
  checkIsGVMInstalled
  checkIsDockerInstalled
  checkIsDockerRunning
  checkIsKubectlInstalled
  checkIsKindInstalled
  checkIsClusterRunning
  outputCheckJson
}

# Install dependencies
installXcodeCommandLineTools() {
  xcode-select -p &> /dev/null
  xcodeCommandLineToolsStatus=$?
  if [ "$xcodeCommandLineToolsStatus" == "0" ]; then
    echo "Xcode Command Line Tools is already installed"
  else
    xcode-select --install
    echo "Xcode Command Line Tools Installation Complete"
  fi
}

installMercurial() {
  brew list mercurial &> /dev/null
  mercurialVersionStatus=$?
  if [ "$mercurialVersionStatus" == "0" ]; then
    echo "Mercurial is already installed"
  else
    echo "Installing Mercurial..."
    brew install Mercurial
    echo "Mercurial Installation Complete"
  fi
}

installHomebrew() {
  if [ -x "$(command -v brew)" ]; then
    echo "Homebrew is already installed"
    echo "Updating Homebrew"
    brew update &> /dev/null
  else
    echo "Installing homebrew..."
    URL_BREW='https://raw.githubusercontent.com/Homebrew/install/master/install.sh'
    echo | /bin/bash -c "$(curl -fsSL $URL_BREW)"
    echo "Homebrew Installtion Complete"
  fi
}

installCurl() {
  if [ -x "$(command -v curl)" ]; then
    echo "Curl is already installed"
  else
    echo "Installing Curl..."
    brew install curl
    echo "Homebrew Installtion Complete"
  fi
}

installGVM() {
  # shellcheck source=src/lib.sh
  source "$HOME/.gvm/scripts/gvm" &> /dev/null
  gvm version &> /dev/null
  gvmVersionStatus=$?
  if [ "$gvmVersionStatus" == "0" ]; then
    echo "gvm is already installed"
  else
    echo "Installing gvm..."
    $SHELL < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    # shellcheck source=src/lib.sh
    source "$HOME/.gvm/scripts/gvm"
    if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
      shell_profile="zshrc"
    elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
      shell_profile="profile"
    fi
    touch "$HOME/.${shell_profile}"
    {
    echo '# GVM'
    echo "export GVM_ROOT=$HOME/.gvm"
    echo '. $GVM_ROOT/scripts/gvm-default'
    } >> "$HOME/.${shell_profile}"
    echo "gvm Installation Complete"
  fi
}

installGoBaseVersion() {
  # shellcheck source=src/lib.sh
  source "$HOME/.gvm/scripts/gvm"
  gvm install go1.13.5
  gvm use go1.13.5
}

installDocker() {
  if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed"
  else
    echo "Installing Docker..."
    brew cask install docker
    echo "Docker Installation Complete"
  fi
}

runDocker() {
  curl -s --unix-socket /var/run/docker.sock http://ping &> /dev/null
  status=$?
  if [ "$status" == "7" ]; then
    echo "Docker is not running, open docker app..."
    open /Applications/Docker.app
  else
    echo "Docker is already up and running"
  fi
}

installKubectl() {
  if [ -x "$(command -v kubectl)" ]; then
    echo "Kubectl is already installed"
  else
    brew install kubectl
  fi
}

installKind() {
  if [ -x "$(command -v kind)" ]; then
    echo "Kind is already installed"
  else
    echo "Installing Kind..."
    brew install kind
    echo "Kind Installtion Complete"
    echo "Creating cluster..."
    kind create cluster
    echo "Cluster was Created"
  fi
}

runCluster() {
  kubectl cluster-info &> /dev/null
  clusterStatus=$?
  if [ ! "$clusterStatus" == "0" ]; then
    echo "Creating cluster..."
    kind create cluster
    echo "Cluster was Created"
  else
    echo "Cluster is already up and running"
  fi
}

checkIfGVMHasAvailableVersion () {
  availableGoVersion=$(findAvailableGoVersion)
  # use latest available version or install go1.13.5
  if [ "$availableGoVersion" == "unknown" ]; then
    installGoBaseVersion
  elif [ "$availableGoVersion" == "false" ]; then
    installGoBaseVersion
  else
    gvm use "go$availableGoVersion"
  fi
}

findAvailableGoVersion() {
  baseVersion="1.13"
  # Get current avaliable version in gvm
  curentVersionArray=()
  availableVersionArray=()

  # shellcheck source=src/lib.sh
  source "$HOME/.gvm/scripts/gvm" &> /dev/null
  while read -r line
  do
    goVersion=$(echo "$line" | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')
    if [ ! "$goVersion" == "" ]; then
      curentVersionArray+=("$goVersion")
    fi
  done < <( gvm list | grep -v ^$ )

  # get all version higher than 1.13
  for i in "${curentVersionArray[@]}"
  do :
  vercomp "$i" "$baseVersion"
  result=$?
  if [ ! "$result" == "2" ]; then
    availableVersionArray+=("$i")
  fi
  done

  # use latest available version or install go1.13.5
  if [ "${#availableVersionArray[@]}" -gt 0 ]; then
    avaliableVersion=${availableVersionArray[${#availableVersionArray[@]}-1]}
    echo "$avaliableVersion"
  else
    echo "false"
  fi
}

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}


install() {
  installXcodeCommandLineTools
  installMercurial
  installHomebrew
  installCurl
  installGVM
  checkIfGVMHasAvailableVersion
  installDocker
  runDocker
  installKubectl
  installKind
  runCluster
}

# start workflow flow engine
start() {
  baseVersion="1.13"
  availableGoVersion=$(findAvailableGoVersion)
  # use latest available version
  if [ "$availableGoVersion" == "false" ]; then
    echo "Cannot find go version >= $baseVersion"
    exit 1
  else
    # shellcheck source=src/lib.sh
    source "$HOME/.gvm/scripts/gvm"
    gvm use "go$availableGoVersion"
    go get -u github.com/flintdev/workflow-engine
    go run ./main.go
  fi
}

# upgrade workflow flow engine
upgrade() {
  baseVersion="1.13"
  availableGoVersion=$(findAvailableGoVersion)
  # use latest available version
  if [ "$availableGoVersion" == "false" ]; then
    echo "Cannot find go version >= $baseVersion"
    exit 1
  else
    # shellcheck source=src/lib.sh
    source "$HOME/.gvm/scripts/gvm"
    gvm use "go$availableGoVersion"
    go get -u github.com/flintdev/workflow-engine
  fi
}


if [[ $# -ne 1 ]]; then
  echo "Incorrect usage!"
  echo "Usage: $0 <check|install|start|upgrade> "
  exit 1
fi

opt=$1
case $opt in
    "check")
      check
    ;;
    "install")
      install
    ;;
    "start")
      start
    ;;
    "upgrade")
      upgrade
    ;;
    *)
      echo "Incorrect usage!"
      echo "Usage: $0 <check|install|start|upgrade> "
      exit 1
    ;;
esac