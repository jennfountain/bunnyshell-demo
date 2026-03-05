FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install software-properties-common to add PPAs
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update

# Install Python 3.12 and development tools
RUN apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3.12-distutils \
    git \
    curl \
    wget \
    vim \
    nano \
    build-essential \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for python
RUN ln -sf /usr/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/bin/python3.12 /usr/bin/python3

# Install pip for Python 3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

WORKDIR /app

# Install Python development tools
RUN python3.12 -m pip install --no-cache-dir \
    ipython \
    ipdb \
    pytest \
    black \
    ruff

# Copy requirements and install
COPY requirements.txt .
RUN python3.12 -m pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

EXPOSE 8000

# Default to bash shell for development
CMD ["/bin/bash"]
