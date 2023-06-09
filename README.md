# Transcribe and Diarize Audio Files


## Overview

This project provides a script designed for law enforcement agencies to perform transcription and diarization on audio files. The script utilizes the whiper models to transcribe speech and pyannote-audio lib to identify speakers within the audio recordings.

## Installation

To run this project, you need to create a Conda environment using the provided `stt_environment.yaml` file. This environment contains all the necessary dependencies for the script to function properly.
```
git clone https://github.com/lindeberg25/sis.git
cd sis/
conda env create -f stt_environment.yaml
conda activate stt
(stt) pip install pyannote-audio/  (use this local repository to run offline)
```

## Usage
To use the script, run the following command:

```
(stt) python sis_stt.py <audio_file>
```
Replace <audio_file> with the path to the audio file you want to process.

## Configuration
The script uses environment variables for configuration. Create a .env file and set the following variables:

- `batch_audios_for_processing`: Number of recordings the script processes at once.
- `diarization_model`: Path to the diarization model.
- `transcription_model`: Path to the transcription model.
- `log_file`: Path to the log file.
- `language` (optional): Language for the transcription model.

## Script Details
The script performs the following steps:

- Loads the environment variables and sets up logging.
- Loads the diarization and transcription models.
- Defines the `transcribe_diarization` function to transcribe and diarize an audio file.
- Parses command-line arguments and calls the `transcribe_diarization` function with the specified audio file.


## Examples
Transcribe and diarize an audio file:
```
(stt) python sis_stt.py path/to/audio_file.wav
```
##### Expected output example
```
(0.0s - 1.0s)   HNI_1:  Oi, pai.
(1.0s - 7.0s)   HNI_2:  Oi, tô chegando.
(7.0s - 12.0s)  HNI_1:  Já estou aqui esperando.
(12.0s - 15.0s) HNI_2:  Tá bom.
(16.0s - 19.0s) HNI_1:  Quando chegar, avisa.
(29.0s - 30.0s) HNI_2:  Tá bom.
```
HNI = Human not identified 
## License
This project is licensed under the MIT License.
