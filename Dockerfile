FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=drownfish
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

LABEL org.opencontainers.image.title="Drownfish development environment"
LABEL org.opencontainers.image.description="C++ build, test, and UCI runtime environment for Drownfish"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        clang \
        clang-format \
        clangd \
        cmake \
        curl \
        expect \
        g++-multilib \
        gdb \
        git \
        jq \
        less \
        lld \
        lldb \
        make \
        nano \
        procps \
        python3 \
        python3-pip \
        sudo \
        time \
        unzip \
        valgrind \
        vim \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    if getent group "${USER_GID}" > /dev/null; then \
        group_name="$(getent group "${USER_GID}" | cut -d: -f1)"; \
        if [ "${group_name}" != "${USERNAME}" ]; then groupmod --new-name "${USERNAME}" "${group_name}"; fi; \
    else \
        groupadd --gid "${USER_GID}" "${USERNAME}"; \
    fi; \
    if getent passwd "${USER_UID}" > /dev/null; then \
        user_name="$(getent passwd "${USER_UID}" | cut -d: -f1)"; \
        if [ "${user_name}" != "${USERNAME}" ]; then \
            usermod --login "${USERNAME}" --home "/home/${USERNAME}" --move-home "${user_name}"; \
        fi; \
        usermod --gid "${USER_GID}" --shell /bin/bash "${USERNAME}"; \
    else \
        useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /bin/bash "${USERNAME}"; \
    fi; \
    echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"; \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"

WORKDIR /workspaces/Drownfish

USER ${USERNAME}

ENV COMP=gcc \
    COMPCXX=g++ \
    MAKEFLAGS=-j

CMD ["bash"]
