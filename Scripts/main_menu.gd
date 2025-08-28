extends Control

@onready var playBtn = %Play
@onready var quitBtn = %Quit

# Volume #
@onready var masterPercent = %PercentMaster
@onready var musicPercent = %PercentMusic
@onready var sfxPercent = %PercentSFX
@onready var sfxUiMove = %SFX_UI_move

var MASTER_AUDIO_NAME:String = "Master"
var MUSIC_AUDIO_NAME:String = "Music"
var SFX_AUDIO_NAME:String = "SFX"

var MASTER_AUDIO_ID
var MUSIC_AUDIO_ID
var SFX_AUDIO_ID

var Decibels
# ---X--- #

func _ready() -> void:
	# Buttons
	playBtn.pressed.connect(play)
	quitBtn.pressed.connect(quit_game)
	
	# Values volume
	masterPercent.text = "100%"
	musicPercent.text = "100%"
	sfxPercent.text = "100%"
	
	MASTER_AUDIO_ID = AudioServer.get_bus_index(MASTER_AUDIO_NAME)
	MUSIC_AUDIO_ID = AudioServer.get_bus_index(MUSIC_AUDIO_NAME)
	SFX_AUDIO_ID = AudioServer.get_bus_index(SFX_AUDIO_NAME)
	
	# Verification web
	if (OS.has_feature("web")):
		quitBtn.queue_free()
	
func play():
	get_tree().change_scene_to_file("res://Nodes/defaultStage.tscn")
	
func quit_game():
	get_tree().quit()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_slider_master_value_changed(value: float) -> void:
	Decibels = linear_to_db(value)
	masterPercent.text = str(roundi(value*100)) + "%"
	AudioServer.set_bus_volume_db(MASTER_AUDIO_ID, Decibels)

func _on_slider_music_value_changed(value: float) -> void:
	Decibels = linear_to_db(value)
	musicPercent.text = str(roundi(value*100)) + "%"
	AudioServer.set_bus_volume_db(MUSIC_AUDIO_ID, Decibels)
	

func _on_slider_sfx_value_changed(value: float) -> void:
	sfxUiMove.play()
	Decibels = linear_to_db(value)
	sfxPercent.text = str(roundi(value*100)) + "%"
	AudioServer.set_bus_volume_db(SFX_AUDIO_ID, Decibels)
	
