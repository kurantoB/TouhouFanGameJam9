extends Control


onready var global = get_node("/root/Global")
onready var anim_p : AnimationPlayer = get_node("/root/Control/ColorRect/AnimationPlayer")

func _ready():
	pass
	# MusicController.play_menu_theme()


func _on_Start_button_up():
	global.target_scene = global.main_scene
	anim_p.play("TitleTransition")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "TitleTransition":
		get_tree().change_scene_to(global.target_scene)
