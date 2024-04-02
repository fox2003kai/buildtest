# ベースイメージとしてPythonを使用する
FROM python:3.12.2 AS builder

ARG GIT_VERSION

# Gitをソースからビルドしてインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    libghc-zlib-dev \
    libssl-dev \
    make \
    wget \
    && wget https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz \
    && tar -xf v${GIT_VERSION}.tar.gz \
    && cd git-* \
    && make prefix=/usr/local all \
    && make prefix=/usr/local install \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 最終的なイメージを構築する
FROM python:3.12.2

ARG USERNAME

# ベースイメージから必要なパッケージをコピーする
COPY --from=builder /usr/local/bin/git /usr/local/bin/git

# ホストユーザーをDevContainer上に作成
RUN groupadd -g 1000 ${USERNAME} \
    && useradd -u 1000 -g ${USERNAME} -s /bin/bash -m ${USERNAME} \
    && mkdir -m 777 /workspaces

USER ${USERNAME}
WORKDIR /work
