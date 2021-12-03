# Create a Docker Image with python environment for image processing and Fiji (ImageJ) 

## How it works

The ```Dockerfile``` creates a Docker Image from [Tensorflow](https://hub.docker.com/layers/tensorflow/tensorflow/2.5.1-gpu/images/sha256-ccf22168cc21cd4977065fccd9f58d3f305a103227bb97347242fc0dca87dc95?context=explore). After, it downloads Python packages for image processing (through ```requirements.txt.txt```) and installs Fiji. 

The full list of the Python  packages installed is saved within the docker image in ```package_versions_py.txt```

## Create a new image

First, clone the repo:

```git clone https://github.com/gabnasello/imagepy-env.git``` 

and run the following command to build the image (you might need sudo privileges):

```docker build --no-cache -t imagepy-env:latest .```

Then you can follow the instructions in the [Docker repository](https://hub.docker.com/repository/docker/gnasello/imagepy-env) to use the virtual environment.

Enjoy image processing!