FROM ruby:latest

RUN apt-get update && \
    apt-get install awscli python3-pip jq -y
RUN pip3 install awscli --upgrade

RUN mkdir -p /opt/edos/shatterdome/ui

COPY Gemfile /opt/edos/shatterdome/ui/
WORKDIR /opt/edos/shatterdome/ui/
RUN gem install bundler && bundle update

COPY ./ /opt/edos/shatterdome/ui/

WORKDIR /opt/edos/shatterdome/ui/

CMD ["./bin/entry_point.sh"]