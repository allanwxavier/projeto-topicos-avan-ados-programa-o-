
FROM node:18-slim


RUN apt-get update -y && apt-get install -y openssl

WORKDIR /app


RUN npm install -g typescript ts-node


COPY package*.json ./
COPY tsconfig.json ./
RUN npm install


COPY prisma ./prisma/
RUN npx prisma generate


COPY . .


EXPOSE 8080


CMD ["npx", "ts-node", "src/server.ts"]