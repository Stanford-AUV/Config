# NVIDIA base image
FROM nvcr.io/nvidia/l4t-base:r36.2.0

WORKDIR /SAUV

RUN apt-get update && apt-get install -y \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# disable terminal interaction for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV USE_DISTRIBUTED=on
ENV SHELL /bin/bash
SHELL ["/bin/bash", "-c"]

# Env setup
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV ROS_PYTHON_VERSION=3
ENV ROS_DISTRO=humble
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# Add ROS 2 apt repository
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# ROS fundamentals
RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y \
        devscripts \
        dh-make \
        fakeroot \
        libxtensor-dev \
        python3-bloom \
        python3-colcon-common-extensions \
        python3-pip \
        python3-pybind11 \
        python3-pytest-cov \
        python3-rosdep \
        python3-rosinstall-generator \
        python3-vcstool \
        quilt \
        ros-dev-tools \
        libopenblas-base \
        libopenmpi-dev \
        libjpeg-dev \
        zlib1g-dev
        
# ROS Python fundamentals
RUN apt-get install -y \
        python3-flake8-blind-except \
        python3-flake8-builtins \
        python3-flake8-class-newline \
        python3-flake8-comprehensions \
        python3-flake8-deprecated \
        python3-flake8-import-order \
        python3-flake8-quotes \
        python3-pytest-repeat \
        python3-pytest-rerunfailures

# Python Packages
RUN python3 -m pip install -U \
        numpy>=1.24.4 \
        matplotlib \
        pandas \
        rosbags \
        setuptools==65.7.0 \
        jetson-stats \
        ultralytics[export] \
        transforms3d \
        smbus2 \
        scipy \
        libusb1 \
        pyserial \
        simple_pid

# Install ROS 2 Humble
RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y \
    ros-humble-ros-base \
    ros-humble-angles \
    ros-humble-apriltag \
    ros-humble-behaviortree-cpp-v3 \
    ros-humble-bondcpp \
    ros-humble-camera-calibration-parsers \
    ros-humble-camera-info-manager \
    ros-humble-compressed-image-transport \
    ros-humble-compressed-depth-image-transport \
    ros-humble-cv-bridge \
    ros-humble-demo-nodes-cpp \
    ros-humble-demo-nodes-py \
    ros-humble-desktop \
    ros-humble-diagnostic-aggregator \
    ros-humble-diagnostic-updater \
    ros-humble-example-interfaces \
    ros-humble-foxglove-bridge \
    ros-humble-image-geometry \
    ros-humble-image-pipeline \
    ros-humble-image-transport \
    ros-humble-image-transport-plugins \
    ros-humble-launch-xml \
    ros-humble-launch-yaml \
    ros-humble-launch-testing \
    ros-humble-launch-testing-ament-cmake \
    ros-humble-nav2-bringup \
    ros-humble-nav2-msgs \
    ros-humble-nav2-mppi-controller \
    ros-humble-nav2-graceful-controller \
    ros-humble-navigation2 \
    ros-humble-ompl \
    ros-humble-resource-retriever \
    ros-humble-rmw-cyclonedds-cpp \
    ros-humble-rmw-fastrtps-cpp \
    ros-humble-rosbag2 \
    ros-humble-rosbag2-compression-zstd \
    ros-humble-rosbag2-cpp \
    ros-humble-rosbag2-py \
    ros-humble-rosbag2-storage-mcap \
    ros-humble-rosbridge-suite \
    ros-humble-rqt-graph \
    ros-humble-rqt-image-view \
    ros-humble-rqt-reconfigure \
    ros-humble-rqt-robot-monitor \
    ros-humble-rviz2 \
    ros-humble-rviz-common \
    ros-humble-rviz-default-plugins \
    ros-humble-sensor-msgs \
    ros-humble-slam-toolbox \
    ros-humble-v4l2-camera \
    ros-humble-vision-opencv \
    ros-humble-vision-msgs \
    ros-humble-vision-msgs-rviz-plugins \
    ros-humble-depthai-ros \
    ros-humble-nmea-msgs \
    ros-humble-mavros-msgs

# Setup rosdep
COPY rosdep/extra_rosdeps.yaml /etc/ros/rosdep/sources.list.d/nvidia-isaac.yaml
RUN --mount=type=cache,target=/var/cache/apt \
    rosdep init \
    && echo "yaml file:///etc/ros/rosdep/sources.list.d/nvidia-isaac.yaml" | tee /etc/ros/rosdep/sources.list.d/00-nvidia-isaac.list \
    && rosdep update

# Install torch
RUN wget https://nvidia.box.com/shared/static/0h6tk4msrl9xz3evft9t0mpwwwkw7a32.whl -0 /tmp/torch.whl \
    pip install /tmp/torch.whl \
    rm /tmp/torch.whl

# Install torch vision
RUN git clone https://github.com/pytorch/vision /tmp/torchvision && \
    cd /tmp/torchvision && \
    git checkout v0.16.2 && \
    python3 setup.py install --user
