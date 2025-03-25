#!/bin/bash

#Colours
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
gray="\e[0;37m\033[1m"
turq="\e[0;36m\033[1m"

trap ctrl_c INT

function ctrl_c(){
  echo -e "\n${red}[!] Proceso detenido..${end}\n"
  exit 1
}

function helpPanel(){
  echo -e "
  ╭╮${yellow}╱╱${end}${blue}╱╱${end}${red}╱${end}╭╮╭━━━╮
  ┃┃${yellow}╱${end}${blue}╱╱${end}${red}╱${end}╭╯╰┫╭━╮┃
  ┃┃${blue}╱╱${end}╭━┻╮╭┻╯╭╯┃
  ┃┃${blue}╱${end}╭┫╭╮┃┃╭╮╰╮┃
  ┃╰━╯┃╭╮┃╰┫╰━╯┃
  ╰━━━┻╯╰┻━┻━━━╯"
  echo -e "\n${blue}[+] Uso:${end} ./lat3.sh \n\n"
  echo -e "${purple}[*] Parametros:${end}\n"
  echo -e "\t ${green}-l${end}  Lenguaje de salida | Ejemplo: -l en"
  echo -e "\t     Lenguajes disponibles trans -R"
  echo -e "\t ${green}-t${end}  Tiempo de escucha (seg) | -t 10"
  echo -e "\t ${green}-f${end}  Traduce un archivo"
  echo -e "\t ${green}-m${end}  Modo de Traducción -> Por entrada de voz (listen)"
  echo -e "\t ${green}-h${end}  Panel de Ayuda"

  echo -e "\n${purple}[*] Ejemplo de ejecución:${end} ${gray}./lat3.sh -m listen -l en -t 10${end}"
}

function listen_mode(){
  if [ ! -d "history" ]; then
    mkdir history
  fi

  echo -e "\n${purple}[*] Escuchando...${end} ${gray}($listen_time segs)${end}"
  arecord -f cd -d $listen_time input.wav > /dev/null 2>&1

  echo -e "\n${turq}[+] Convirtiendo Voz a Texto...${end}"
  ffmpeg -i input.wav -ar 16000 -ac 1 -f wav audio.wav >/dev/null 2>&1

  python3 cribe.py audio.wav > result.txt 2>&1

  tail -n 1 result.txt > output.txt
  echo -e "\n${yellow}[-] Has dicho:${end}"
  cat output.txt

  traduccion=$(trans -b es:$lenguaje -i output.txt)
  echo -e "\n${yellow}[-] Texto Traducido:${end}"
  echo $traduccion

  # Gestion de archivos e historial
  echo $traduccion > ./history/traduccion_$(date | cut -d " " -f5).txt
  mv audio.wav ./history/audio_$(date | cut -d " " -f5).wav
  mv output.txt ./history/output_$(date | cut -d " " -f5).txt
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
    echo "${red}[!] El modo indicado no existe${end}"
    helpPanel
  fi
fi