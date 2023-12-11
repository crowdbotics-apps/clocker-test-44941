# Start from the base image
FROM timbru31/ruby-node:3.3-slim-hydrogen

# Install Python 2 from an alternative source
RUN apt-get update && apt-get install -y wget gnupg2
RUN apt-get update && \
    apt-get install -y python3


# Create a symbolic link to python2
RUN ln -s /usr/local/bin/python2.7 /usr/bin/python

# Continue with your existing setup
WORKDIR /app/webapp/

RUN gem update bundler
COPY Gemfile Gemfile.lock /app/webapp/
RUN bundle install

COPY package.json package-lock.json /app/webapp/
RUN npm install

COPY . /app/webapp/

CMD ["npm", "start"]
