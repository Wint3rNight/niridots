#!/usr/bin/env bash
# Audio output switcher, per application.
#
# WHY THIS EXISTS: DankMaterialShell has no per-app routing at all - no UI and no IPC.
# `dms ipc call audio cycleoutput` and the media panel's output picker both only change
# the *default sink*, which moves every stream that is not pinned. That is fine for
# "move everything", but it cannot express "Spotify on the speaker, YouTube in my ears".
#
# WirePlumber can: node.stream.restore-target is on by default, so the moment a stream is
# moved by hand it remembers that app's output and re-applies it every time the app
# starts. Moving a stream here is therefore permanent until you move it back.
#
# (A previous version of this setup disabled exactly that, with a stream.rules fragment
# setting state.restore-target=false for Spotify. It made Spotify follow the default sink,
# and in doing so destroyed the per-app routing this script now exposes. The fragment is
# gone; do not reintroduce it.)
#
# Selecting an app moves it to the next sink. Selecting the "Default output" row cycles
# the default instead, which moves everything that has no pin of its own.

sinks_json=$(pactl -f json list sinks)
inputs_json=$(pactl -f json list sink-inputs)
default_sink=$(pactl get-default-sink)

menu=$(SINKS="$sinks_json" INPUTS="$inputs_json" DEFAULT="$default_sink" python3 - <<'PY'
import json, os

sinks = json.loads(os.environ["SINKS"])
inputs = json.loads(os.environ["INPUTS"])
default = os.environ["DEFAULT"]


def short(desc):
    # "JBL TUNE 310C USB-C Analog Stereo" -> "JBL TUNE 310C"; keep it scannable.
    return " ".join(desc.split()[:3])


# A sink-input's "sink" field is the sink's numeric index, not its name.
by_index = {s["index"]: s for s in sinks}
by_name = {s["name"]: s for s in sinks}
lines = []

for i in inputs:
    props = i.get("properties", {})
    app = props.get("application.name") or props.get("media.name") or f"stream {i['index']}"
    sink = by_index.get(i.get("sink"), {})
    lines.append(f"{app}  ·  {short(sink.get('description', '?'))}\t{i['index']}")

if lines:
    lines.append("\t")  # separator row, ignored on selection

cur = by_name.get(default, {})
lines.append(f"Default output  ·  {short(cur.get('description', '?'))}\tDEFAULT")

print("\n".join(lines))
PY
)

[ -z "$menu" ] && exit 0

choice=$(printf '%s' "$menu" | cut -f1 | rofi -dmenu -i -p "Audio output" -format i)
[ -z "$choice" ] && exit 0

target=$(printf '%s' "$menu" | sed -n "$((choice + 1))p" | cut -f2)
[ -z "$target" ] && exit 0

# Next sink after the one currently in use, wrapping around.
next_sink() {
    local current="$1"
    local names
    mapfile -t names < <(pactl list short sinks | awk '{print $2}')
    local n=${#names[@]}
    for i in "${!names[@]}"; do
        if [ "${names[$i]}" = "$current" ]; then
            echo "${names[$(((i + 1) % n))]}"
            return
        fi
    done
    echo "${names[0]}"
}

if [ "$target" = "DEFAULT" ]; then
    dest=$(next_sink "$default_sink")
    pactl set-default-sink "$dest"
    label="Default output"
else
    # "sink" is the sink index; next_sink() works on names, so map it across.
    current=$(printf '%s' "$inputs_json" | IDX="$target" SINKS="$sinks_json" python3 -c "
import json,os,sys
idx = int(os.environ['IDX'])
by_index = {s['index']: s['name'] for s in json.loads(os.environ['SINKS'])}
for i in json.load(sys.stdin):
    if i['index'] == idx:
        print(by_index.get(i.get('sink'), ''))
        break")
    dest=$(next_sink "$current")
    pactl move-sink-input "$target" "$dest"
    label=$(printf '%s' "$menu" | sed -n "$((choice + 1))p" | cut -f1 | sed 's/  ·.*//')
fi

if command -v notify-send >/dev/null; then
    desc=$(pactl list sinks | grep -A1 "Name: $dest\$" | grep Description | sed 's/.*Description: //')
    notify-send -a "Audio" -t 2500 "$label" "→ ${desc:-$dest}"
fi
