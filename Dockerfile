# Dockerfile adapted from Napari [https://github.com/napari/napari/blob/main/dockerfile]
# install miniconda from https://github.com/ContinuumIO/docker-images/tree/master/miniconda3/debian/Dockerfile
# install miniconda in ubuntu Docker from https://gist.github.com/pangyuteng/f5b00fe63ac31a27be00c56996197597
# install R packages from https://github.com/theislab/single-cell-tutorial/blob/master/Dockerfile
# install environment.yml from Gabriele Nasello
# Activate conda environment in Dockerfile https://pythonspeed.com/articles/activate-conda-dockerfile/

ARG UBUNTU_VER=latest

FROM ubuntu:${UBUNTU_VER}

# below env var required to install libglib2.0-0 non-interactively
# Avoiding user interaction with tzdata when installing ubuntu
ENV TZ America/Los_Angeles
ENV DEBIAN_FRONTEND noninteractive

# System packages 
RUN apt-get update && apt-get install -yq curl wget jq vim git unzip curl htop less nano emacs

# install graphical libraries used by qt and vispy
# From Napari Dockerfile [https://github.com/napari/napari/blob/main/dockerfile]
RUN \
  apt-get update && \
  apt-get install -qqy mesa-utils libgl1-mesa-glx  libglib2.0-0 && \
  apt-get install -qqy libfontconfig1 libxrender1 libdbus-1-3 libxkbcommon-x11-0 libxi6 && \
  apt-get install -qqy libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 && \
  apt-get install -qqy libxcb-xinerama0 libxcb-xinput0 libxcb-xfixes0 libxcb-shape0

# RUN apt-get install -qqy mesa-utils libgl1-mesa-glx  libglib2.0-0
# RUN apt-get install -qqy libfontconfig1 libxrender1 libdbus-1-3 libxkbcommon-x11-0 libxi6
# RUN apt-get install -qqy libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0
# RUN apt-get install -qqy libxcb-xinerama0 libxcb-xinput0 libxcb-xfixes0 libxcb-shape0

# Make RUN commands use `bash --login`:
SHELL ["/bin/bash", "--login", "-c"]

ENV PATH /opt/conda/bin:$PATH

CMD [ "/bin/bash" ]

# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=py38_4.9.2

RUN set -x && \
    UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
        SHA256SUM="1314b90489f154602fd794accfc90446111514a5a72fe1f71ab83e07de9504a7"; \
    elif [ "${UNAME_M}" = "s390x" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-s390x.sh"; \
        SHA256SUM="4e6ace66b732170689fd2a7d86559f674f2de0a0a0fbaefd86ef597d52b89d16"; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-aarch64.sh"; \
        SHA256SUM="b6fbba97d7cef35ebee8739536752cd8b8b414f88e237146b11ebf081c44618f"; \
    elif [ "${UNAME_M}" = "ppc64le" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-ppc64le.sh"; \
        SHA256SUM="2b111dab4b72a34c969188aa7a91eca927a034b14a87f725fa8d295955364e71"; \
    fi && \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

ADD environment.yml .

RUN conda env create -f environment.yml

# Initialize conda in bash config fiiles:
RUN conda init bash  && \
    echo "conda activate imagepy-env" >> ~/.bashrc && \
    echo "alias jl='export SHELL=/bin/bash; jupyter lab --allow-root --port=7777 --ip=0.0.0.0'" >> ~/.bashrc

RUN pip freeze > ../package_versions_py.txt

RUN conda list --explicit > ../spec-conda-file.txt

RUN echo "conda env list" >> ~/.bashrc

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