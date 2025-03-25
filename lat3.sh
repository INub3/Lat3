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

function requirements(){
  echo -e "\n${yellow}[*]${end}${purple} Instalando aplicaciones necesarias...${end}\n"
  sleep 1

  test -f /usr/bin/arecord
  if [ "$(echo $?)" == "0" ]; then
    echo -e "\tarecord ${green}(V)${end}"
  else
    echo -e "\tarecord ${red}(X)${end}"
    echo -e "\t${yellow}[*] Instalando ${end}${blue}Arecrod...${end}\n"
    apt-get install alsa-utils -y > /dev/null 2>&1
  fi;
  sleep 1
  test -f /usr/bin/ffmpeg
  if [ "$(echo $?)" == "0" ]; then
    echo -e "\tffmpeg ${green}(V)${end}"
  else
    echo -e "\tffmpeg ${red}(X)${end}"
    echo -e "\t${yellow}[*] Instalando ${end}${blue}ffmepg...${end}"
    apt-get install ffmepg -y > /dev/null 2>&1
  fi;
  sleep 1
  test -f /usr/bin/trans
  if [ "$(echo $?)" == "0" ]; then
    echo -e "\ttrans ${green}(V)${end}"
  else
    echo -e "\ttrans ${red}(X)${end}"
    echo -e "\t${yellow}[*] Instalando ${end}${blue}translate-shell...${end}"
    apt-get install translate-shell -y > /dev/null 2>&1
  fi;
  sleep 1
  echo -e "\n${yellow}[+]${end} ${purple}Instalando dependecia de Python${end} (vosk)"
  pip install vosk > /dev/null 2>&1

  exit 0
}

# MAIN
declare -i parameter_count=0

while getopts ":l:t:f:m:rh" arg; do
  case $arg in
    l) lenguaje=$OPTARG; let parameter_count+=1 ;;
    t) listen_time=$OPTARG; let parameter_count+=1 ;;
    f) file_name=$OPTARG; let parameter_count+=1 ;;
    m) mode=$OPTARG; let parameter_count+=1 ;;
    r) requirements; let parameter_count+=1 ;;
    h) helpPanel ;;
  esac
done

if [ $parameter_count -eq 0 ]; then
  echo -e "\n${red}[!] Sin parametros introduciodos${end}"
  echo -e "\n${turq}[+] Panel de ayuda:${end} ./lat3.sh -h"
  exit 1
else
  if [ $mode = "listen" ]; then
    listen_mode
  else
    echo -e "${red}[!] El modo indicado no existe${end}"
    helpPanel
    exit 1
  fi
fi