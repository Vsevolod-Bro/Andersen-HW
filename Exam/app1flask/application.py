from flask import Flask

application = Flask(__name__)


@application.route("/")
def index():
    return "<h1>Helloo from FLASK</h1>"

if __name__  == "__main__":
    application.run()

