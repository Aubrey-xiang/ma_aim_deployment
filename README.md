# MA_auto_aim

非常感谢YD07-xyt的框架提供

在配置环境之前一定要下载好梯子并且打开TUN模式，确保能够科学上网之后再进行配置

话说回来，docker虽快，但弊端也太多，推荐仅供应对紧急情况或者调试测试

## 环境配置
### 1.安装docker

建议安装docker engine 

参考了官网：

```
https://docs.docker.com/engine/install/ubuntu/
```

按照以下步骤进行安装：

```
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

运行以下命令检测是否安装成功

```
sudo docker run hello-world
```


### 2.获取镜像

docker安装好后clone该项目至你的电脑

```
git clone https://github.com/Aubrey-xiang/ma_aim_deployment.git
```

我已经把构建好的镜像上传了docker hub，通过以下命令拉取环境镜像

```
sudo docker pull aubrey888/mavision:latest
```

也可以自己构建镜像（可能会比较卡），运行构建脚本

```
./build.sh
```

### 3.注意事项

<img width="692" height="183" alt="image" src="https://github.com/user-attachments/assets/dcc4d90b-ab4f-4aee-be97-97700cb85828" />

1.build.sh：构建本地镜像

2.first_run.sh:第一次跑脚本，运行该脚本后会生成一个容器，exit后不会删除

3.restart.sh:运行first_run.sh脚本后，若退出了，第二次启动直接restart即可

4.shell.sh:在容器中打开新终端

5.clear.sh:清除容器

若遇到脚本权限不够，给该脚本附权

```
sudo chmod +x 该脚本
```


