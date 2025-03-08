FROM node:20.11-alpine3.18 as build

WORKDIR /usr/src/ozone

# Install dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Remove development dependencies and cache
RUN rm -rf node_modules .next/cache
RUN mv service/package.json package.json && mv service/yarn.lock yarn.lock
RUN yarn install --production

# Final stage
FROM node:20.11-alpine3.18

# Install dumb-init for proper process management
RUN apk add --update dumb-init
ENV TZ=Etc/UTC

WORKDIR /usr/src/ozone
COPY --from=build /usr/src/ozone /usr/src/ozone
RUN chown -R node:node .

# Configure the application
ENV PORT=3000
ENV NODE_ENV=production

# Set up the container
EXPOSE 3000
USER node
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "./service"]

LABEL org.opencontainers.image.source=https://github.com/bluesky-social/ozone
LABEL org.opencontainers.image.description="Ozone Moderation Service Web UI"
LABEL org.opencontainers.image.licenses=MIT
