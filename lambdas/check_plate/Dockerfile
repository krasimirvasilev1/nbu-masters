# Define custom function directory
ARG FUNCTION_DIR="/function"
ARG ALPR_DIR="/srv/openalpr"

FROM python:buster as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR
ARG ALPR_DIR

# Install aws-lambda-cpp build dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    make \
    curl \
    git \
    libcurl3-dev \
    libleptonica-dev \
    liblog4cplus-dev \
    libopencv-dev \
    libtesseract-dev \
    wget \
    python3 \
    python \
    python-pip \
    python3-pip \
    g++ \
    unzip \
    libcurl4-openssl-dev \
    autoconf \
    libtool

# Copy function code
RUN mkdir -p ${FUNCTION_DIR}

WORKDIR ${ALPR_DIR}

# Get OpenALPR repo
RUN git clone https://github.com/openalpr/openalpr.git .

# Setup the build directory
RUN mkdir -p src/build

# Setup the compile environment
RUN cd src/build && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc .. && \
    make -j2 && \
    make install

# Copy function code
RUN mkdir -p ${FUNCTION_DIR}
COPY app/* ${FUNCTION_DIR}

# Install the function's dependencies
RUN python3 -m pip install awslambdaric --target ${FUNCTION_DIR}

FROM python:slim-buster

RUN pip3 install boto3

# Install prerequisites
run apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libcurl3-dev \
    libleptonica-dev \
    liblog4cplus-dev \
    libopencv-dev \
    libtesseract-dev

# Include global arg in this stage of the build
ARG FUNCTION_DIR
ARG ALPR_DIR

# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR} 
COPY --from=build-image ${ALPR_DIR} ${ALPR_DIR}
COPY --from=build-image /usr/share/openalpr /usr/share/openalpr
COPY --from=build-image /usr/lib/libopenalpr* /usr/lib/
COPY --from=build-image /usr/include/*alpr* /usr/include/
COPY --from=build-image /usr/bin/*alpr* /usr/bin/
COPY --from=build-image /etc/openalpr/ /etc/openalpr/

# Create a dir for temporary images
RUN mkdir tmp_images

# (Optional) Add Lambda Runtime Interface Emulator and use a script in the ENTRYPOINT for simpler local runs
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY entry.sh /
RUN chmod 755 /usr/bin/aws-lambda-rie /entry.sh

ENTRYPOINT [ "/entry.sh" ]
CMD [ "app.handler" ]
