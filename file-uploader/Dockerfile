# build environment
FROM node:13.12.0-alpine as build

ARG STORAGE_SAS_TOKEN=test
ARG STORAGE_RESOURCE_NAME=test

ENV REACT_APP_STORAGESASTOKEN=$STORAGE_SAS_TOKEN
ENV REACT_APP_STORAGERESOURCENAME=$STORAGE_RESOURCE_NAME

WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY package.json ./
COPY package-lock.json ./
RUN npm ci --silent
RUN npm install react-scripts@3.4.1 -g --silent
COPY . ./
RUN npm run build

# production environment
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

