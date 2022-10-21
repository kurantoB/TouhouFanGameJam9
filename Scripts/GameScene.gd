extends Node

# _process(delta) is called by this class
# player input is handled here
# unit declares its intention in process_unit()
# stage environment interacts with the unit in interact()
# unit executes its resulting state in react()
# stage environment interacts with the unit once more in interact_post()
class_name GameScene

export var tile_set_name: String
export var level_name: String
const Constants = preload("res://Scripts/Constants.gd")
const Unit = preload("res://Scripts/Unit.gd")

var units = []
var player : Player
var player_cam : Camera2D

# [pressed?, just pressed?, just released?]
var input_table = {
	Constants.PlayerInput.UP: [false, false, false],
	Constants.PlayerInput.DOWN: [false, false, false],
	Constants.PlayerInput.LEFT: [false, false, false],
	Constants.PlayerInput.RIGHT: [false, false, false],
	Constants.PlayerInput.GBA_A: [false, false, false],
	Constants.PlayerInput.GBA_B: [false, false, false],
	Constants.PlayerInput.GBA_SELECT: [false, false, false],
}
const I_T_PRESSED : int = 0
const I_T_JUST_PRESSED : int = 1
const I_T_JUST_RELEASED : int = 2

var stage_env

# Called when the node enters the scene tree for the first time.
func _ready():
	units.append(get_node("Player"))
	player = units[0]
	player.init_unit_w_scene(self)
	player_cam = player.get_node("Camera2D")
	player_cam.make_current()
	
	stage_env = load("res://Scripts/StageEnvironment.gd").new(self)
	player.get_node("Camera2D").make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for unit in units:
		unit.reset_actions()
		unit.handle_input(delta)
		unit.reset_current_action()
		unit.process_unit(delta)
		stage_env.interact(unit, delta)
		unit.react(delta)
		stage_env.interact_post(unit)
	# visual effects
	if (player.facing == Constants.Direction.RIGHT):
		player_cam.offset_h = 1
	else:
		player_cam.offset_h = -1

func handle_player_input():
	for input_num in input_table.keys():
		if Input.is_action_pressed(Constants.INPUT_MAP[input_num]):
			input_table[input_num][I_T_PRESSED] = true
			input_table[input_num][I_T_JUST_RELEASED] = false
			if Input.is_action_just_pressed(Constants.INPUT_MAP[input_num]):
				input_table[input_num][I_T_JUST_PRESSED] = true
			else:
				input_table[input_num][I_T_JUST_PRESSED] = false
		else:
			input_table[input_num][I_T_PRESSED] = false
			input_table[input_num][I_T_JUST_PRESSED] = false
			if Input.is_action_just_released(Constants.INPUT_MAP[input_num]):
				input_table[input_num][I_T_JUST_RELEASED] = true
			else:
				input_table[input_num][I_T_JUST_RELEASED] = false
	
	# process input_table
	
	if input_table[Constants.PlayerInput.LEFT][I_T_PRESSED] or input_table[Constants.PlayerInput.RIGHT][I_T_PRESSED]:
		if input_table[Constants.PlayerInput.LEFT][I_T_PRESSED] and input_table[Constants.PlayerInput.RIGHT][I_T_PRESSED]:
			input_table[Constants.PlayerInput.LEFT][I_T_PRESSED] = false
			input_table[Constants.PlayerInput.LEFT][I_T_JUST_PRESSED] = false
		var input_dir
		if input_table[Constants.PlayerInput.LEFT][I_T_PRESSED]:
			input_dir = Constants.Direction.LEFT
		else:
			input_dir = Constants.Direction.RIGHT
		if player.unit_conditions[Constants.UnitCondition.IS_ON_GROUND]:
			if player.unit_conditions[Constants.UnitCondition.MOVING_STATUS] == Constants.UnitMovingStatus.IDLE:
				if player.timer_actions[Constants.ActionType.DASH] > 0 and player.dash_facing == input_dir:
					player.set_action(Constants.ActionType.DASH)
				else:
					player.set_action(Constants.ActionType.MOVE)
			elif player.unit_conditions[Constants.UnitCondition.MOVING_STATUS] == Constants.UnitMovingStatus.MOVING:
				player.set_action(Constants.ActionType.MOVE)
			else:
				if player.facing == input_dir:
					player.set_action(Constants.ActionType.DASH)
				else:
					player.set_action(Constants.ActionType.MOVE)
			player.dash_facing = input_dir
			player.set_timer_action(Constants.ActionType.DASH)
		else:
			if (player.unit_conditions[Constants.UnitCondition.MOVING_STATUS] == Constants.UnitMovingStatus.DASHING
			and input_dir == player.facing
			and player.h_speed != 0):
				player.set_action(Constants.ActionType.DASH)
			else:
				player.set_action(Constants.ActionType.MOVE)
				player.reset_timer_action(Constants.ActionType.DASH)
		# set facing
		player.facing = input_dir
	
	if input_table[Constants.PlayerInput.GBA_A][I_T_PRESSED]:
		if (player.get_current_action() == Constants.UnitCurrentAction.JUMPING
		or (player.get_current_action() == Constants.UnitCurrentAction.IDLE
		and player.unit_conditions[Constants.UnitCondition.IS_ON_GROUND]
		and input_table[Constants.PlayerInput.GBA_A][I_T_JUST_PRESSED])):
			player.set_action(Constants.ActionType.JUMP)
	
	if input_table[Constants.PlayerInput.GBA_B][I_T_JUST_PRESSED]:
		player.set_action(Constants.ActionType.BREAK)

func reset_player_current_action():
	# process CURRENT_ACTION
	if player.get_current_action() == Constants.UnitCurrentAction.JUMPING:
		if input_table[Constants.PlayerInput.GBA_A][I_T_JUST_RELEASED]:
			player.set_current_action(Constants.UnitCurrentAction.IDLE)
	# process MOVING_STATUS
	if not player.actions[Constants.ActionType.MOVE] and not player.actions[Constants.ActionType.DASH]:
		player.set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.IDLE)
