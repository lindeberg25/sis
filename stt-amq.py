import os
import time
import json
import pika
import whisper
import torch
import logging
import librosa

def main():
    
    logging.basicConfig(filename='stt_amp.log', level=logging.INFO)

    
    # Definindo as credenciais de conexão com o RabbitMQ
    credentials = pika.PlainCredentials('guest', 'guest')
    parameters = pika.ConnectionParameters('localhost', 5672, '/', credentials)

    # Criando a conexão com o RabbitMQ
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    # Declare an existing queue
    queue_name = 'sis_eventos'

    # pasta onde se encontra os áudios do SIS
    pasta_audios = "audios"
    
    # pasta onde as transcrições são salvas
    pasta_transcricoes = "transcricoes"

    # pasta onde as transcrições são salvas
    pasta_inicio_fim_transcricoes = "inicio_fim_transcricoes"

    # Definindo a função que será executada ao receber uma mensagem
    def callback(ch, method, properties, body):
        mensagem = json.loads(body)


        # Check if NVIDIA GPU is available
        torch.cuda.is_available()
        DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
        model = whisper.load_model("medium.pt", device=DEVICE)
        
        duration = librosa.get_duration(path=os.path.join(os.getcwd(), pasta_audios,  mensagem['conteudo']))
        
        if not os.path.exists(os.path.join(os.getcwd(), pasta_audios, mensagem['conteudo'])):
            logging.warning("Arquivo de áudio não encontrado: {}".format(os.path.join(os.getcwd(), pasta_audios, mensagem['conteudo'])))
        
        
        elif not os.path.exists(os.path.join(os.getcwd(), pasta_transcricoes, mensagem['conteudo'] + ".txt")) and not os.path.exists(os.path.join(os.getcwd(), pasta_inicio_fim_transcricoes, "inicio_" + mensagem['conteudo'])):
            
            #logging.info("Inicia transcrição")
            
            # Save the text para inicio da trascricao
            filename_inicio_transcricoes = "./{}/inicio_{}".format(pasta_inicio_fim_transcricoes, mensagem['conteudo'])
            with open(filename_inicio_transcricoes, "w") :
                logging.info("Inicio Transcrição {}".format(mensagem['conteudo']))


            start = time.time()
            result = model.transcribe(os.path.join(os.getcwd(), pasta_audios, mensagem['conteudo']), language="pt")
            
            logging.info( result['text'])
            
            filename_fim_transcricoes = "./{}/fim_{}".format(pasta_inicio_fim_transcricoes, mensagem['conteudo'])
            with open(filename_fim_transcricoes, "w") :
                #f.write(result['text'])
                logging.info("Fim de Transcrição {}".format(mensagem['conteudo']))
            
            
            
      
            logging.info("Duração do áudio %s seconds " % duration)
            logging.info("Tempo de transcrição %s seconds " % (time.time() - start))

            # Save the text to a file
            filename = "./{}/{}.txt".format(pasta_transcricoes, mensagem['conteudo'])

            with open(filename, "w") as f:
                f.write(result['text'])
                logging.info("Texto salvo em {}".format(filename))


    # Iniciando o consumo das mensagens
    channel.basic_consume(queue=queue_name, on_message_callback=callback)

    # Iniciando o loop de consumo de mensagens
    print('Aguardando mensagens...')
    channel.start_consuming()


def chech_audios_not_processed(pasta_inicio_fim_transcricoes):

    dir_path = pasta_inicio_fim_transcricoes # replace with the path to your directory
    prefixo_inicio = 'inicio_'
    prefixo_fim = 'fim_'

    for file in os.listdir(dir_path):
        if file.startswith(prefixo_inicio) and not os.path.exists(os.path.join(dir_path, prefixo_fim + file[len(prefixo_inicio):-4] + '.WAV')):
            inicio_file_path = os.path.join(dir_path, file)
            if (time.time() - os.path.getctime(inicio_file_path)) // (24 * 3600) > 0:
                os.remove(inicio_file_path)
        elif file.startswith(prefixo_inicio) and os.path.exists(os.path.join(dir_path, prefixo_fim + file[len(prefixo_inicio):-4] + '.WAV')):
            inicio_file_path = os.path.join(dir_path, file)
            fim_file_path = os.path.join(dir_path, prefixo_fim + file[len(prefixo_inicio):-4] + '.WAV')
            
            os.remove(inicio_file_path)
            os.remove(fim_file_path)


if __name__ == '__main__':
    
    main()
