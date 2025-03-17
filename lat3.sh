#!/bin/bash

trap ctrl_c INT

function ctrl_c(){
  echo "\n[!] Proceso detenido..\n"
  exit 1
}

function helpPanel(){
  echo -e "[+] Uso: ./lat3.sh \n\n"
  echo -e "[*] Parametros:\n"
  echo -e "\t -l  Lenguaje de salida | Ejemplo: -l en -> Lenguajes disponibles trans -R" 
  echo -e "\t -t  Establece el tiempo de escucha en segundos -> -t 10"
  echo -e "\t -f  Traduce un archivo"
  echo -e "\t -m  Modo de Traducción -> Por entrada de voz (listen)"
  echo -e "\t -h  Panel de Ayuda"

  echo -e "\n[*] Ejemplo de ejecución: ./lat3.sh -m listen -l en -t 10"
}

function listen_mode(){
  echo -e "\n[*] Escuchando... ($listen_time segs)"
  arecord -f cd -d $listen_time input.wav > /dev/null 2>&1
  sleep 1

  echo -e "\n[+] Convirtiendo Voz a Texto..."
  ffmpeg -i input.wav -ar 16000 -ac 1 -f wav audio.wav >/dev/null 2>&1

  python3 cribe.py audio.wav > result.txt 2>&1

  tail -n 1 result.txt > output.txt
  echo -e "\nHas dicho:"
  cat output.txt

  traduccion=$(trans -b es:$lenguaje -i output.txt -o ./history/traduccion_$(date | cut -d " " -f5).txt)
  echo -e "\nTexto Traducido:"
  echo $traduccion

  mv audio.wav ./history/audio_$(date | cut -d " " -f5).wav
  mv output.txt ./history/output$(date | cut -d " " -f5).txt
  rm input.wav result.txt > /dev/null 2>&1
}

declare -i parameter_count=0

while getopts ":l:t:f:m:h:" arg; do
  case $arg in
    l) lenguaje=$OPTARG; let parameter_count+=1 ;;
    t) listen_time=$OPTARG; let parameter_count+=1 ;;
    f) file_name=$OPTARG; let parameter_count+=1 ;;
    m) mode=$OPTARG; let parameter_count+=1 ;;
    h) helpPanel ;;
  esac
done

if [ $parameter_count -eq 0 ]; then
  helpPanel
else
  if [ $mode = "listen" ]; then
    listen_mode
  else
    echo "[!] El modo indicado no existe"
    helpPanel
  fi
fi
