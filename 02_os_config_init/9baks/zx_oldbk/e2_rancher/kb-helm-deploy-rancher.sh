##使用国内镜像源来安装K3S~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mkdir -p /etc/rancher/k3s
bash -c 'tee /etc/rancher/k3s/registries.yaml <<-EOF
mirrors:
  docker.io:
    endpoint:
    - "https://vgnxamtipjkx4a.xuanyuan.run"
    - "https://docker.m.daocloud.io"

  gcr.io:
    endpoint:
    - "https://vgnxamtipjkx4a-gcr.xuanyuan.run"
    - "https://gcr.m.daocloud.io"

  quay.io:
    endpoint:
    - "https://vgnxamtipjkx4a-quay.xuanyuan.run"
    - "https://quay.m.daocloud.io"

  registry.k8s.io:
    endpoint:
    - "https://vgnxamtipjkx4a-k8s.xuanyuan.run"
    - "https://k8s.m.daocloud.io"
EOF'

export INSTALL_K3S_VERSION="v1.32.7+k3s1" # 明确指定K3S版本
export INSTALL_K3S_MIRROR="cn"            # 启用国内镜像加速
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh |
  INSTALL_K3S_MIRROR="cn" INSTALL_K3S_VERSION="v1.32.7+k3s1" \
    bash -s - server --cluster-init

##直接安装cert-manager~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
yml_cert_mgr=https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml
kubectl apply -f https://ghfast.top/$yml_cert_mgr

##安装HELM~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
make ist/helm
##添加helm repo~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
# chnnel=latest
chnnel=stable
reponame=rancher-$chnnel
helm repo add $reponame https://rancher-mirror.rancher.cn/server-charts/$chnnel
kubectl create namespace cattle-system

helm install rancher $reponame/rancher \
  --namespace cattle-system \
  --set replicas=1 \
  --set hostname=192.168.100.2.sslip.io \
  --set bootstrapPassword=ljjx-rancher \
  --set rancherImage=registry.cn-hangzhou.aliyuncs.com/rancher/rancher \
  --set systemDefaultRegistry=registry.cn-hangzhou.aliyuncs.com
