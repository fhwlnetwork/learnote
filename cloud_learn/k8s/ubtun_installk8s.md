

## 关闭防火墙

root@wjh:~# ufw disable

![image-20220406211339317](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220406211339317.png)

## 安装docker

```sh
apt-get remove docker docker-engine docker.io containerd runc
apt-get update
apt-get install -y apt-transport-https ca-certificates curl  gnupg-agent software-properties-common
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository  "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce=5:20.10.6~3-0~ubuntu-focal docker-ce-cli=5:20.10.6~3-0~ubuntu-focal containerd.io -Y
cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload
systemctl restart docker
```



## 配置双网卡地址

> vim /etc/netplan/00-installer-config.yaml 

```yaml
# This is the network config written by 'subiquity'
mv /etc/netplan/00-installer-config.yaml  /etc/netplan/00-installer-config.yaml.bak2
cat << EOF | tee /etc/netplan/00-installer-config.yaml 
network:
  ethernets:
    ens33:
       dhcp4: no
       addresses:
         - 10.0.0.100/24
       gateway4: 10.0.0.2
       nameservers:
         addresses: [114.114.114.114]
    ens38:
      dhcp4: no
      addresses:
        - 172.31.0.100/24
  version: 2

```

## 关闭交换分区

```SH
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
#关闭swap
swapoff -a  
sed -ri.bak 's/.*swap.*/#&/' /etc/fstab
```

![image-20220406212230316](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220406212230316.png)



## 允许 iptables 检查桥接流量

```sh
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

## 更新 apt 包索引并安装使用 Kubernetes apt 存储库所需的包：

```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

```

## 安装 kubeadm

```sh
sudo curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
```

## 添加 Kubernetes apt 存储库

```sh
sudo tee /etc/apt/sources.list.d/kubernetes.list <<-'EOF'
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF
```

## 更新 apt 包索引，安装 kubelet、kubeadm 和 kubectl

```sh
sudo apt-get update 
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```



# ## kubeadm 初始化

```SH
>echo  "172.31.0.100 cncamp.com "  >> /etc/hosts
kubeadm init \
--apiserver-advertise-address=172.31.0.100 \
--control-plane-endpoint=cluster-endpoint \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.23.5 \
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=192.168.0.0/16
```

## 一键安装

```SH
#!/bin/bash
##配置网卡ip

apt-get remove docker docker-engine docker.io containerd runc
apt-get update
apt-get install -y apt-transport-https ca-certificates curl  gnupg-agent software-properties-common
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository  "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ $(lsb_release -cs) stable"
apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl daemon-reload
systemctl restart docker

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
#关闭swap
swapoff -a  
sed -ri.bak 's/.*swap.*/#&/' /etc/fstab

#允许 iptables 检查桥接流量
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

#更新 apt 包索引并安装使用 Kubernetes apt 存储库所需的包：
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

#安装 kubeadm
sudo curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
#添加 Kubernetes apt 存储库
sudo tee /etc/apt/sources.list.d/kubernetes.list <<-'EOF'
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF

# 更新 apt 包索引，安装 kubelet、kubeadm 和 kubectl
sudo apt-get update 
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "172.31.0.129 cncamp.com" >> /etc/hosts

kubeadm init --apiserver-advertise-address=172.31.0.100 --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.23.5 --service-cidr=10.96.0.0/16 --pod-network-cidr=192.168.0.0/16 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml


```

