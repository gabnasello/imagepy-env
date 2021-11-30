# Create a Docker Image with a conda environment for image processing

## How it works

The ```Dockerfile``` creates a Docker Image on Ubuntu and installs miniconda. After, it creates a virtual environment called imagepy-env from the ```environment.ylm``` file.

The full list of the Python  packages installed is saved within the docker image in ```spec-conda-file.txt```  and```package_versions_py.txt```

## Create a new image

First, clone the repo:

```git clone https://github.com/gabnasello/imagepy-env.git``` 

and run the following command to build the image (you might need sudo privileges):

```docker build --no-cache -t imagepy-env:latest .```

Then you can follow the instructions in the [Docker repository](https://hub.docker.com/repository/docker/gnasello/imagepy-env) to use the virtual environment.

Enjoy image processing!