# create a computer with go installed called builder
FROM golang:1.26.1 AS builder
# create a dir called /app on that computer
WORKDIR /app
# copy all of this repos contents into that folder
COPY . .
# build an exe from the ./cmd called "gatekeeper"
RUN go build -o gatekeeper ./cmd


# start a second, empty computer
FROM debian:stable-slim
# make and enter a seperate /app folder
WORKDIR /app
# fetch the gapekeeper exe file stored on the builder computer and place into local /app
COPY --from=builder /app/gatekeeper .
# when this container runs, execute this file
CMD ["./gatekeeper"]


