# Ubuntu 22.04 + ROS 2 Humble
FROM osrf/ros:humble-desktop

LABEL authors="Aubrey-xiang YD07-xyt"
ENV DEBIAN_FRONTEND=noninteractive

# 基础工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales curl gnupg2 ca-certificates lsb-release \
    build-essential git pkg-config \
    wget software-properties-common \
    libopencv-dev libeigen3-dev libsuitesparse-dev \
    python3-rosdep python3-colcon-common-extensions python3-argcomplete \
  && rm -rf /var/lib/apt/lists/*

# Locale
RUN locale-gen en_US en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# CMake
RUN set -eux; \
  wget -qO- https://apt.kitware.com/keys/kitware-archive-latest.asc \
  | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg; \
  echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
  > /etc/apt/sources.list.d/kitware.list; \
  apt-get update && apt-get install -y --no-install-recommends cmake \
  && rm -rf /var/lib/apt/lists/*

# OpenVINO
RUN set -eux; \
  wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
  | gpg --dearmor -o /usr/share/keyrings/intel-products-archive-keyring.gpg; \
  echo "deb [signed-by=/usr/share/keyrings/intel-products-archive-keyring.gpg] https://apt.repos.intel.com/openvino ubuntu22 main" \
  > /etc/apt/sources.list.d/intel-openvino.list; \
  apt-get update && apt-get install -y --no-install-recommends \
    openvino-2025.2.0 \
  && rm -rf /var/lib/apt/lists/*

# 创建工作区 
WORKDIR /ma_auto_aim
RUN mkdir -p environment/mindvision environment/Sophus environment/g2o src

# 先复制依赖源码（利用缓存）
COPY mindvision ./environment/mindvision
COPY auto_aim   ./src

# 安装 mindvision
RUN set -eux; \
  cd environment/mindvision && chmod +x install.sh && ./install.sh || true; \
  rm -rf /var/lib/apt/lists/*

# 安装 ROS 依赖包 
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-camera-info-manager \
    ros-humble-xacro \
    ros-humble-foxglove-bridge \
    libfmt-dev \
  && rm -rf /var/lib/apt/lists/*
  
# 安装 Sophus
RUN set -eux; \
  cd environment/Sophus && \
  git clone https://github.com/strasdat/Sophus.git && \
  cd Sophus && mkdir -p build && cd build && \
  cmake .. -DCMAKE_BUILD_TYPE=Release && \
  make -j"$(nproc)" && make install && \
  ldconfig


# 安装 g2o
RUN set -eux; \
  cd environment/g2o && \
  git clone https://github.com/RainerKuemmerle/g2o.git && \
  cd g2o && mkdir -p build && cd build && \
  cmake .. -DCMAKE_BUILD_TYPE=Release && \
  make -j"$(nproc)" && make install && \
  ldconfig

# Ceres Solver
RUN apt-get update && apt-get install -y --no-install-recommends \
    libceres-dev \
  && rm -rf /var/lib/apt/lists/*

# rosdep 初始化 + 依赖安装
# 注：容器里可能已经 init 过；失败不致命
RUN set -eux; \
  rosdep init || true; \
  rosdep update; \
  cd /ma_auto_aim && rosdep install --from-paths src --ignore-src -r -y || true

# 自动 source ROS 环境 
# 进入 bash 自动加载 ROS 环境和 colcon 补全
SHELL ["/bin/bash","-lc"]
RUN set -eux; \
    echo 'source /opt/ros/humble/setup.bash' >> /etc/bash.bashrc; \
    activate-global-python-argcomplete || true

# xcb    
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx libxkbcommon-x11-0 libxcb-xinerama0 libxcb-cursor0 \
    libx11-xcb1 libxrender1 libxi6 libxrandr2 libfontconfig1 libfreetype6 \
 && rm -rf /var/lib/apt/lists/*

ENV QT_QPA_PLATFORM=xcb

# 还原交互模式环境变量
ENV DEBIAN_FRONTEND=

# 默认工作目录 & 启动命令
WORKDIR /ma_auto_aim/src
SHELL ["/bin/bash","-lc"]
CMD ["bash"]

