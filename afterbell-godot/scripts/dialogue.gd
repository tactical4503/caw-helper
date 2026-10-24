extends RefCounted
## Subtitles with typewriter reveal and per-character "voice blips" (no recorded voices needed).
##
## Each speaker has a voice: base pitch, waveform, blip length and how much the pitch wanders.
## Every second letter revealed plays one blip; the letter itself nudges the pitch, so the same
## line always "sounds" the same. Narration (empty speaker) types out silently.
##
## Usage: var d := Dialogue.new(sfx, who_label, text_label); d.say("MIKA", "..."); d.update(dt)

const CHARS_PER_SEC := 38.0
const HOLD_AFTER := 1.1     # seconds a finished line stays on screen (at least)

## pitch Hz, waveform ("sine"/"tri"), blip seconds, pitch spread, volume, wooden click
const VOICES := {
	"REN": [210.0, "tri", 0.045, 0.06, 0.10, false],              # short, clipped, low-key
	"MIKA": [330.0, "tri", 0.035, 0.08, 0.09, false],             # quick and precise
	"NELL": [470.0, "sine", 0.05, 0.16, 0.10, false],             # bright, wanders more
	"HESTA": [175.0, "tri", 0.06, 0.05, 0.11, false],             # low and firm
	"LEN": [300.0, "sine", 0.045, 0.12, 0.09, false],
	"FLOOR MANAGER": [125.0, "tri", 0.04, 0.03, 0.12, true],      # hollow, wooden
}
const DEFAULT_VOICE := [260.0, "sine", 0.045, 0.1, 0.09, false]

var sfx
var who_label: Label
var text_label: Label
var queue: Array = []
var current = null          # [speaker, text, min_duration]
var elapsed := 0.0
var shown := 0
var blips_played := 0


func _init(sound, who: Label, text: Label) -> void:
	sfx = sound
	who_label = who
	text_label = text


func say(speaker: String, text: String, duration := 2.6) -> void:
	queue.append([speaker, text, duration])


func clear() -> void:
	queue.clear()
	current = null
	who_label.text = ""
	text_label.text = ""


func is_idle() -> bool:
	return current == null and queue.is_empty()


func update(dt: float) -> void:
	if current == null:
		if queue.is_empty():
			return
		current = queue.pop_front()
		elapsed = 0.0
		shown = 0
		who_label.text = current[0]
		text_label.text = current[1]
		text_label.visible_characters = 0
	elapsed += dt
	var line: String = current[1]
	var target := mini(line.length(), int(elapsed * CHARS_PER_SEC))
	while shown < target:
		_voice(current[0], line[shown], shown)
		shown += 1
	text_label.visible_characters = shown
	var type_time := line.length() / CHARS_PER_SEC
	if elapsed >= maxf(current[2], type_time + HOLD_AFTER):
		current = null
		who_label.text = ""
		text_label.text = ""


func _voice(speaker: String, ch: String, index: int) -> void:
	if speaker == "" or sfx == null or index % 2 == 1:
		return
	var code := ch.unicode_at(0)
	var is_letter := (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
	if not is_letter:
		return
	var v: Array = VOICES.get(speaker, DEFAULT_VOICE)
	var lower := ch.to_lower()
	var vowel := lower in ["a", "e", "i", "o", "u"]
	# The letter picks a step in a small scale around the speaker's pitch.
	var step := (code % 7) - 3
	var pitch: float = v[0] * (1.0 + step * v[3] * 0.33)
	var length: float = v[2] * (1.4 if vowel else 1.0)
	sfx.tone(pitch, length, v[4], 0.0, pitch * (0.92 if vowel else 1.04), v[1])
	if v[5]:
		sfx.noise(0.012, v[4] * 0.8)   # the knock of a wooden jaw
	blips_played += 1
