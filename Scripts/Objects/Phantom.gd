extends Node2D

const Constants = preload("res://Scripts/Constants.gd")


export var emotion : int
var animated_sprite : AnimatedSprite

# 0: active, 1: taken, 2: waiting respawn
var cycle_stage : int = ACTIVE
const ACTIVE = 0
const TAKEN = 1
const WAITING_RESPAWN = 2

var pos : Vector2
var original_pos : Vector2
var player : Player
var spawn_timer : float
var time_since_taken : float
var move_speed : float = 1

func _ready():
	pos = Vector2(position.x / Constants.GRID_SIZE, -1 * position.y / Constants.GRID_SIZE)
	original_pos = pos
	position.x = position.x * Constants.SCALE_FACTOR
	position.y = position.y * Constants.SCALE_FACTOR
	scale.x = Constants.SCALE_FACTOR
	scale.y = Constants.SCALE_FACTOR
	if emotion == Constants.EMOTION.JOY:
		animated_sprite = get_node("JoyAnim")
	elif emotion == Constants.EMOTION.WRATH:
		animated_sprite = get_node("WrathAnim")
	elif emotion == Constants.EMOTION.SORROW:
		animated_sprite = get_node("SorrowAnim")
	elif emotion == Constants.EMOTION.PLEASURE:
		animated_sprite = get_node("PleasureAnim")
	for temp_anim_sprite in get_children():
		temp_anim_sprite.visible = false
	animated_sprite.visible = true

func init_w_player(player : Player):
	self.player = player

func take_end():
	cycle_stage = WAITING_RESPAWN
	pos = original_pos
	position.x = pos.x * Constants.GRID_SIZE * Constants.SCALE_FACTOR
	position.y = -pos.y * Constants.GRID_SIZE * Constants.SCALE_FACTOR
	spawn_timer = Constants.PHANTOM_SPAWN_COOLDOWN
	move_speed = 1
	animated_sprite.visible = false
	player.gain_phantom(emotion)

func _process(delta):
	delta *= get_node("/root/Scene").delta_factor
	if cycle_stage == TAKEN:
		var directional_vector : Vector2 = Vector2(player.pos.x, player.pos.y + Constants.UNIT_HIT_BOXES[player.unit_type][Constants.HIT_BOX_BOUND.UPPER_BOUND] / 2) - pos
		if directional_vector.length() < move_speed * delta:
			take_end()
		else:
			var move_dist = move_speed * delta
			var fraction_moved = move_dist / directional_vector.length()
			pos.x += directional_vector.x * fraction_moved
			pos.y += directional_vector.y * fraction_moved
			position.x = pos.x * Constants.GRID_SIZE * Constants.SCALE_FACTOR
			position.y = -1 * pos.y * Constants.GRID_SIZE * Constants.SCALE_FACTOR
			time_since_taken += delta
			move_speed += time_since_taken
	elif cycle_stage == WAITING_RESPAWN:
		spawn_timer = max(0, spawn_timer - delta)
		if spawn_timer == 0:
			cycle_stage = ACTIVE
			animated_sprite.visible = true
	else: # cycle == ACTIVE
		var directional_vector : Vector2 = Vector2(player.pos.x, player.pos.y + Constants.UNIT_HIT_BOXES[player.unit_type][Constants.HIT_BOX_BOUND.UPPER_BOUND] / 2) - pos
		if directional_vector.length() < 1.5:
			cycle_stage = TAKEN
			time_since_taken = 0
			
