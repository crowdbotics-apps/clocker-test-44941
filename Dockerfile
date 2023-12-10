FROM timbru31/ruby-node:3.1

# Install Python 2
RUN apt-get update && apt-get install -y python2

# If 'python' symbolic link exists, remove it
RUN if [ -f /usr/bin/python ]; then rm /usr/bin/python; fi

# Create a symbolic link to python2
RUN ln -s /usr/bin/python2 /usr/bin/python

# Continue with your existing setup
WORKDIR /app/webapp/

RUN gem update bundler
COPY Gemfile Gemfile.lock /app/webapp/
RUN bundle install

COPY package.json package-lock.json /app/webapp/
RUN npm install

COPY . /app/webapp/

CMD ["npm", "start"]

