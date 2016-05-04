FROM jkirkby91/ubuntusrvbase
MAINTAINER James Kirkby <jkirkby91@gmail.com>

# Compile node from source
# Put this at the top so we can modify subsequent layers without having to compile node again as its long
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Install some packages
RUN apt-get update && \
apt-get upgrade -y && \
apt-get install -y sqlite3 libsqlite3-dev supervisor apache2 libapache2-mod-php5 php5-fpm php5-mysql php5-curl php5-gd php5-intl php5-mcrypt php5-tidy php5-xmlrpc php5-xsl php5-xdebug php-pear && \
apt-get remove --purge -y software-properties-common && \
apt-get autoremove -y && \
apt-get clean && \
apt-get autoclean && \
echo -n > /var/lib/apt/extended_states && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /usr/share/man/?? && \
rm -rf /usr/share/man/??_*

# Link nodejs env
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Install bower
RUN npm install -g bower

# Install gulp
RUN npm install -g gulp

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configure Xdebug
RUN echo "zend_extension=/usr/lib/php5/20121212/xdebug.so" >> /etc/php5/fpm/php.ini
RUN echo "xdebug.remote_enable = 1" >> /etc/php5/fpm/php.ini
RUN echo "xdebug.idekey = 'ideStorm'" >> /etc/php5/fpm/php.ini
RUN echo "xdebug.remote_autostart = 1" >> /etc/php5/fpm/php.ini
RUN echo "xdebug.remote_connect_back = 1" >> /etc/php5/fpm/php.ini
RUN echo "xdebug.remote_port = 9000" >> /etc/php5/fpm/php.ini
RUN echo "xdebug.remote_handler=dbgp" >> /etc/php5/fpm/php.ini
RUN echo "xdebug.remote_mode=req" >> /etc/php5/fpm/php.ini

# Define entry point
CMD ["/bin/bash"]
