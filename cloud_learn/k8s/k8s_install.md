# 安装K8S

## 安装docker环境

```sh
/bin/bash
#移除以前docker相关包
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
# 配置yum源
yum install -y yum-utils
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
#安装dockcer
yum install -y docker-ce-20.10.7 docker-ce-cli-20.10.7  containerd.io-1.4.6
#启动
systemctl enable docker --now
#配置加速器
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://rcl1cdp5.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
docker info
```

## 安装kubeadm

- 一台兼容的 Linux 主机。Kubernetes 项目为基于 Debian 和 Red Hat 的 Linux 发行版以及一些不提供包管理器的发行版提供通用的指令
- 每台机器 2 GB 或更多的 RAM （如果少于这个数字将会影响你应用的运行内存)

- 2 CPU 核或更多
- 集群中的所有机器的网络彼此均能相互连接(公网和内网都可以)

- - **设置防火墙放行规则**

- 节点之中不可以有重复的主机名、MAC 地址或 product_uuid。请参见[这里](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-mac-address)了解更多详细信息。

- - **设置不同hostname**

- 开启机器上的某些端口。请参见[这里](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports) 了解更多详细信息。

- - **内网互信**

- 禁用交换分区。为了保证 kubelet 正常工作，你 **必须** 禁用交换分区。

- - **永久关闭**

### 1、基础环境

```sh
#各个机器设置自己的域名
hostnamectl set-hostname xxxx
hostnamectl set-hostname k8s-master
hostnamectl set-hostname k8s-node1
hostnamectl set-hostname k8s-node2

# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

#关闭swap
swapoff -a  
sed -ri 's/.*swap.*/#&/' /etc/fstab

#允许 iptables 检查桥接流量
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

```

![image-20220213135001649](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213135001649.png)

![image-20220213135117782](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213135117782.png)

### 2、安装kubelet、kubeadm、kubectl



```sh
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
   http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF


sudo yum install -y kubelet-1.20.9 kubeadm-1.20.9 kubectl-1.20.9 --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```

> > 所有节点都需要执行
> >
> > 
>
> kubelet 现在每隔几秒就会重启，因为它陷入了一个等待 kubeadm 指令的死循环

![image-20220213141952764](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213141952764.png)

## 使用kubeadm引导集群

### 1、下载各个机器需要的镜像

```sh
sudo tee ./images.sh <<-'EOF'
#!/bin/bash
images=(
kube-apiserver:v1.20.9
kube-proxy:v1.20.9
kube-controller-manager:v1.20.9
kube-scheduler:v1.20.9
coredns:1.7.0
etcd:3.4.13-0
pause:3.2
)
for imageName in ${images[@]} ; do
docker pull registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/$imageName
done
EOF
   
chmod +x ./images.sh && ./images.sh
```

### 2、初始化主节点

```sh
#所有机器添加master域名映射，以下需要修改为自己的
echo "172.31.0.100 cluster-endpoint" >> /etc/hosts
#主节点初始化
kubeadm init \
--apiserver-advertise-address=172.31.0.100 \
--control-plane-endpoint=cluster-endpoint \
--image-repository registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images \
--kubernetes-version v1.20.9 \
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=192.168.0.0/16
#所有网络范围不重叠

```

![image-20220213143850055](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213143850055.png)

```sh

##初始化完成后的信息，用于添加节点
Your Kubernetes control-plane has initialized successfully!

##主节点执行如下信息
To start using your cluster, you need to run the following as a regular user:
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

  kubeadm join cluster-endpoint:6443 --token srtl5c.618lmpbu0gpxruhx \
    --discovery-token-ca-cert-hash sha256:9fc2ce76173023817677c5788b11bebfd3e12680f00c6632b84a6e9ac6f8e5c2 \
    --control-plane 

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join cluster-endpoint:6443 --token srtl5c.618lmpbu0gpxruhx \
    --discovery-token-ca-cert-hash sha256:9fc2ce76173023817677c5788b11bebfd3e12680f00c6632b84a6e9ac6f8e5c2 
```

#### 设置.kube/config

> 配置命令在初始化信息中

![image-20220213144215902](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213144215902.png)

### 3、 安装网络组件

```sh
curl https://docs.projectcalico.org/manifests/calico.yaml -O

kubectl apply -f calico.yaml
```

![image-20220213144848633](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213144848633.png)

>--pod-network-cid值如果修改了，需要修改 calico.yaml
>
>value: "192.168.0.0/16"

### 4、加入node节点

```sh
kubeadm join cluster-endpoint:6443 --token srtl5c.618lmpbu0gpxruhx \
    --discovery-token-ca-cert-hash sha256:9fc2ce76173023817677c5788b11bebfd3e12680f00c6632b84a6e9ac6f8e5c2 
```

>TOKEN24小时内有效，过期可以使用以下命令重新生成新令牌
>
>kubeadm token create --print-join-command

![image-20220213151234891](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213151234891.png)

> 问题处理
>
> 1、如果出现镜像拉取失败imagespullbakcoff的情况可以执行以下命令，查看失败原因，在失败的节点上拉取镜像
>
>  kubectl describe poDS -n kube-system calico-node-s26rt 

### 5、验证集群

- 验证集群节点状态

- - kubectl get nodes

### 6、部署dashboard

#### 1、部署 

kubernetes官方提供的可视化界面
https://github.com/kubernetes/dashboard

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
```

#### 2、设置访问端口

```sh
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
```

> type: ClusterIP 改为 type: NodePort

![image-20220213165128286](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213165128286.png)

```sh
kubectl get svc -A |grep kubernetes-dashboard
## 找到端口，在安全组放行
```

![image-20220213165215739](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213165215739.png)

访问： https://集群任意IP:端口      https://10.0.0.100:30368

#### 3、创建访问账号

```yaml
#创建访问账号，准备一个yaml文件； vi dash.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

```sh
kubectl apply -f dash.yaml
```

![image-20220213165413487](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220213165413487.png)

#### 4、令牌访问

```text

```

![image-20220213165508944](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220213165508944.png)

```sh
eyJhbGciOiJSUzI1NiIsImtpZCI6IklLLUtVV2VvMGE2a1hBT3NMU1JXY3FxTm9MRzNDQUZTQXBkQkVGc2ZRNXcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLWc5Z3A4Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIyOGRmNDQ2Ni03YTM1LTRiM2UtYWFkZC0xZWM3NmE2MDBkZWIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.BQcX86qMhgRtI6rK8LK5uhb_IJw-oZpiLkeSEjHngPyMIKhcQ8RfhQ0DuZ0ApoJt_59Qrpc6v2GzUZ8P-pDe3BcA0JV8g3QarYnQ458-LZhzIlCsaVvXFZMLGSA0l08FySXnckIEzdEZzuvsa7Q9aoMhe4eb_DpDmZj-jwEo7gBEVLKjuqdvLhak7BAcrsymVKXOioxZMKVJdglEXNDjBcBfnkbRM4pNKnP6Zp6m_qF2ILMlfB48IJFFDSN2EjAKvxro9mAwDJ98Al48w62phL_V6M-O_0KhCEhN4a2lJtuYuWmdQSQ5zUsDSs0NtCJaH6rb0u6Vf0wmUp_NvuonVA
```

