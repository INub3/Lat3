import vosk
import sys
import wave
import json


def es_pregunta(texto):
    palabras_interrogativas = {"qué", "cómo", "cuándo", "dónde", "por qué", "quién", "cuál"}
    palabras = texto.lower().split()
    for i, palabra in enumerate(palabras):
        if palabra in palabras_interrogativas:
            palabras[i] = "¿" + palabras[i]
            return " ".join(palabras) + "?"
    return texto

model = vosk.Model("./vosk-es")  # Ruta al modelo de idioma

wf = wave.open("audio.wav", "rb")
if wf.getsampwidth() != 2:
    sys.exit(1)

rec = vosk.KaldiRecognizer(model, wf.getframerate())

# Procesar audio
while True:
    data = wf.readframes(4000)
    if len(data) == 0:
        break
    if rec.AcceptWaveform(data):
        pass

# Procesar resultado final
resultado_final_json = json.loads(rec.FinalResult())
texto_final = resultado_final_json.get("text", "")

# Solo imprimir el resultado final y verificar si es una pregunta
texto_final = es_pregunta(texto_final)
print(texto_final)

