#!/usr/bin/env bash

# Color setup
ERROR='\033[1;31m'  # [ERROR] Light RED
INFO='\033[1;32m'   # [INFO] Light GREEN
QNA='\033[1;36m'    # [QnA] Light CYAN
WARN='\033[1;33m'   # [WARN] YELLOW
NC='\033[0m'        # [END] No color

# Install for macOS
OS=$(uname)
# Install target command
COMMANDS=('aws' 'aws-iam-authenticator' 'kubectl')
BIN_DIR="/usr/local/bin"


# Check macOS
[ "$OS" != "Darwin" ] && echo -e "${ERROR}## [ERROR] This Script is for macOS" && exit

echo -e "${WARN}###############################################################################"
echo -e "## 스트립트에서 실행 절차입니다."
echo -e "## 절차 진행 시 Enter를 입력하고, 취소 시 Ctrl + c 를 입력"
echo -e "## aws cli --> aws 명령줄 인터페이스"
echo -e "## aws cli 설치 시에는 sudo 권한으로 인해 패스워드를 입력"
echo -e "## aws-iam-authenticator --> aws iam 계정과 kubernetes 클러스터 인증 "
echo -e "## kubectl(v1.19.13) --> 쿠버네티스 명령줄 인터페이스"
echo -e "## 환경설정은 ${QNA}$HOME/.customrc ${WARN}에 저장 "
echo -e "## customrc는 ${QNA}$HOME/.zshrc ${WARN}에 import "
echo -e "## staging kubeconfig는 ${QNA}$HOME/.kube/config.staging ${WARN}으로 저장"
echo -e "## customrc에 export KUBECONFIG 환경변수가 저장"
echo -e "## ${QNA}production${WARN}은 SRE팀에 요청"
echo -e "## aws configure 별도로 진행"
echo -e "###############################################################################"
read -p "$(echo -e "${INFO}[Press Enter] ${NC}")"


# Defined aws-iam-authenticator
# ref: https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-aws-iam-authenticator.html
install_aws-iam-authenticator() {
  # set environment variables
  IAM_AUTH="aws-iam-authenticator"
  IAM_AUTH_CHECKSUM="$IAM_AUTH.sha256"
  IAM_AUTH_VERS="1.19.6"
  IAM_AUTH_DOWN_URL="https://amazon-eks.s3.us-west-2.amazonaws.com/$IAM_AUTH_VERS/2021-01-05/bin/darwin/amd64"

  # Started install
  DOWNLOAD_IAM_AUTH=$(curl -s -w "%{http_code}" -o $IAM_AUTH $IAM_AUTH_DOWN_URL/$IAM_AUTH)
  sleep 2;

  if [ "$DOWNLOAD_IAM_AUTH" == 200 ]; then
    echo -e "${INFO}## [INFO] $IAM_AUTH download successed ${NC}"
    DOWNLOAD_IAM_CHECKSUM=$(curl -s -w "%{http_code}" -o $IAM_AUTH_CHECKSUM $IAM_AUTH_DOWN_URL/$IAM_AUTH_CHECKSUM)
    sleep 2;
    if [ "$DOWNLOAD_IAM_CHECKSUM" == 200 ]; then
      echo -e "${INFO}## [INFO] $IAM_AUTH_CHECKSUM download successed ${NC}"
      openssl sha1 -sha256 $IAM_AUTH

      echo -e "${INFO}## [INFO] Change execute mode ${NC}"
      [ -f "$IAM_AUTH" ] && chmod +x "./$IAM_AUTH"

      echo -e "${INFO}## [INFO] Move to ${WARN} $BIN_DIR/$IAM_AUTH"
      [ -f "$IAM_AUTH" ] && mv "./$IAM_AUTH" "$BIN_DIR/$IAM_AUTH"

      echo -e "${INFO}## [INFO] Remove $IAM_AUTH_CHECKSUM"
      [ -f "$IAM_AUTH_CHECKSUM" ] && rm  "./$IAM_AUTH_CHECKSUM"

    else
      echo -e "${ERROR}## [ERROR] $IAM_AUTH_CHECKSUM download failed ${NC}"
    fi
  else
    echo -e "${ERROR}## [ERROR] $IAM_AUTH download failed ${NC}"
  fi

}

# Defined aws cli
# ref: https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2-mac.html
install_aws() {
  # set environment variables
  CLI_DOWN_URL="https://awscli.amazonaws.com"
  PKG="AWSCLIV2.pkg"

  # Started install
  DOWNLOAD_CLI=$(curl -s -LO -w "%{http_code}" "$CLI_DOWN_URL/$PKG")
  sleep 2;
  if [ "$DOWNLOAD_CLI" == 200 ]; then
    echo -e "${INFO}## [INFO] $PKG download successed ${NC}"
    sudo installer -pkg $PKG -target /
    sleep 2;
    [ -f "$PKG" ] && rm "$PKG"
  else
    echo -e "${ERROR}## [ERROR] $PKG download failed ${NC}"
  fi
}


# Defined kubectl
# ref: https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-macos/
install_kubectl() {
  # set environment variables
  KC="kubectl"
  KC_CHECKSUM="$KC.sha256"
  KC_VERSION="v1.19.13"
  KC_DOWN_URL="https://dl.k8s.io/release/$KC_VERSION/bin/darwin/amd64"

  # Started install
  DOWNLOAD_KC=$(curl -s -LO -w "%{http_code}" "$KC_DOWN_URL/$KC")
  sleep 2;
  if [ "$DOWNLOAD_KC" == 200 ]; then
    echo -e "${INFO}## [INFO] $KC download successed ${NC}"
    DOWNLOAD_KC_CHECKSUM=$(curl -s -LO -w "%{http_code}" "$KC_DOWN_URL/$KC_CHECKSUM")
    sleep 2;
    if [ "$DOWNLOAD_KC_CHECKSUM" == 200 ]; then
      echo -e "${INFO}## [INFO] $KC_CHECKSUM download successed ${NC}"
      echo -e "$(<$KC_CHECKSUM)  $KC" | shasum -a 256 --check

      echo -e "${INFO}## [INFO] Change execute mode ${NC}"
      [ -f "$KC" ] && chmod +x "./$KC"
      echo -e "${INFO}## [INFO] Move to ${WARN} $BIN_DIR/$KC"
      [ -f "$KC" ] && mv "./$KC" "$BIN_DIR/$KC"

      echo -e "${INFO}## [INFO] Remove $KC_CHECKSUM"
      [ -f "$KC_CHECKSUM" ] && rm "$KC_CHECKSUM"
      echo -e "${INFO}## [INFO] $KC Intalled ${NC}"

    else
      echo -e "${ERROR}## [ERROR] $KC_CHECKSUM download failed ${NC}"
    fi
  else
    echo -e "${ERROR}## [ERROR] $KC download failed ${NC}"
  fi
}

check_version () {
  case $1 in
    "aws")
      $1 --version
      ;;
    "aws-iam-authenticator")
      $1 version
      ;;
    "kubectl")
      $1 version --short --client
      ;;
  esac
}

# Definded staging kubeconfig
set_kubeconfig() {
  ENV="staging"
  CLUSTER="$ENV-eks-cluster"
  CLUSTER_NAME="$CLUSTER-cluster"
  CLUSTER_USER="$CLUSTER-user"
  ENDPOINT="https://76D103BB10EFF4B0D9F13851BD0F766A.yl4.ap-northeast-2.eks.amazonaws.com"
  CA_CERT="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1EY3hOakE0TkRreE5Wb1hEVEk1TURjeE16QTRORGt4TlZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTUFKCm84VVBPY1RVbFk0blNvbCtkVFcwc2lwVmk3ZU8yRlU4NUVKQ3dGcFAvdEdqV3NDQzRnWDgwdXYreDQxTVhRSlkKenVMWVFaVi8yRDZuUmdPeGFqMkxhVUtSNklWOUtVTFFzbXhERUpNM3pKK0tVZDB4aTUyLzlyaGFrb0Z2WjlydApHd3lwK3lkdDk5WTZyUUZIWmtGZlU3TWwyN1I1S0pRa0xrOFJiTTFhclN1cTNGVWFVV1ZHeUZQamVwQTMvblBjCkczbWMrQmdTcGlxQVoxWi9GTWY2K3c1bXYwUHhBcjNhSjhNTG51VTVHS1dBUThjWE81Y0hveEhkWFhYM0xva0gKYy8rUFlub2xQK0p2RkNtUUhYdzFZSGx2dzQ3ZEIzMmYvSE80dndWWm1YU3ExVTFmR1QrZDBJL1JIYy9vcFN2SQpFSWpHNFdyOXBSaTRaSGl2cEhrQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFBSm5BdVA1ZndYN0hwTnYxTW1kTmFTaWh4ME4KclNIaUNnRlFwZkl4WnptR29QOTFwa09TZDhMVEpHcnVUZkdPcFpoanBzTHcxeWJreEF3Rkl3cEk2aFU4UHViSQp3QlJrSVJKUS9OVzFFZGpBTDFuSnBQdm5SeDR0enl4NmdNUjk5RmUwUHNLVTdPOWlucW5LYUhiZVI5bXZNRE1VCjlLUlJ4a05BUWFtcnczT2VjMVRnb2hYWE9kcGx4RElvdEtYbDJjdDlOZUFnb2F5cnVDc3luU01JY2k5cXpuYjcKTGRwYnJBbWk3cE9vaTc1MkowaXJTSFVxQVg2dWl5MXZCSkFqblFmYjFEM0V2SkMxdS9ONXpuWU84dVV4WnBhcAo2MGxqeklDcWNpaW5XNDA1a2lEaVRPckxiWk9aWkxkcWFOWDRXUWdYUDB0Ty9kNWZXb283WjJvME55RT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
  KUBE_HOME="$HOME/.kube"
  STAGING_KUBE_CONFIG="$KUBE_HOME/config.$ENV"

  if [ ! -f "$STAGING_KUBE_CONFIG" ]; then
    read -p "$(echo -e "${QNA}## [INFO] Do you want to create $STAGING_KUBE_CONFIG? [Press Enter] ${NC}")"

    [ ! -d "$KUBE_HOME" ] && mkdir -p "$KUBE_HOME"
    cat > "$STAGING_KUBE_CONFIG" << EOF
apiVersion: v1
clusters:
- cluster:
    server: $ENDPOINT
    certificate-authority-data: $CA_CERT
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: $CLUSTER_USER
    namespace: default
  name: staging
current-context: staging
kind: Config
preferences: {}
users:
- name: $CLUSTER_USER
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - $CLUSTER

EOF
    echo -e "${NC}## [INFO] $STAGING_KUBE_CONFIG was created for kubernetes ${NC}"
  else
    echo -e "${WARN}## [WARN] $STAGING_KUBE_CONFIG already exists ${NC}"
  fi
}

set_customrc() {
  CUSTOMRC="$HOME/.customrc"
  ZSHRC="$HOME/.zshrc"

  # if [ ! -f "$CUSTOMRC" ] && ! grep -q "completion " "$CUSTOMRC"; then
  if [ ! -f "$CUSTOMRC" ]; then
    read -p "$(echo -e "${QNA}## [INFO] Do you want to create $CUSTOMRC? [Press Enter] ${NC}")"
    cat > "$CUSTOMRC" << EOF
##### Kubectl zsh auto-completion #####
source <(kubectl completion zsh)

##### aws cli auto-completion #####
# ref: https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-configure-completion.html
complete -C '/usr/local/bin/aws_completer' aws

autoload -U +X bashcompinit && bashcompinit

##### KUBECONFIG environment variables #####
export KUBE_HOME=\$HOME/.kube
export KUBE_STAGING=\$KUBE_HOME/config.staging
export KUBE_PRODUCTION=\$KUBE_HOME/config.production
export KUBECONFIG=\$KUBE_STAGING:\$KUBE_PRODUCTION

EOF
    echo -e "${NC}## [INFO] $CUSTOMRC was created for cli auto completion ${NC}"
    [ -f "$ZSHRC" ] && ! grep -q ".customrc" "$ZSHRC" && echo ". $CUSTOMRC" >> "$ZSHRC"
    echo -e "${NC}## [INFO] . $CUSTOMRC has been applied to $ZSHRC ${NC}"
  else
    echo -e "${WARN}## [WARN] $CUSTOMRC already exists ${NC}"
  fi
}

## set commands
for comm in "${COMMANDS[@]}"
do
  COMM_TYPE=$(type $comm &>/dev/null)
  if [ "$?" != 0 ]; then
    read -p "$(echo -e "${QNA}## [INFO] Do you want to install this [$comm] on you MacOS? [Press Enter] ${NC}")"
    echo -e "###################################################"
    echo -e "## $comm installation has started"
    echo -e "###################################################"
    install_"$comm"
    echo -e "${INFO}## [INFO] $comm intalled ${NC}"
    check_version $comm
  else
    echo -e "${INFO}## [INFO] $comm already intalled ${NC}"
    check_version $comm
  fi
done

set_kubeconfig
set_customrc
