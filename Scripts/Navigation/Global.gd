extends Node


var title_scene = preload("res://Scenes/Title.tscn")
var main_scene = preload("res://Scenes/Hakugyokurou.tscn")

var target_scene

var broken_walls = {
	# "level name": [[grid_x, grid_y], ...]
	"Hakugyokurou": [],
}
