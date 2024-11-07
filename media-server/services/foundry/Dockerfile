FROM gcr.io/distroless/nodejs18-debian11
WORKDIR /app
COPY ./source/resources/app .
EXPOSE 30000
CMD ["/app/main.js", "--dataPath=/data"]