extends Node


var intro_scene = preload("res://Scenes/Intro.tscn")
var main_scene = preload("res://Scenes/Hakugyokurou.tscn")
var epilogue_scene = preload("res://Scenes/Epilogue.tscn")

var target_scene

var broken_walls = {
	# "level name": [[grid_x, grid_y], ...]
	"Hakugyokurou": [],
}

var collected_phantoms = 0
