# Transcribe and Diarize Audio Files


## Overview

This project provides a script that performs transcription and diarization on audio files. It utilizes various libraries and models to transcribe speech and identify speakers in the audio.

## Installation

To run this project, you need to create a Conda environment using the provided `stt_environment.yaml` file. This environment contains all the necessary dependencies for the script to function properly.
```
conda env create -f stt_environment.yaml
conda activate stt_environment
```

## Usage
To use the script, run the following command:

```
python script.py <audio_file>
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
python script.py path/to/audio_file.wav
```

## License
This project is licensed under the MIT License.
