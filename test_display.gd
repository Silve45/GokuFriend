extends RichTextLabel

var canUpdateText = true
func update_text():
	text = completed_text + "[color=green]" + partial_text + "[/color]"
	#text = completed_text  + partial_text 

func _process(_delta):
	if canUpdateText == true:
		update_text()

var completed_text := ""
var partial_text := ""

func _on_capture_stream_to_text_transcribed_msg(is_partial, new_text):
	if is_partial == true:
		completed_text += new_text
		partial_text = ""
	else:
		if new_text!="":
			partial_text = new_text

func _wipe_text():
	text = ""
	completed_text = ""
	partial_text = ""
	canUpdateText = false

func _restart_text():
	canUpdateText = true
