#!/bin/bash
# Installation virtual environment

cd /web-app
python3 -m venv web-1env
source web-1env/bin/activate
pip install wheel
pip install uwsgi flask
deactivate
