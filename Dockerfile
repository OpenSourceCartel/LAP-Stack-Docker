FROM jkirkby91/ubuntusrvbase
MAINTAINER James Kirkby <jkirkby91@gmail.com>

# enable the multiverse (at least in the multiverse you're more likely not to be sat here doing this ;-)
RUN sudo apt-add-repository multiverse

RUN curl -sL https://deb.nodesource.com/setup | sudo bash -

# Install some packages
RUN apt-get update && \
apt-get upgrade -y && \
apt-get install -y wget sqlite3 libsqlite3-dev supervisor apache2 apache2-mpm-event libapache2-mod-fastcgi php5-fpm php5-cli php5-mysql php5-curl php5-gd php5-intl php5-mcrypt php5-tidy php5-xmlrpc php5-xsl php5-xdebug php-pear nodejs npm --fix-missing && \
apt-get remove --purge -y software-properties-common && \
apt-get autoremove -y && \
apt-get clean && \
apt-get autoclean && \
echo -n > /var/lib/apt/extended_states && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /usr/share/man/?? && \
rm -rf /usr/share/man/??_*

# Compile node from source
# RUN \
#  cd /tmp && \
#  wget http://nodejs.org/dist/node-latest.tar.gz && \
#  tar xvzf node-latest.tar.gz && \
#  rm -f node-latest.tar.gz && \
#  cd node-v* && \
#  ./configure && \
#  CXX="g++ -Wno-unused-local-typedefs" make && \
#  CXX="g++ -Wno-unused-local-typedefs" make install && \
#  cd /tmp && \
#  rm -rf /tmp/node-v* && \
#  npm install -g npm && \
#  printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

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

# set php-fpm configs so it actually works
RUN sed -i -e "s/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php5/fpm/pool.d/www.conf && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php5/fpm/pool.d/www.conf && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php5/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php5/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php5/fpm/pool.d/www.conf && \
echo "security.limit_extensions = .php .html" >> /etc/php5/fpm/pool.d/www.conf

# Define entry point
CMD ["/bin/bash"]
