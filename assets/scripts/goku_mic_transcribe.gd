extends Control

@export var chat : NobodyWhoChat
@export var myWords : RichTextLabel
@onready var mic_player: AudioStreamPlayer = $CaptureStreamToText/MicPlayer
@export var captureStreamToText : CaptureStreamToText
var regularMouth = load("res://assets/blender/goku/imagesAndPSDS/mouth.png")
var talkingMouth1 = load("res://assets/blender/goku/imagesAndPSDS/mouthTalking1.png")
var canRecord = false


func _ready() -> void:
	chat.system_prompt = "your name is goku and you are a saiyan from earth! NEVER USE EMOJIS IN YOUR REPONSIVES"
	chat.start_worker()
	

func _mouth_animation_start():
	$"3dScene/GokuScene/mouthAnimations".play("mouthAnimation")
	#await DisplayServer.tts_is_speaking() == false
	#print("stop")
	#_mouth_animation_stop()
	

func _mouth_animation_stop():
	$"3dScene/GokuScene/mouthAnimations".play("idleMouth")



var incrementNum = 0
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		#_trial_run()
		#_start_thread()
		pass
	if event.is_action_pressed("debug"):
		_trial_run()
		#canRecord = !canRecord
		#$CaptureStreamToText/Panel/Label.text = ""
		#_can_play()

func _can_play():
	if canRecord == true:
		#$CaptureStreamToText.recording = true
		mic_player.play()
		$CaptureStreamToText/Panel/Label._restart_text()
	else:
		mic_player.stop()
		$CaptureStreamToText/Panel/Label._wipe_text()
		#$CaptureStreamToText.recording = false


var thread : Thread
func _start_thread():
	if Engine.is_editor_hint():
		return
	if thread && thread.is_alive():
		captureStreamToText.recording = false
		thread.wait_to_finish()
	thread = Thread.new()
	captureStreamToText._effect_capture.clear_buffer()
	thread.start(captureStreamToText.transcribe_thread)


func _replace_first(from: String, what: String, forwhat: String):
	var idx = from.find(what)
	if idx == -1: return from
	return from.substr(0, idx) + forwhat + from.substr(idx + what.length())


var extraWords : String
func _trial_run():
	var words = myWords.text
	var finalWords = _replace_first(words, extraWords, "")
	
	var testWords = "what is your name"
	
	print("I said : ", testWords)
	chat.say(testWords)
	
	extraWords = words #add all previous words to this string
	var response = await chat.response_finished
	
	print("He said: " + response)
	var voices = DisplayServer.tts_get_voices_for_language("en")
	var voice_id = voices[0]
	
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_ENDED, _stop_mouth)
	DisplayServer.tts_speak(response, voice_id)
	_mouth_animation_start()
	


func _stop_mouth(_id):
	_mouth_animation_stop()
	printerr(" DONENOEONENOE")


func _mouth_animation(whichMouth : int):
	var pickedMouth : Texture
	match whichMouth:
		0:
			pickedMouth = regularMouth
		1:
			pickedMouth = talkingMouth1

	var mouthMaterial = $"3dScene/GokuScene/goku/headShape".get_active_material(2)
	mouthMaterial.albedo_texture =  pickedMouth
