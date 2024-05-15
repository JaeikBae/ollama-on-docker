FROM nvidia/cuda:11.4.3-cudnn8-runtime-ubuntu20.04


RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget vim curl pciutils lshw apt-utils git build-essential

WORKDIR /ws

RUN mkdir -p /usr/share/keyrings && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub | gpg --dearmor -o /usr/share/keyrings/cuda-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cuda-archive-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/cuda.list
RUN curl -fsSL https://ollama.com/install.sh | sh

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=20

RUN bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION"

RUN bash -c "source $NVM_DIR/nvm.sh && ln -s $NVM_DIR/versions/node/v$NODE_VERSION/bin/node /usr/local/bin/node && ln -s $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm /usr/local/bin/npm"

RUN bash -c "source $NVM_DIR/nvm.sh && npm -v"

RUN git clone https://github.com/open-webui/open-webui.git

WORKDIR /ws/open-webui/

RUN cp -RPp .env.example .env

RUN bash -c "source $NVM_DIR/nvm.sh && npm install"
RUN bash -c "source $NVM_DIR/nvm.sh && npm run build"

RUN apt-get install -y software-properties-common

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install -y python3.9 python3.9-dev python3-pip

RUN python3 -m pip install --upgrade pip 
RUN ln -sf /usr/bin/python3.9 /usr/bin/python3
WORKDIR /ws/open-webui/backend
RUN pip3 install -r requirements.txt

RUN pip3 uninstall -y protobuf
RUN pip3 install protobuf==3.19.4

RUN pip3 install google-generativeai
RUN pip3 install pysqlite3-binary
RUN sed -i '1i __import__("pysqlite3")' /usr/local/lib/python3.9/dist-packages/chromadb/__init__.py
RUN sed -i '2i import sys' /usr/local/lib/python3.9/dist-packages/chromadb/__init__.py
RUN sed -i '3i sys.modules["sqlite3"] = sys.modules.pop("pysqlite3")' /usr/local/lib/python3.9/dist-packages/chromadb/__init__.py

RUN echo "ollama serve &" > serve.sh
RUN echo "PORT='8000' bash start.sh" >> serve.sh

CMD ["bash", "serve.sh"]


