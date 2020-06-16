# BASE IMAGE #
FROM nginx:alpine

# Copy a sample of nginx configuration
COPY ./nginx.conf /etc/nginx/nginx.conf

# Adding bash to the image
RUN apk update && apk add bash
