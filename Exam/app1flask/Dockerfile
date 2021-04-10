FROM python:3.6-alpine

#RUN adduser -D app1user
COPY . /app
WORKDIR /app
#/home/app1user

#COPY requirements.txt requirements.txt
#RUN python -m venv venv
RUN pip install -r /app/requirements.txt




#RUN chmod +x application

#ENV FLASK_APP application.py

#RUN chown -R microblog:microblog ./
#USER microblog

EXPOSE 5000
CMD [ "python", "application.py" ]