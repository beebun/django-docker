FROM ubuntu:14.04

# Enable production settings by default; for development, this can be set to 
# `false` in `docker run --env`
ENV DJANGO_PRODUCTION=true

# Set terminal to be noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get update && apt-get install -y \
    git \
    nginx \
    python-dev \
    python-setuptools \
    python-urllib3 \
    supervisor \
    vim
RUN easy_install pip

# Handle urllib3 InsecurePlatformWarning
RUN apt-get install -y libffi-dev libssl-dev libpython2.7-dev
RUN pip install requests[security] ndg-httpsclient pyasn1

# Configure Django project
ADD . /code
RUN mkdir /djangomedia
RUN mkdir /static
RUN mkdir /logs
RUN mkdir /logs/nginx
RUN mkdir /logs/gunicorn
WORKDIR /code
RUN pip install -r requirements.txt
RUN chmod ug+x /code/initialize.sh

# Expose ports
# 80 = Nginx
# 8000 = Gunicorn
EXPOSE 80 8000

# Configure Nginx
RUN ln -s /code/nginx.conf /etc/nginx/sites-enabled/django_docker.conf
RUN rm /etc/nginx/sites-enabled/default

# Run Supervisor (i.e., start, Nginx, and Gunicorn)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
