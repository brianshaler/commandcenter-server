FROM node:5.7-slim

WORKDIR /usr/src/app

RUN npm install -g gulp@3.8.6

ADD package.json /usr/src/app/

RUN npm install

ADD . /usr/src/app/

RUN gulp

CMD ["npm", "start"]
