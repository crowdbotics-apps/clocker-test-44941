# Use Heroku-22 stack with buildpacks for Ruby and Node.js
FROM heroku/heroku:22
# Install Python 2 (python2 package)
RUN apt-get update && apt-get install -y python2

# Set Python 2 as the default Python version if necessary
RUN ln -s /usr/bin/python2 /usr/bin/python

# Set working directory
WORKDIR /app/clockapp/

# Install necessary dependencies for Ruby and Node.js
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y build-essential && \
    apt-get install -y ruby-full

# Copy package files and install dependencies
COPY package.json package-lock.json /app/clockapp/
RUN npm install

# Copy Gemfile and Gemfile.lock and install Ruby dependencies
COPY Gemfile Gemfile.lock /app/clockapp/
RUN gem update --system && \
    gem install bundler && \
    bundle install

# Copy the rest of the application files
COPY . /app/clockapp/

# Specify the command to start the clock app
CMD ["npm", "start"]
