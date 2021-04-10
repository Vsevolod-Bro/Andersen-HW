from flask import Flask, render_template

application = Flask(__name__)


@application.route("/")
def index():
    return "<h1>Hello World 1 (FLASK)</h1>"

@application.route("/an")
def an():
    return render_template("anders.html")

@application.route("/user/<string:name>")
def user(name):
    return "<h1>User page for User: " + name + "</h1>"

if __name__  == "__main__":
    #application.debug = True
    application.run(host="0.0.0.0")

