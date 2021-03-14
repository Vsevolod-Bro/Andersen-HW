from flask import Flask, request
import unicodedata

web_main = Flask(__name__)


@web_main.route("/hello")
def site():
    return "<h1>Helloo from FLASK</h1>"


@web_main.route("/", methods=['POST','GET'])
def json():
    if request.method == 'POST':
       request_data = request.get_json(force=True)
       word1 = request_data['word']
       count1 = request_data['count']
       emo=unicodedata.lookup(word1)
       str1 = emo
       for i in range(count1):
           str1=str1 + word1 + emo

       return '''
            {}
            '''.format(str1)
    return 'JSON page. Send json POST \n'


@web_main.route("/str")
def strok():
    q_str = request.args.get('str1')
    return q_str

if __name__  == "__main__":
    web_main.run(host='0.0.0.0')
else:
    application = web_main
