FROM python:3.10-slim

USER root

WORKDIR /deployment


RUN mkdir cache && touch .cache \
    && chmod -R 777 /deployment/


ENV NUMBA_CACHE_DIR=/tmp/

#RUN touch .cache
#RUN chmod 755 .cache


#RUN chmod 755 /deployment/.cache



#RUN chmod 755 /deployment/
#RUN chmod 755 /deployment/cache/
#RUN chmod 755 /deployment/audio/



RUN apt-get -qq update \
    && apt-get -qq install --no-install-recommends ffmpeg

COPY requirements.txt requirements.txt
RUN  apt-get -y install git

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install "git+https://github.com/openai/whisper.git" 
ADD https://openaipublic.azureedge.net/main/whisper/models/345ae4da62f9b3d59415adc60127b97c714f32e89e936602e85993674d08dcb1/medium.pt /deployment

RUN chmod 777 /deployment/medium.pt

COPY . .


USER 1001

CMD ["python","stt-amq.py"]