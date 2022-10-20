extends Node

#var menu_theme = preload("res://Audio/Nekophantasia.mp3")
#var game_theme = preload("res://Audio/Utsuho - The Magician.mp3")
#var gap_noise = preload("res://Audio/mixkit-arcade-retro-jump-223.mp3")
onready var player = get_node("AudioStreamPlayer")
#onready var sfx_player = get_node("SFXPlayer")

func _ready():
	pass
	#sfx_player.stream = gap_noise
	#sfx_player.volume_db = -20
	#gap_noise.loop = false

#func play_menu_theme():
#	if player.stream != menu_theme:
#		player.stop()
#		player.stream = menu_theme
#		player.volume_db = -10
#		player.play()

#func play_game_theme():
#	if player.stream != game_theme:
#		player.stop()
#		player.stream = game_theme
#		player.play()

#func play_gap():
#	sfx_player.play()

#func _process(delta):
#	if player.stream == menu_theme and player.get_playback_position() >= 41.5:
#		player.stop()
#		player.play()
#	pass
