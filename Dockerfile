FROM python:3.10-slim

USER root

WORKDIR /deployment


RUN mkdir cache && mkdir audios && mkdir inicio_fim_transcricoes && mkdir transcricoes && mkdir audios_sis && touch .cache \
    && chmod 777 /deployment/ && chmod 777 /deployment/audios && chmod 777 /deployment/inicio_fim_transcricoes


VOLUME --name audios /audios

VOLUME --name transcricoes /transcricoes

VOLUME --name inicio_fim_transcricoes /inicio_fim_transcricoes

ENV NUMBA_CACHE_DIR=/tmp/

#RUN touch .cache
#RUN chmod 755 .cache


#RUN chmod 755 /deployment/.cache



#RUN chmod 777 /deployment/
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