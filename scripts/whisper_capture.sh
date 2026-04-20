#!/bin/bash
# whisper_capture.sh - STABLE/CPU version

LOGFILE="/tmp/ecdd_whisper.log"
touch "$LOGFILE"

echo "[$(date)] Starting safe capture..." >> "$LOGFILE"

# CONFIGURATION
WHISPER_BIN="/c/Users/jamie/.local/bin/whisper.exe"
export AUDIODRIVER=waveaudio

# Windows-friendly temp location
TEMP_DIR="${USERPROFILE}/AppData/Local/Temp"
mkdir -p "$TEMP_DIR"
TEMP_WAV=$(mktemp --tmpdir="$TEMP_DIR" --suffix=.wav)
WIN_WAV=$(cygpath -w "$TEMP_WAV")

trap "rm -f $TEMP_WAV" EXIT

# Capture 4 seconds
timeout 4s rec -q -c 1 -r 16000 -t wav "$TEMP_WAV" 2>> "$LOGFILE"

if [ -s "$TEMP_WAV" ]; then
    echo "[$(date)] Safe Transcribing (CPU Only): $WIN_WAV" >> "$LOGFILE"
    TBASE=$(basename "$TEMP_WAV" .wav)
    TDIR=$(dirname "$TEMP_WAV")
    
    # OPTS: --device cpu (forces CPU), --threads 2 (prevents CPU 100% lockup)
    "$WHISPER_BIN" "$WIN_WAV" --model tiny --language en --device cpu --threads 2 --fp16 False --verbose False --output_dir "$TDIR" --output_format txt 2>> "$LOGFILE"
    
    TXT_FILE="${TDIR}/${TBASE}.txt"
    if [ -f "$TXT_FILE" ]; then
        RESULT=$(cat "$TXT_FILE" | tr -d '\n\r' | sed 's/^ *//')
        echo "[$(date)] Result: $RESULT" >> "$LOGFILE"
        echo "$RESULT"
        rm -f "$TXT_FILE"
    else
        echo "[$(date)] ERROR: Whisper failed or was killed." >> "$LOGFILE"
    fi
else
    echo "[$(date)] ERROR: Empty recording." >> "$LOGFILE"
    exit 1
fi
