#FROM nvidia/cuda:11.3.1-base-ubuntu20.04
#FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04
#FROM nvidia/cuda:11.6.1-devel-ubuntu20.04
# Use an official Miniconda runtime as a parent image
#FROM continuumio/miniconda3:latest
#FROM nvidia/cuda:11.3.1-devel-ubuntu20.04
#nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04


FROM nvidia/cuda:11.6.1-devel-ubuntu20.04
#FROM nvidia/cuda:12.6.1-devel-ubuntu20.04

ENV PYTHON_VERSION=3.8
# Set CUDA 11.6 as the default CUDA path
#ENV CUDA_HOME=/usr/local/cuda-11.6
#ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

RUN apt-get update && apt-get install -y \
    build-essential \
    nano \
    unzip \
    wget \
    git \
    libxrender1 \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libegl1-mesa \
    libgbm1 \
    freeglut3-dev \
    mesa-utils \ 
    && rm -rf /var/lib/apt/lists/
#ultime 2 righe consigliate da chatgpt

# Install Miniconda
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda.sh && \
    chmod +x /miniconda.sh && \
    /miniconda.sh -b -p /opt/conda && \
    rm /miniconda.sh && \
    /opt/conda/bin/conda clean -ya

# Add Conda to the PATH
ENV PATH=/opt/conda/bin:$PATH

# Ensure all NVIDIA GPUs are visible
ENV NVIDIA_VISIBLE_DEVICES all

ENV PYOPENGL_PLATFORM=egl
ENV MESA_GL_VERSION_OVERRIDE=3.3 

#update conda
RUN conda update -n base -c defaults conda -y

# Set working directory
WORKDIR /app

# Copy the environment.yml file into the container at /app
COPY environment.yaml /app/environment.yaml
COPY requirements.txt /app/requirements.txt
COPY requirements_colab.txt /app/requirements_colab.txt

# Create the Conda environment
RUN conda env create -f environment.yaml

# # Ensure the non-root user can write to the Conda environment
# ARG UID=1001
# ARG GID=1001

# # Change ownership of only necessary directories per essere piu' veloce
# RUN chown -R ${UID}:${GID} /opt/conda/envs /opt/conda/pkgs

# # Create group and user with the same IDs as your host system
# RUN groupadd -g ${GID} yourgroup && \
#     useradd -u ${UID} -g ${GID} -m youruser

# # Switch to the new user
# USER youruser

# Activate the Conda environment and run a command to confirm the environment is available
RUN echo "source activate icon" > ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc && conda info --envs"

# Activate the Conda environment
SHELL ["conda", "run", "-n", "icon", "/bin/bash", "-c"]

# python libs
RUN pip install --upgrade pip
# Update setuptools and wheel to the latest version
#RUN pip install --upgrade setuptools wheel
# Install the packaging library
#RUN pip install packaging

#RUN pip install -r requirements_colab.txt --use-deprecated=legacy-resolver #non usare
RUN pip install -r requirements.txt --use-deprecated=legacy-resolver 

#installarlo dentro al requirements da problemi con cython
RUN pip install simple-romp --use-deprecated=legacy-resolver

#RUN pip install git+https://github.com/facebookresearch/pytorch3d.git@v0.7.1
RUN pip install kaolin==0.13.0 -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-1.13.1_cu116.html
#RUN pip install git+https://github.com/YuliangXiu/neural_voxelization_layer.git
RUN pip install git+https://github.com/YuliangXiu/rembg.git

# installing pytorch3d
#RUN pip install --no-index --no-cache-dir pytorch3d -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py38_cu113_pyt1110/download.html
RUN pip install --no-index --no-cache-dir pytorch3d -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py38_cu116_pyt1130/download.html

#RUN pip install trimesh
#RUN pip install pyembree

# Set the entry point to activate the Conda environment and start a shell
#ENTRYPOINT ["conda", "run", "-n", "pifu", "/bin/bash"]
