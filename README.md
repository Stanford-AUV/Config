# SAUV-Config

Contains Docker configs for running ROS2 Humble on our autonomy stack, SAUV-Autonomy. Please use the container to ensure a consistent development environment.

# Installation

1. On your Linux VM, install [Docker Desktop](https://docs.docker.com/desktop/install/linux-install/). If you're having trouble with installation like Miyu, install using the [apt repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository).

2. To pull the latest image, run: ```docker pull selenasun1618/ros2_humble:latest```

3. Create & move the necessary folders so your folder structure is as follows:


4. Build the image: sudo docker run -it --device /dev/i2c-7 -v path/to/local/SAUV/folder:/SAUV selenasun1618/ros2_humble:latest

You need the `--device` flag to access the i2c bus for the IMU.

# Usage

1. Upon starting the container

# TODO RUN THE SAME CONTAINER IN DIFF TERMINALS

# Updating the Docker image

If you added a new package to the image (in Dockerfile.ros2_humble), you need to update the image.

1. ```
   docker build -t sauv-autonomy-image .
   ```