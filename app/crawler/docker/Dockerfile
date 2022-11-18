FROM python:3.6.0-alpine

RUN apk update
RUN apk add git

RUN git clone https://github.com/daskain/search_engine_crawler.git
RUN cd search_engine_crawler/

WORKDIR /search_engine_crawler

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
ENV MONGO mongodb
ENV MONGO_PORT mongo_port
ENV RMQ_HOST rabbitmq
ENV RMQ_QUEUE rabbitmq_queue
ENV RMQ_USERNAME rabbitmq_user
ENV RMQ_PASSWORD rabbitmq_pass
ENV CHECK_INTERVAL chk_interval
ENV EXCLUDE_URLS exclude_urls
ENV URL url

CMD ["sh", "-c", "python -u crawler/crawler.py ${URL}"]