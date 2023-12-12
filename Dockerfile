# Base image
FROM ubuntu:jammy AS hera-base

# Set default entrypoint (will be overriden in case of buildpack)
ENTRYPOINT ["/bin/bash"]


# Runner image
FROM hera-base as hera-runner

ARG cnb_uid=1002
ARG cnb_gid=1000

# Create user and group
RUN groupadd -g ${cnb_gid} cnb
RUN useradd -rms /bin/bash -u ${cnb_uid} -g ${cnb_gid} cpp

# Set user
USER ${cnb_uid}:${cnb_gid}


# Builder image
FROM hera-base AS hera-builder

ARG apt_get_dependencies="clang jq make python3 pipx"
#ARG apt_get_dependencies="build-essential jq make python3 pipx"

ARG apt_get_parameters="-y --no-install-recommends"
ARG cnb_uid=1001
ARG cnb_gid=1000
ARG pip_requirements_file="requirements.txt"

# Install apt-get dependencies
RUN apt-get update ${apt_get_parameters}
RUN apt-get install ${apt_get_parameters} ${apt_get_dependencies}

# Create user and group
ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}
RUN groupadd -g ${cnb_gid} cnb
RUN useradd -rms /bin/bash -u ${CNB_USER_ID} -g ${CNB_GROUP_ID} cpp

# Set user and path
USER ${CNB_USER_ID}:${CNB_GROUP_ID}
ENV PATH "/home/cpp/.local/bin:${PATH}"

# Install pip dependencies
COPY $pip_requirements_file ./
RUN xargs -I % pipx install "%" < requirements.txt

# Detect Conan profile
RUN conan --version && conan profile detect
