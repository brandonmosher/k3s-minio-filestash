FROM debian:9 AS builder
ARG GO_VERSION=1.18.1
ARG NODE_VERSION=v14.19.1
ARG ARCH=linux-arm64

RUN apt-get update && \
    apt-get install -y git curl && \
    curl -LO https://go.dev/dl/go${GO_VERSION}.${ARCH}.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.${ARCH}.tar.gz && \
    curl -LO https://nodejs.org/download/release/${NODE_VERSION}/node-${NODE_VERSION}-${ARCH}.tar.gz && \
    mkdir -p /usr/local/lib/nodejs && \
    tar -xzf node-${NODE_VERSION}-${ARCH}.tar.gz -C /usr/local/lib/nodejs && \
    git clone https://github.com/mickael-kerjean/filestash

ENV PATH=${PATH}:/usr/local/go/bin:/usr/local/lib/nodejs/node-${NODE_VERSION}-${ARCH}/bin:$PATH

WORKDIR /filestash/server/plugin/plg_image_light/deps/

COPY create_libresize.sh create_libtranscode.sh ./

RUN chmod +x create_libresize.sh create_libtranscode.sh && \
    ./create_libresize.sh && \
    ./create_libtranscode.sh

WORKDIR /filestash/server/plugin/plg_image_light

RUN sed -i '3 i // #cgo LDFLAGS: -lm -lgmodule-2.0 -lgobject-2.0 -lglib-2.0 -ldl -L./deps -l:libresize.a' lib_resize.go && \
    sed -i '3 i // #cgo LDFLAGS: -lm -lpthread -L./deps -l:libtranscode.a' lib_transcode.go

WORKDIR /filestash

RUN mkdir -p ./dist/data/state/config && \
    cp config/config.json ./dist/data/state/config/ && \
    mkdir -p ./filestash/data/state/config && \
    cp config/config.json ./filestash/data/state/config/ && \
    make build_init

RUN make build_backend && \
    cp dist/filestash filestash

RUN npm install --unsafe-perm=true --allow-root && \
    make build_frontend && \
    cp -R ./dist/data/public ./filestash/data/public

FROM debian:9

COPY --from=builder /filestash/filestash /filestash

RUN apt-get update && \
    apt-get install -y libglib2.0-0 && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENTRYPOINT ./filestash/filestash

