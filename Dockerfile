# Start from the base image
FROM timbru31/ruby-node:3.3-slim-hydrogen

# Install Python 3
RUN apt-get update && \
    apt-get install -y python3

# Check if '/usr/bin/python' exists before removing it
RUN if [ -f /usr/bin/python ]; then rm /usr/bin/python; fi

# Create a symbolic link to python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Continue with your existing setup
WORKDIR /app/webapp/

# Update Bundler to the version specified in your lockfile
RUN gem install bundler -v 1.17.3

COPY Gemfile Gemfile.lock /app/webapp/
RUN bundle _1.17.3_ install

COPY package.json package-lock.json /app/webapp/
RUN npm install

COPY . /app/webapp/

CMD ["npm", "start"]
