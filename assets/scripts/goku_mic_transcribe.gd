extends Control

@export var chat : NobodyWhoChat
@export var myWords : RichTextLabel
@onready var mic_player: AudioStreamPlayer = $CaptureStreamToText/MicPlayer
@export var captureStreamToText : CaptureStreamToText
@onready var mouthAnimationTree = $"3dScene/GokuScene/mouthAnimationTree"
@onready var headAnimationTree = $"3dScene/GokuScene/headAnimations/headAnimationTree"
var regularMouth = load("res://assets/blender/goku/imagesAndPSDS/mouth.png")
var talkingMouth1 = load("res://assets/blender/goku/imagesAndPSDS/mouthTalking1.png")



func _ready() -> void:
	chat.system_prompt = "your name is goku and you are a saiyan from earth! NEVER USE EMOJIS IN YOUR REPONSIVES"
	chat.start_worker()


func _mouth_animation_start():
	mouthAnimationTree.set("parameters/conditions/moving",true)
	mouthAnimationTree.set("parameters/conditions/idle",false)


func _mouth_animation_stop():
	mouthAnimationTree.set("parameters/conditions/idle",true)
	mouthAnimationTree.set("parameters/conditions/moving",false)
	#going back to idle state as well
	_trigger_head_animation_state(0)#idle
	$CaptureStreamToText/Panel/Label._wipe_text()
	isTalking = false

func _trigger_head_animation_state(state):
	headAnimationTree.set("parameters/conditions/idle", false)
	headAnimationTree.set("parameters/conditions/listening", false)
	headAnimationTree.set("parameters/conditions/talking", false)
	match state:
		0, "idle":
			headAnimationTree.set("parameters/conditions/idle", true)
		1, "listening", "listen":
			headAnimationTree.set("parameters/conditions/listening", true)
		2, "talking", "talk":
			headAnimationTree.set("parameters/conditions/talking", true)


var started = false
var canRecord = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		if started == false:
			_start_thread()
			started = true
		
	if event.is_action_pressed("space"):
		#_trial_run()
		if isTalking == false:
			canRecord = !canRecord
			if canRecord == true:
				_listening()
			else:
				_talking()
			
		#$CaptureStreamToText/Panel/Label.text = "" #sa does nothing
		#_can_play()


func _listening():
	mic_player.play()
	_trigger_head_animation_state(1)#listening
	$CaptureStreamToText/Panel/Label._restart_text()#starts text if available

var isTalking = false
func _talking():
	isTalking = true
	#stop lisenting and switch animations
	mic_player.stop()
	_trigger_head_animation_state(2)#talking
	
	var words = myWords.get_parsed_text()
	#var words = "what is your name" #this is a test
	
	print("I said : ", words)
	chat.say(words)
	
	var response = await chat.response_finished
	
	print("He said: " + response)
	var voices = DisplayServer.tts_get_voices_for_language("en")
	var voice_id = voices[0]
	
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_ENDED, _stop_mouth)
	DisplayServer.tts_speak(response, voice_id)
	_mouth_animation_start()


func _stop_mouth(_id):
	_mouth_animation_stop()
	


func _mouth_animation(whichMouth : int):
	var pickedMouth : Texture
	match whichMouth:
		0:
			pickedMouth = regularMouth
		1:
			pickedMouth = talkingMouth1

	var mouthMaterial = $"3dScene/GokuScene/goku/headShape".get_active_material(2)
	mouthMaterial.albedo_texture =  pickedMouth


#depreciated can_play
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
