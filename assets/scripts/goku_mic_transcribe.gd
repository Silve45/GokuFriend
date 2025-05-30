extends Control

@export var chat : NobodyWhoChat
@export var myWords : RichTextLabel
@onready var mic_player: AudioStreamPlayer = $CaptureStreamToText/MicPlayer

func _ready() -> void:
	chat.system_prompt = "your name is goku and you are a saiyan from earth! NEVER USE EMOJIS IN YOUR REPONSIVES"
	chat.start_worker()
	

var canRecord = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		printerr("enter pressed")
		_trial_run()
	if event.is_action_pressed("debug"):
		canRecord = !canRecord
		$CaptureStreamToText/Panel/Label.text = ""
		_can_play()

func _can_play():
	if canRecord == true:
		#$CaptureStreamToText.recording = true
		mic_player.play()
	else:
		mic_player.stop()
		#$CaptureStreamToText.recording = false


func _replace_first(from: String, what: String, forwhat: String):
	var idx = from.find(what)
	if idx == -1: return from
	return from.substr(0, idx) + forwhat + from.substr(idx + what.length())


var extraWords : String
func _trial_run():
	var words = myWords.text
	var finalWords = _replace_first(words, extraWords, "")
	
	printerr("I said : ", finalWords)
	chat.say(finalWords)
	
	extraWords = words #add all previous words to this string
	
	var response = await chat.response_finished
	print("He said: " + response)
	var voices = DisplayServer.tts_get_voices_for_language("en")
	var voice_id = voices[0]
	
	DisplayServer.tts_speak(response, voice_id)
	
