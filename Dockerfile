# Use a imagem oficial do Red Hat como base
FROM registry.access.redhat.com/ubi8/ubi

# Copie o arquivo environment.yaml para o diretório atual
COPY stt_environment.yaml .

# Instale o ambiente Conda a partir do arquivo YAML
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
    && sh miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh \
    && /opt/conda/bin/conda env create -f stt_environment.yaml \
    && /opt/conda/bin/conda clean -afy \
    && dnf install -y libsndfile

# Configure o ambiente Conda como padrão
ENV PATH /opt/conda/envs/stt/bin:$PATH


# Instala as dependências necessárias
RUN dnf install -y libaio && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Baixa o pacote RPM do Oracle Instant Client e instala-o
ADD https://download.oracle.com/otn_software/linux/instantclient/211000/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm /tmp/
ADD https://download.oracle.com/otn_software/linux/instantclient/211000/oracle-instantclient-devel-21.1.0.0.0-1.x86_64.rpm /tmp/
RUN dnf install -y /tmp/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm /tmp/oracle-instantclient-devel-21.1.0.0.0-1.x86_64.rpm && \
    rm -f /tmp/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm /tmp/oracle-instantclient-devel-21.1.0.0.0-1.x86_64.rpm && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Define a variável de ambiente LD_LIBRARY_PATH para incluir o caminho do Instant Client
ENV LD_LIBRARY_PATH="/usr/lib/oracle/21/client64/lib"


ENV NUMBA_CACHE_DIR=/tmp/

# Crie um diretório de trabalho
#WORKDIR /app

RUN mkdir /app && mkdir -p /app/gravacoes

RUN mkdir -p /.cache && chmod -R 777 /.cache
RUN mkdir -p /.config/ && chmod -R 777 /.config
RUN mkdir -p /speaker-diarization && chmod -R 777 /speaker-diarization
RUN mkdir -p /pyannote-audio && chmod -R 777 /pyannote-audio
#RUN  mkdir -p /.cache/torch/pyannote/models--pyannote--speaker-diarization/refs/main && chmod -R 777 /.cache/torch/pyannote/models--pyannote--speaker-diarization/refs/main

RUN chmod -R 777 /app/
RUN chmod -R 777 /app/gravacoes
#RUN pip install -qq https://github.com/pyannote/pyannote-audio/archive/develop.zip
#RUN pip install Lightning
# Copie a aplicação sis_stt.py para o diretório /app
COPY medium.pt /app
COPY sis_stt.py /app
COPY pyannote_whisper/ /app/pyannote_whisper
COPY speaker-diarization/ /speaker-diarization
COPY pyannote-audio/ /pyannote-audio

RUN pip install pyannote-audio --quiet
# Execute a aplicação quando o container for iniciado
CMD ["python", "/app/sis_stt.py"]
