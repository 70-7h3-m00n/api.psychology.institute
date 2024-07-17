FROM node:20 as build
# Installing dependencies for sharp Compatibility
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    autoconf \
    automake \
    zlib1g-dev \
    libpng-dev \
    libvips-dev \
    git && \
    rm -rf /var/lib/apt/lists/*
    
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
WORKDIR /opt/
COPY ./package.json ./package-lock.json ./
ENV PATH /opt/node_modules/.bin:$PATH
RUN npm config set fetch-retry-maxtimeout 600000 -g && npm install
WORKDIR /opt/app
COPY ./ .
RUN npm run build

FROM node:20
RUN apt-get update && apt-get install -y libvips-dev && rm -rf /var/lib/apt/lists/*
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
WORKDIR /opt/app
COPY --from=build /opt/node_modules ./node_modules
ENV PATH /opt/node_modules/.bin:$PATH
COPY --from=build /opt/app ./
EXPOSE 1337
CMD ["npm", "start"]
