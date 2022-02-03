# Adapted from Deepcell Dockerfile 

# Use tensorflow/tensorflow as the base image
# Change the build arg to edit the tensorflow version.
# Only supporting python3.
ARG TF_VERSION=2.5.1-gpu

FROM tensorflow/tensorflow:${TF_VERSION}

# System maintenance
RUN apt-get update && apt-get install -y  \
    graphviz && \
    rm -rf /var/lib/apt/lists/* && \
    /usr/bin/python3 -m pip install --no-cache-dir --upgrade pip

# Copy the required setup files and install the deepcell-tf dependencies
COPY deepcell-tf/* /deepcell-tf/

# Prevent reinstallation of tensorflow and install all other requirements.
RUN sed -i "/tensorflow>/d" /deepcell-tf/requirements.txt && \
    pip install --no-cache-dir -r /deepcell-tf/requirements.txt

# Install deepcell via setup.py
RUN pip install deepcell

# Dockerfile adapted from Napari [https://github.com/napari/napari/blob/main/dockerfile]
# install miniconda from https://github.com/ContinuumIO/docker-images/tree/master/miniconda3/debian/Dockerfile
# install miniconda in ubuntu Docker from https://gist.github.com/pangyuteng/f5b00fe63ac31a27be00c56996197597
# install R packages from https://github.com/theislab/single-cell-tutorial/blob/master/Dockerfile
# install environment.yml from Gabriele Nasello
# Activate conda environment in Dockerfile https://pythonspeed.com/articles/activate-conda-dockerfile/

# ARG UBUNTU_VER=latest

# FROM ubuntu:${UBUNTU_VER}

# # below env var required to install libglib2.0-0 non-interactively
# # Avoiding user interaction with tzdata when installing ubuntu
# ENV TZ America/Los_Angeles
# ENV DEBIAN_FRONTEND noninteractive

# System packages 
RUN apt-get update && apt-get install -yq curl wget jq vim git unzip htop less nano emacs

# install graphical libraries used by qt and vispy
# From Napari Dockerfile [https://github.com/napari/napari/blob/main/dockerfile]
RUN \
  apt-get update && \
  apt-get install -qqy mesa-utils libgl1-mesa-glx  libglib2.0-0 && \
  apt-get install -qqy libfontconfig1 libxrender1 libdbus-1-3 libxkbcommon-x11-0 libxi6 && \
  apt-get install -qqy libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 && \
  apt-get install -qqy libxcb-xinerama0 libxcb-xinput0 libxcb-xfixes0 libxcb-shape0

ADD requirements.txt .

RUN pip install -r requirements.txt

# Initialize conda in bash config fiiles:
RUN echo "alias jl='export SHELL=/bin/bash; jupyter lab --allow-root --port=7777 --ip=0.0.0.0'" >> ~/.bashrc

RUN pip freeze > ../package_versions_py.txt

# Install Fiji.

# From OpenJDK Java 7 JRE Dockerfile
# http://dockerfile.github.io/#/java
# https://github.com/dockerfile/java
# https://github.com/dockerfile/java/tree/master/openjdk-7-jre
RUN \
  apt-get update && \
  apt-get install -y openjdk-11-jdk && \
  rm -rf /var/lib/apt/lists/*
# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# Regular instructions for installing imagej [https://www.scivision.dev/install-imagej-linux/]
WORKDIR /imagej
RUN wget https://downloads.imagej.net/fiji/latest/fiji-linux64.zip && \
    unzip fiji*.zip -d . && \
    rm fiji*.zip && \
    echo "alias imagej='/imagej/Fiji.app/ImageJ-linux64'" >> ~/.bashrc && \
    echo "alias fiji='/imagej/Fiji.app/ImageJ-linux64'" >> ~/.bashrc
# Install DeepCell-imagej-plugin
# [https://github.com/vanvalenlab/kiosk-imageJ-plugin]
RUN wget https://github.com/vanvalenlab/kiosk-imageJ-plugin/releases/download/0.3.2/Kiosk_ImageJ-0.3.2.jar && \
    mv Kiosk*.jar Fiji.app/plugins/
# Install Ilastik-imagej-plugin
RUN wget https://sites.imagej.net/Ilastik/plugins/ilastik4ij-1.8.2.jar-20210407103536 && \
    unzip ilastik* && \
    jar cf ilastik4ij-1.8.2.jar META-INF/* org/* && \
    mv ilastik4ij-1.8.2.jar Fiji.app/plugins/ && \
    rm -r META-INF/ org/ ilastik* 
WORKDIR /