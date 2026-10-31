#!/usr/bin/env bash
set +e
shopt -s extglob nocaseglob nullglob

WORK_DIR=".tmp_dvd_listos_$$"
FINAL_DIR=".tmp_dvd_final_$$"
LOG_FILE=".dvd_error.log"

# =======================================================
# MANEJO DE CANCELACIÓN INSTANTÁNEA (Ctrl + C) Y LIMPIEZA
# =======================================================
cleanup() {
    local term_rows=$(tput lines 2>/dev/null || echo 24)
    printf "\033[1;%dr" "$term_rows" 2>/dev/null
    tput cnorm 2>/dev/null
    tput cup $((term_rows - 1)) 0 2>/dev/null
    tput el 2>/dev/null
    
    echo -e "\n\n⚠️  Proceso cancelado inmediatamente por el usuario."
    echo "🧹 Limpiando archivos temporales..."
    pkill -P $$ 2>/dev/null
    rm -rf "$WORK_DIR" "$FINAL_DIR" dvdauthor.xml .cover_optimized.jpg "$LOG_FILE" 2>/dev/null
    echo "✅ Carpeta limpia. Consola lista."
    exit 130
}
trap cleanup SIGINT SIGTERM

FULL_LANG="${LANG:-en}"
LANG_CODE="${FULL_LANG%%_*}"
LANG_CODE="${LANG_CODE,,}"

case "$LANG_CODE" in
    pt)
        MSG_HEADER="HiFi DVD Pro - AUTORIA PROFISSIONAL DE DVD DE ÁUDIO"
        MSG_CALC="🔄 A analisar áudio e calcular tamanho..."
        MSG_MISSING_DEPS="Faltam as seguintes ferramentas no seu sistema:"
        MSG_ASK_INSTALL="Deseja instalá-las agora automaticamente? (Requer palavra-passe)\n👉 [s] SIM (Predefinição) / [n] NÃO: "
        MSG_INSTALLING="🔄 A instalar pacotes..."
        MSG_INSTALL_FAIL="❌ ERRO: A instalação falhou ou foi cancelada."
        MSG_ERR_COVER="❌ ERRO: O ficheiro 'cover.jpg' (ou .png) não foi encontrado na pasta atual."
        MSG_ERR_AUDIO="❌ ERRO: Não existem ficheiros de áudio compatíveis na pasta."
        MSG_EST_DURATION="⏱️ Duração e Tamanho Real (ISO)"
        MSG_EST_CRITICAL="🚨 CRÍTICO: Excede o limite de Dupla Camada (8.5 GB)."
        MSG_EST_NOTICE="⚠️ AVISO: Requer um **DVD DE CAMADA DUPLA (DVD-9 / 8.5 GB)**."
        MSG_EST_OK="✅ Cabe num DVD standard de camada simples (4.7 GB)."
        MSG_ASK_FMT="\n📺 FORMATO DE VÍDEO\n1) PAL (Europa/Ásia - 720x576, 25fps)  <-- [PREDEFINIÇÃO]\n2) NTSC (América/Japão - 720x480, 29.97fps)\nℹ️  (Se premir Enter sem escolher, será selecionado PAL)\n👉 Escolha [1] ou [2]: "
        MSG_ASK_VOL="\n🎵 VOLUME\nNivelar automaticamente o volume (EBU R128)?\nℹ️  (Se premir Enter sem escolher, será selecionado SIM)\n👉 [s] SIM (Predefinição) / [n] NÃO: "
        MSG_ASK_OUT="\n💿 SAÍDA\n1) Apenas pastas (VIDEO_TS)\n2) Apenas ficheiro ISO\n3) Ambas (VIDEO_TS + ISO)  <-- [PREDEFINIÇÃO]\nℹ️  (Se premir Enter sem escolher, será selecionado 3)\n👉 Escolha [1], [2] ou [3]: "
        MSG_ASK_ISONAME="\n📝 NOME ISO\nIntroduza um nome personalizado\nℹ️  (Se premir Enter, o nome será 'hifi_dvd_project.iso')\n👉 Nome: "
        MSG_SUCCESS="🎉 HiFi DVD Pro: PROCESSO CONCLUÍDO COM SUCESSO!"
        MSG_ERR_COMP="\n❌ ERRO ao compilar. Revisa o ficheiro '$LOG_FILE' para mais detalhes."
        MSG_PRESS_ENTER="\n👉 Prima ENTER para fechar a janela..."
        MSG_CLOSING_IN="⏱️ A fechar em"
        ;;
    es)
        MSG_HEADER="HiFi DVD Pro - AUTORÍA PROFESIONAL DE DVD DE AUDIO"
        MSG_CALC="🔄 Analizando audio y calculando tamaño..."
        MSG_MISSING_DEPS="Faltan las siguientes herramientas en tu sistema:"
        MSG_ASK_INSTALL="¿Deseas instalarlas ahora automáticamente? (Requiere contraseña)\n👉 [s] SÍ (Por defecto) / [n] NO: "
        MSG_INSTALLING="🔄 Instalando paquetes..."
        MSG_INSTALL_FAIL="❌ ERROR: La instalación falló o fue cancelada."
        MSG_ERR_COVER="❌ ERROR: No se encontró 'cover.jpg' (o .png) en la carpeta actual."
        MSG_ERR_AUDIO="❌ ERROR: No hay archivos de audio compatibles en la carpeta."
        MSG_EST_DURATION="⏱️ Duración y Tamaño Real (ISO)"
        MSG_EST_CRITICAL="🚨 CRÍTICO: Supera el límite de Doble Capa (8.5 GB)."
        MSG_EST_NOTICE="⚠️ AVISO: Requiere un **DVD DE DOBLE CAPA (DVD-9 / 8.5 GB)**."
        MSG_EST_OK="✅ Cabe en un DVD estándar de capa simple (4.7 GB)."
        MSG_ASK_FMT="\n📺 FORMATO DE VÍDEO\n1) PAL (Europa/España - 720x576, 25fps)  <-- [POR DEFECTO]\n2) NTSC (América/Japón - 720x480, 29.97fps)\nℹ️  (Si pulsas Enter sin escribir nada, se elegirá PAL)\n👉 Elige [1] o [2]: "
        MSG_ASK_VOL="\n🎵 VOLUMEN\n¿Nivelar automáticamente el volumen (EBU R128)?\nℹ️  (Si pulsas Enter sin escribir nada, se elegirá SÍ)\n👉 [s] SÍ (Por defecto) / [n] NO: "
        MSG_ASK_OUT="\n💿 SALIDA\n1) Solo carpetas (VIDEO_TS)\n2) Solo archivo ISO\n3) Ambas (VIDEO_TS + ISO)  <-- [POR DEFECTO]\nℹ️  (Si pulsas Enter sin escribir nada, se elegirá 3)\n👉 Elige [1], [2] o [3]: "
        MSG_ASK_ISONAME="\n📝 NOMBRE ISO\nIntroduce un nombre personalizado\nℹ️  (Si pulsas Enter, se llamará 'hifi_dvd_project.iso')\n👉 Nombre: "
        MSG_SUCCESS="🎉 HiFi DVD Pro: ¡PROCESO COMPLETADO CON ÉXITO!"
        MSG_ERR_COMP="\n❌ ERROR al compilar. Revisa el archivo '$LOG_FILE' para más detalles."
        MSG_PRESS_ENTER="\n👉 Presiona ENTER para cerrar la ventana..."
        MSG_CLOSING_IN="⏱️ Cerrando ventana en"
        ;;
    *)
        MSG_HEADER="HiFi DVD Pro - PROFESSIONAL AUDIO DVD AUTHORING"
        MSG_CALC="🔄 Analyzing audio and calculating size..."
        MSG_MISSING_DEPS="The following dependencies are missing:"
        MSG_ASK_INSTALL="Do you want to install them now? (Requires sudo)\n👉 [y] YES (Default) / [n] NO: "
        MSG_INSTALLING="🔄 Installing packages..."
        MSG_INSTALL_FAIL="❌ ERROR: Installation failed."
        MSG_ERR_COVER="❌ ERROR: 'cover.jpg' not found."
        MSG_ERR_AUDIO="❌ ERROR: No compatible audio files found."
        MSG_EST_DURATION="⏱️ Duration and Real Size (ISO)"
        MSG_EST_CRITICAL="🚨 CRITICAL: Exceeds Dual Layer (8.5 GB)."
        MSG_EST_NOTICE="⚠️ NOTICE: Requires a **DUAL LAYER DVD (DVD-9 / 8.5 GB)**."
        MSG_EST_OK="✅ Fits in a standard single layer DVD (4.7 GB)."
        MSG_ASK_FMT="\n📺 VIDEO FORMAT\n1) PAL (720x576, 25fps)  <-- [DEFAULT]\n2) NTSC (720x480, 29.97fps)\nℹ️  (Press Enter to select PAL)\n👉 Choose [1] or [2]: "
        MSG_ASK_VOL="\n🎵 VOLUME\nNormalize volume (EBU R128)?\nℹ️  (Press Enter to select YES)\n👉 [y] YES (Default) / [n] NO: "
        MSG_ASK_OUT="\n💿 OUTPUT\n1) Folders only\n2) ISO only\n3) Both (Folders + ISO)  <-- [DEFAULT]\nℹ️  (Press Enter to select Both)\n👉 Choose [1], [2] or [3]: "
        MSG_ASK_ISONAME="\n📝 ISO FILENAME\nEnter a custom filename\nℹ️  (Press Enter to use 'hifi_dvd_project.iso')\n👉 Name: "
        MSG_SUCCESS="🎉 HiFi DVD Pro: PROCESS SUCCESSFULLY COMPLETED!"
        MSG_ERR_COMP="\n❌ ERROR compiling. Check '$LOG_FILE' for details."
        MSG_PRESS_ENTER="\n👉 Press ENTER to close this window..."
        MSG_CLOSING_IN="⏱️ Closing window in"
        ;;
esac

# =======================================================
# SISTEMA DE EXIT CONDICIONAL (Solo en caso de error)
# =======================================================
pause_on_exit() {
    local exit_code=$?
    local term_rows=$(tput lines 2>/dev/null || echo 24)
    printf "\033[1;%dr" "$term_rows" 2>/dev/null
    tput cnorm 2>/dev/null
    tput cup $((term_rows - 1)) 0 2>/dev/null
    
    if [ $exit_code -ne 0 ]; then
        echo -e "${MSG_PRESS_ENTER}"
        read -r
    fi
}
trap pause_on_exit EXIT

echo "======================================================="
echo "  📀 $MSG_HEADER 📀"
echo "======================================================="

# 1. Comprobar dependencias
ISO_TOOL=""
for tool in genisoimage mkisofs xorriso; do
    if command -v "$tool" &> /dev/null; then
        ISO_TOOL="$tool"
        break
    fi
done

MISSING_CMDS=""
for cmd in ffmpeg ffprobe dvdauthor; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_CMDS="$MISSING_CMDS $cmd"
    fi
done
if [ -z "$ISO_TOOL" ]; then
    MISSING_CMDS="$MISSING_CMDS genisoimage"
fi

if [ -n "$MISSING_CMDS" ]; then
    echo -e "\n$MSG_MISSING_DEPS $MISSING_CMDS"
    echo -e "$MSG_ASK_INSTALL"
    read -r resp_inst
    resp_inst="${resp_inst:-s}"
    if [[ "$resp_inst" =~ ^[SsYy] ]]; then
        echo "$MSG_INSTALLING"
        if command -v dnf &> /dev/null; then sudo dnf install -y $MISSING_CMDS
        elif command -v apt-get &> /dev/null; then sudo apt-get update && sudo apt-get install -y $MISSING_CMDS
        elif command -v pacman &> /dev/null; then sudo pacman -Syu --noconfirm $MISSING_CMDS
        elif command -v zypper &> /dev/null; then sudo zypper install -y $MISSING_CMDS
        else exit 1; fi
        
        for tool in genisoimage mkisofs xorriso; do
            if command -v "$tool" &> /dev/null; then ISO_TOOL="$tool"; break; fi
        done
    else exit 1; fi
fi

# 2. Comprobar y validar imagen de portada
COVER=""
for img in cover.jpg cover.jpeg cover.png COVER.JPG COVER.JPEG COVER.PNG; do
    if [ -f "$img" ]; then COVER="$img"; break; fi
done
if [ -z "$COVER" ]; then echo "$MSG_ERR_COVER"; exit 1; fi

MIN_WIDTH=576
MIN_HEIGHT=576
MAX_SIZE_MB=15
MAX_SIZE_BYTES=$(( MAX_SIZE_MB * 1024 * 1024 ))

IMG_W=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$COVER")
IMG_H=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$COVER")
FILE_SIZE=$(stat -c%s "$COVER" 2>/dev/null || wc -c < "$COVER")

IMG_W=${IMG_W:-0}
IMG_H=${IMG_H:-0}
FILE_SIZE=${FILE_SIZE:-0}

if [ "$IMG_W" -lt "$MIN_WIDTH" ] || [ "$IMG_H" -lt "$MIN_HEIGHT" ]; then
    echo -e "❌ ERROR: La imagen '$COVER' es demasiado pequeña (${IMG_W}x${IMG_H}px)."
    echo "ℹ️  Resolución mínima requerida: ${MIN_WIDTH}x${MIN_HEIGHT}px."
    exit 1
fi

if [ "$FILE_SIZE" -gt "$MAX_SIZE_BYTES" ]; then
    echo -e "❌ ERROR: La imagen '$COVER' pesa demasiado ($(( FILE_SIZE / 1024 / 1024 )) MB)."
    echo "ℹ️  Tamaño máximo permitido: ${MAX_SIZE_MB} MB."
    exit 1
fi

# 3. Comprobar archivos de audio
audio_files=( *.@(flac|mp3|wav|m4a|aac|ogg|wma|aiff) )
total_files=${#audio_files[@]}
if [ $total_files -eq 0 ]; then echo "$MSG_ERR_AUDIO"; exit 1; fi

# =======================================================
# 4. CÁLCULO INICIAL DE TAMAÑO
# =======================================================
echo -e "\n$MSG_CALC"

total_seconds=0
current_file_idx=0

for f in "${audio_files[@]}"; do
    [ -f "$f" ] || continue
    current_file_idx=$((current_file_idx + 1))
    fname=$(basename "$f")

    percentage=$(( (current_file_idx * 100) / total_files ))
    printf "\r[ Analizando: %3d%% (%d/%d) | %s ]\033[K" "$percentage" "$current_file_idx" "$total_files" "${fname:0:35}"

    dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null)
    dur_sec=$(echo "$dur" | cut -d'.' -f1)
    if [ -n "$dur_sec" ] && [ "$dur_sec" -gt 0 ] 2>/dev/null; then
        total_seconds=$(( total_seconds + dur_sec ))
    fi
done
echo -e "\n"

if [ "$total_seconds" -le 0 ]; then 
    total_seconds=$(( total_files * 240 ))
fi

# 5. ESTIMACIÓN DE TAMAÑO EN GB
calc_hours=$(( total_seconds / 3600 ))
calc_mins=$(( (total_seconds % 3600) / 60 ))
mins=$(( total_seconds / 60 ))

est_size_mb=$(( (mins * 26) + 20 ))
gb_int=$(( est_size_mb / 1024 ))
gb_dec=$(( ((est_size_mb % 1024) * 100) / 1024 ))

if [ $gb_dec -lt 10 ]; then
    est_size_gb="${gb_int}.0${gb_dec}"
else
    est_size_gb="${gb_int}.${gb_dec}"
fi

# 6. MOSTRAR RESUMEN DEL PROYECTO
echo "-------------------------------------------------------"
echo -e "${MSG_EST_DURATION}: ${calc_hours}h ${calc_mins}m (${mins} mins) | ~${est_size_gb} GB"

if [ "$est_size_mb" -gt 8100 ]; then
    echo -e "$MSG_EST_CRITICAL"
elif [ "$est_size_mb" -gt 4500 ]; then
    echo -e "$MSG_EST_NOTICE"
else
    echo -e "$MSG_EST_OK"
fi
echo "-------------------------------------------------------"

# =======================================================
# 7. PREGUNTAS AL USUARIO
# =======================================================
read -t 0.1 -n 10000 discard 2>/dev/null || true

echo -e "$MSG_ASK_FMT"
read -r resp_fmt
resp_fmt="${resp_fmt:-1}"

if [[ "$resp_fmt" == "2" ]]; then
    export VIDEO_FORMAT=NTSC; VID_RES="720:480"; VID_FPS="30000/1001"; VID_HEIGHT="480"; SAR_VAL="8/9"
else
    export VIDEO_FORMAT=PAL; VID_RES="720:576"; VID_FPS="25"; VID_HEIGHT="576"; SAR_VAL="64/45"
fi

echo -e "$MSG_ASK_VOL"
read -r resp_vol
resp_vol="${resp_vol:-s}"

if [[ "$resp_vol" =~ ^[SsYy] ]]; then
    AUDIO_FILTER="adelay=500|500,loudnorm=I=-16:TP=-1.0:LRA=11"
else
    AUDIO_FILTER="adelay=500|500"
fi

echo -e "$MSG_ASK_OUT"
read -r resp_out
resp_out="${resp_out:-3}"

iso_name="hifi_dvd_project.iso"
if [[ "$resp_out" == "2" || "$resp_out" == "3" ]]; then
    echo -e "$MSG_ASK_ISONAME"
    read -r custom_iso_name
    if [ -n "$custom_iso_name" ]; then
        if [[ "$custom_iso_name" != *.iso ]]; then iso_name="${custom_iso_name}.iso"; else iso_name="$custom_iso_name"; fi
    fi
fi

# =======================================================
# 8. RENDERIZADO CON REGISTRO EN LOG
# =======================================================
if [ "$IMG_W" -gt "$IMG_H" ]; then
    FILTER_V="scale=${VID_RES}:flags=lanczos,setsar=${SAR_VAL},setdar=16/9,fps=${VID_FPS}"
else
    if [ "$VID_HEIGHT" -eq "576" ]; then
        FILTER_V="scale=405:576:flags=lanczos,pad=720:576:(720-405)/2:0:color=black,setsar=${SAR_VAL},setdar=16/9,fps=${VID_FPS}"
    else
        FILTER_V="scale=360:480:flags=lanczos,pad=720:480:(720-360)/2:0:color=black,setsar=${SAR_VAL},setdar=16/9,fps=${VID_FPS}"
    fi
fi

OPTIMIZED_COVER=".cover_optimized.jpg"
ffmpeg -nostdin -hide_banner -y -i "$COVER" -vf "scale=-1:${VID_HEIGHT}:flags=lanczos" -q:v 2 "$OPTIMIZED_COVER" < /dev/null 2> >(tee -a "$LOG_FILE" >&2)
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló al procesar la imagen de portada. Revisa '$LOG_FILE'."
    exit 1
fi

rm -rf "$WORK_DIR" "$FINAL_DIR"
mkdir -p "$WORK_DIR" "$FINAL_DIR"

has_iso=0
if [[ "$resp_out" == "2" || "$resp_out" == "3" ]]; then has_iso=1; fi
total_steps=$(( 1 + total_files + 1 + has_iso ))
current_step=0

term_rows=$(tput lines 2>/dev/null || echo 24)

printf "\033[1;%dr" $((term_rows - 1)) 2>/dev/null
tput civis 2>/dev/null

update_bottom_counter() {
    local phase_desc="$1"
    current_step=$((current_step + 1))
    local percentage=$(( (current_step * 100) / total_steps ))
    [ $percentage -gt 100 ] && percentage=100
    
    tput sc 2>/dev/null
    tput cup $((term_rows - 1)) 0 2>/dev/null
    printf "\033[44m\033[37m PROGRESO GLOBAL: %3d%%  |  %s \033[0m\033[K" "$percentage" "$phase_desc"
    tput rc 2>/dev/null
}

update_bottom_counter "Optimizando portada"

counter=1
for f in "${audio_files[@]}"; do
    [ -f "$f" ] || continue
    out_mpg="$WORK_DIR/track_$(printf "%02d" $counter).mpg"
    track_name=$(basename "$f")
    
    update_bottom_counter "Pista $counter/$total_files: ${track_name:0:32}"
    
    ffmpeg -nostdin -hide_banner -y -threads 0 \
        -loop 1 -i "$OPTIMIZED_COVER" -i "$f" \
        -filter_complex "[0:v]${FILTER_V}[v];[1:a]${AUDIO_FILTER},aformat=sample_fmts=s16:sample_rates=48000[a]" \
        -map "[v]" -map "[a]" \
        -c:v mpeg2video -b:v 8000k -maxrate 8500k -bufsize 1835k -qscale:v 1 \
        -g 12 -bf 0 -mbd 2 -trellis 2 -cmp 2 -subcmp 2 \
        -pix_fmt yuv420p \
        -c:a pcm_s16be -ar 48000 \
        -f dvd -shortest "$out_mpg" < /dev/null 2> >(tee -a "$LOG_FILE" >&2)
        
    if [ $? -ne 0 ]; then
        cleanup
    fi
        
    counter=$((counter + 1))
done

rm -f "$OPTIMIZED_COVER"

# 9. GENERAR XML PARA EL MENÚ
mpg_files=( "$WORK_DIR"/*.mpg )
xml_file="dvdauthor.xml"

cat <<EOF > "$xml_file"
<dvdauthor>
  <vmgm />
  <titleset>
    <titles>
      <pgc>
EOF

for f in "${mpg_files[@]}"; do
    filename=$(basename "$f")
    echo "        <vob file=\"$WORK_DIR/$filename\" chapters=\"00:00:00.000\" />" >> "$xml_file"
done

cat <<EOF >> "$xml_file"
        <post>jump title 1 chapter 1;</post>
      </pgc>
    </titles>
  </titleset>
</dvdauthor>
EOF

# 10. CREAR ESTRUCTURA DVD E ISO
update_bottom_counter "Compilando estructuras de DVD"
dvdauthor -o "$FINAL_DIR" -x "$xml_file" > >(tee -a "$LOG_FILE") 2>&1
if [ $? -ne 0 ]; then
    cleanup
fi

if [[ "$resp_out" == "2" || "$resp_out" == "3" ]]; then
    update_bottom_counter "Generando archivo ISO final"
    vol_label=$(basename "$iso_name" .iso)
    
    if [ "$ISO_TOOL" = "xorriso" ]; then
        xorriso -outdev "$iso_name" -blank as_needed -dvd-video "$FINAL_DIR" -volid "$vol_label" > >(tee -a "$LOG_FILE") 2>&1
    else
        "$ISO_TOOL" -dvd-video -V "$vol_label" -o "$iso_name" "$FINAL_DIR" > >(tee -a "$LOG_FILE") 2>&1
    fi

    if [ $? -ne 0 ]; then
        cleanup
    fi
    if [[ "$resp_out" == "2" ]]; then rm -rf "$FINAL_DIR"; fi
fi

if [[ "$resp_out" == "1" || "$resp_out" == "3" ]]; then
    rm -rf DVD_FINAL
    mv "$FINAL_DIR" DVD_FINAL
fi

printf "\033[1;%dr" "$term_rows" 2>/dev/null
tput cnorm 2>/dev/null
tput cup $((term_rows - 1)) 0 2>/dev/null
tput el 2>/dev/null

if { [ "$resp_out" = "1" ] && [ -d "DVD_FINAL/VIDEO_TS" ] && [ "$(ls -A DVD_FINAL/VIDEO_TS)" ]; } || \
   { [ "$resp_out" = "2" ] && [ -f "$iso_name" ]; } || \
   { [ "$resp_out" = "3" ] && [ -d "DVD_FINAL/VIDEO_TS" ] && [ -f "$iso_name" ]; }; then
    rm -rf "$WORK_DIR" "$FINAL_DIR" "$xml_file" "$LOG_FILE"
    
    echo -e "\n=========================================================="
    echo " $MSG_SUCCESS"
    echo -e "=========================================================="
    
    # Notificación de escritorio en Linux (si existe notify-send)
    command -v notify-send &>/dev/null && notify-send "HiFi DVD Pro" "$MSG_SUCCESS" -i media-optical 2>/dev/null
    
    # Temporizador de 3 segundos visual con salida por cualquier tecla
    for i in 3 2 1; do
        printf "\r%s %d s... (Presiona cualquier tecla para salir ya)\033[K" "$MSG_CLOSING_IN" "$i"
        read -t 1 -n 1 && break || true
    done
    echo ""
    
    exit 0
else
    echo -e "$MSG_ERR_COMP"
    cleanup
fi