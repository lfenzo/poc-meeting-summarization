#!/usr/bin/bash

conda create --name whisperx python=3.10 -y
conda activate whisperx

conda install -y pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 -c pytorch -c nvidia

conda install -y cuda==11.8

pip install git+https://github.com/m-bain/whisperx.git
pip install -r additional-requirements.txt
