FROM debian:wheezy

MAINTAINER Donatas Aleksandravicius <donis@gildija.lt>

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 89DF5277

RUN echo "deb http://nginx.org/packages/debian/ wheezy nginx" >> /etc/apt/sources.list
RUN echo "deb http://packages.dotdeb.org wheezy all" > /etc/apt/sources.list.d/dotdeb.all.list
RUN echo "deb http://packages.dotdeb.org/ wheezy-php55 all" > /etc/apt/sources.list.d/php.list

ENV NGINX_VERSION 1.6.2-1~wheezy

RUN apt-get update && apt-get install -y nginx=${NGINX_VERSION}

RUN apt-get install -y php5-cli php5-curl php5-fpm php5-gd php5-mcrypt php5-imagick php5-intl php5-ldap php5-memcache php5-memcached php5-mysqlnd php5-readline php5-xcache php5-xdebug

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN ln -sf /dev/stderr /var/log/php5-fpm.log

RUN rm -rf /etc/nginx/addon.d /etc/php5/fpm/pool.d
RUN mkdir -p /etc/nginx/addon.d /etc/php5/fpm/pool.d
ADD etc /etc

# allow cache writes & stuff
RUN usermod -u 1000 www-data

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD service php5-fpm start && nginx -g "daemon off;"
