############################################################
# Dockerfile to build container for running sequenceserver
# Based on Ubuntu 14.04
############################################################

# Set the base image to Ubuntu
FROM phusion/passenger-ruby21:0.9.15


# File Author / Maintainer
MAINTAINER Patrick Moss <moss@alderbio.com>


ENV blast_version '2.2.30'


################## BEGIN INSTALLATION ######################
RUN apt-get update && apt-get install -y build-essential wget

#Install blastall

RUN mkdir -p /home/software
WORKDIR /home/software

RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${blast_version}/ncbi-blast-${blast_version}+-x64-linux.tar.gz 
RUN tar -xvzf ncbi-blast-${blast_version}+-x64-linux.tar.gz && \
ln -s /home/software/ncbi-blast-2.2.30+/bin/* /usr/local/bin/.

# Set correct environment variables.
ENV HOME /root


#Copy in the gemfile so this can be cached
COPY ./Gemfile /home/software/Gemfile
COPY ./Gemfile.lock /home/software/Gemfile.lock

RUN bundle install
RUN chown -R app:app /home/software



WORKDIR /home/app/webapp
#Setup our server with runit
RUN mkdir /etc/service/thin
ADD config/thin/thin.sh /etc/service/thin/run

#Copy in all files
ADD . /home/app/webapp/
RUN mkdir -p /home/app/webapp/public/blast_data;

#Site Specific Blast database.  Copy fasta files into blast_dir and sequenceserver will make the blastdb
COPY ./docker_blast_sequences/Rabbit_VH_AA.fasta /home/app/webapp/public/blast_data/Rabbit_VH_AA.fasta

#Run a script to make a json config file using ENV VAR ALDER_SEQ_HOST to set the servername where sequences should be pulled from
ADD config/make_config_file.sh /etc/my_init.d/make_config_file.sh

RUN chown -R app:app /home/app/webapp

EXPOSE :4567

# Use baseimage-docker's runt process.
CMD ["/sbin/my_init"]


#docker build -t aldermossy/sequenceserver .

## Manual run sequenceserver within container
#docker run -it  -p 4567:4567 -e ALDER_SEQ_HOST=research-staging.alderbio.lan --name sequenceserver aldermossy/sequenceserver /bin/bash

#docker run -d  -p 4567:4567 -e ALDER_SEQ_HOST=research-staging.alderbio.lan --name sequenceserver aldermossy/sequenceserver

#docker push aldermossy/sequenceserver 


