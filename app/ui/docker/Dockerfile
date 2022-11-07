FROM python:3.6.0-alpine

RUN apk update
RUN apk add git

RUN git clone https://github.com/daskain/search_engine_ui.git
RUN cd search_engine_ui/

WORKDIR /search_engine_ui

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
ENV MONGO mongodb
ENV MONGO_PORT mongo_port

CMD ["gunicorn","--chdir","ui","ui:app","-b","0.0.0.0"]