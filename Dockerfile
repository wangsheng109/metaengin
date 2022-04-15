FROM golang:1.15 AS build

WORKDIR /src
# enable modules caching in separate layer
COPY go.mod go.sum ./
RUN go mod download
COPY . ./

RUN make binary

FROM debian:10.2-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    groupadd -r voyager --gid 999; \
    useradd -r -g voyager --uid 999 --no-log-init -m voyager;

# make sure mounted volumes have correct permissions
RUN mkdir -p /home/voyager/.voyager && chown 999:999 /home/voyager/.voyager

COPY --from=build /src/dist/voyager /usr/local/bin/voyager

EXPOSE 1633 1634 1635
USER voyager
WORKDIR /home/voyager
VOLUME /home/voyager/.voyager

ENTRYPOINT ["voyager"]
