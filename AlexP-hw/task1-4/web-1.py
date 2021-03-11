from flask import Flask, request
web_main = Flask(__name__)


@web_main.route('/hello')
def site():
    return "<h1>Helloo from FLASK</h1>"

#   curl -XPOST -d'{"word":"evilmartian", "count": 3}' http://myvm.localhost/

@web_main.route('/', methods=['POST','GET'])
def json():
    request_data = request.get_json(force=True)
    word1 = request_data['word']
    count1 = request_data['count']
    emo="\U0001F923"
    str=emo
    for i in range(count1):
        str=str + word1 + emo

    return '''
         {}
         '''.format(str)


@web_main.route('/str')
def str():
    q_str = request.args.get('str')
    return q_str




if __name__  == "__main__":
    web_main.run(debug=True)
    print("\U0001F923")
#print(__name__)
#print("aa")
