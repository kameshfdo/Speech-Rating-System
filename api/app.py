from flask import Flask, request, jsonify
from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor
import torch
import soundfile as sf
import io
import resampy
import utill


app = Flask(__name__)

# Load pre-trained model and processor
model_name = "facebook/wav2vec2-large-960h"
processor = Wav2Vec2Processor.from_pretrained(model_name)
model = Wav2Vec2ForCTC.from_pretrained(model_name)

# Load Decision Tree model
utill.load_saved_artifacts()


@app.route('/transcribe', methods=['POST'])
def transcribe():
    # Get the file from the request
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Read audio file
        audio_input, sample_rate = sf.read(io.BytesIO(file.read()))

        # Resample audio if necessary
        if sample_rate != 16000:
            audio_input = resampy.resample(audio_input, sample_rate, 16000)
            sample_rate = 16000

        # Preprocess audio
        inputs = processor(audio_input, sampling_rate=sample_rate, return_tensors="pt", padding=True)

        # Perform inference
        with torch.no_grad():
            logits = model(inputs.input_values).logits

        # Decode the predicted tokens to text
        predicted_ids = torch.argmax(logits, dim=-1)
        transcription = processor.batch_decode(predicted_ids)[0]

        print(type(transcription),transcription)

        # Calculate Character Error Rate (CER)
        target = request.form.get('target')  # Get target from request
        print(target)


        # Get estimated rate using transcription and target value
        rate_speech = utill.get_estimated_rate(transcription,target)
        return jsonify({"transcription": transcription, "rate_speech": rate_speech})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)