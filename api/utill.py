import pickle
import json
import numpy as np
import sklearn
from torchmetrics.text import CharErrorRate
import re

__model = None
__data_columns = None

def load_saved_artifacts():
    print("loading saved artifacts...start")
    global __data_columns
    global __model

    # Load columns.json
    with open("./artifacts/columns.json", "r") as f:
        __data_columns = json.load(f)['data_columns']

    # Load the model
    if __model is None:
        with open('./artifacts/rate_model.pickle', 'rb') as f:
            __model = pickle.load(f)  # Load model
    print("loading saved artifacts...done")

def get_estimated_rate(transcription,target):
    if __model is None:
        print("Model is not loaded, call load_saved_artifacts first")
        return

    x = np.zeros(len(__data_columns))
    x[0] = get_cer_value(transcription,target)
    predicted_rate_code = __model.predict([x])
    categories = ['GOOD', 'MODERATE', 'WEAK']
    predicted_rate = categories[predicted_rate_code[0]]
    return predicted_rate

def get_cer_value(transcription,target):
    cer = CharErrorRate()
    result = cer(transcription.lower(), target.lower())
    str_result = str(result)

    # Regular expression pattern to match anything inside round brackets
    pattern = r"\((.*?)\)"

    # Using re.search to find the pattern in the string
    match = re.search(pattern, str_result)

    # Extracting the value inside the round brackets
    if match:
        x = match.group(1)
        value_inside_brackets = float(x)
    else:
        value_inside_brackets = 0

    return value_inside_brackets



if __name__ == '__main__':

    load_saved_artifacts()
    example_value = get_cer_value("apple","asale")
    predicted_rate = get_estimated_rate("apple","asale")
    print(type(predicted_rate))
    print(f"Predicted rate for cer_value {example_value}: {predicted_rate}")
