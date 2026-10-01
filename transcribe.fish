function transcribe
    set input $argv[1]

    if test -z "$input"
        echo "Usage: transcribe video.mp4"
        return 1
    end

    if not test -f "$input"
        echo "File not found: $input"
        return 1
    end

    set base (string replace -r '\.[^.]+$' '' "$input")
    set wav "$base.wav"
    set model "$HOME/.local/share/whisper/ggml-medium.bin"

    if not test -f "$model"
        echo "Whisper model not found:"
        echo "$model"
        return 1
    end

    echo "Extracting audio..."
    ffmpeg -y -i "$input" \
        -ar 16000 \
        -ac 1 \
        -c:a pcm_s16le \
        "$wav"

    if test $status -ne 0
        echo "ffmpeg failed"
        return 1
    end

    echo "Transcribing..."
    whisper-cli \
        -m "$model" \
        -f "$wav" \
        -otxt

    if test $status -ne 0
        echo "whisper-cli failed"
        rm -f "$wav"
        return 1
    end

    if test -f "$wav.txt"
        mv "$wav.txt" "$base.txt"
    end

    rm -f "$wav"

    echo "Done: $base.txt"
end
