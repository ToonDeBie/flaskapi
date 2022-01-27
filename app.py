from fastai.vision.all import *
import os
import flask
from flask import request, jsonify, Flask
app = flask.Flask(__name__)
import pathlib
plt = platform.system()
if plt == 'Linux': pathlib.WindowsPath = pathlib.PosixPath
our_out_of_the_box_model_inference = load_learner('export.pkl')
# let's test our model on an image
#our_out_of_the_box_model_inference = load_learner('models\first_model.pth')

#app.config["DEBUG"] = True

@app.route('/', methods=['GET'])
def home():
    if request.method == 'GET':
        link = request.args.get('link')
        response = requests.get(link)
        result = our_out_of_the_box_model_inference.predict(response.content)[0].split("-")
        stringwaardepred = str(max(our_out_of_the_box_model_inference.predict(response.content)[2]))
# Create some test data for our catalog in the form of a list of dictionaries.
        Output = {
            'output': int(result[1][4:]),
            'accuracy': float(stringwaardepred[11:-1])*100,
            'species': result[0],
            'kind' : result[1][:4]
        }
        #'output': int(result[1][4:]),
        #'accuracy': float(stringwaardepred[11:-1])*100,
        #'species' : result[0],
        #'kind' : result[1][:4]
    return jsonify(Output)
if __name__ == '__main__':
    app.run() 
