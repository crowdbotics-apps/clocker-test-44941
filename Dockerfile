# Start from the base image
FROM timbru31/ruby-node:3.1

# Install Python 2 from an alternative source
RUN apt-get update && apt-get install -y wget gnupg2
RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz && \
    tar -xvf Python-2.7.18.tgz && \
    cd Python-2.7.18 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf Python-2.7.18*

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
