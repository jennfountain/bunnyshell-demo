FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Python and development tools
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3-pip \
    python3-venv \
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

WORKDIR /app

# Install Python development tools
RUN pip install --no-cache-dir --break-system-packages \
    ipython \
    ipdb \
    pytest \
    black \
    ruff

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir --break-system-packages -r requirements.txt

# Copy application code
COPY . .

EXPOSE 8000

# Default to bash shell for development
CMD ["/bin/bash"]
