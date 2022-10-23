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
const GreenWallFrag1 = preload("res://Objects/GreenWallFrag1.tscn")
const GreenWallFrag2 = preload("res://Objects/GreenWallFrag2.tscn")
const RedWallFrag1 = preload("res://Objects/RedWallFrag1.tscn")
const RedWallFrag2 = preload("res://Objects/RedWallFrag2.tscn")

const UI0 = preload("res://Graphics/UI/0.png")
const UI1 = preload("res://Graphics/UI/1.png")
const UI2 = preload("res://Graphics/UI/2.png")
const UI3 = preload("res://Graphics/UI/3.png")
const UI4 = preload("res://Graphics/UI/4.png")
const UI5 = preload("res://Graphics/UI/5.png")
const UI6 = preload("res://Graphics/UI/6.png")
const UI7 = preload("res://Graphics/UI/7.png")
const UI8 = preload("res://Graphics/UI/8.png")
const UI9 = preload("res://Graphics/UI/9.png")
const UI_NUMERICAL_RESOURCES = [UI0, UI1, UI2, UI3, UI4, UI5, UI6, UI7, UI8, UI9]

var rng = RandomNumberGenerator.new()

var units = []
var player : Player
var player_cam : Camera2D
var phantoms = []
var wall_frags = []
var wall_frags_speeds = []

var npc_data = [] # grid_x, grid_y, npc_name, done

# [pressed?, just pressed?, just released?]
var input_table = {
	Constants.PlayerInput.UP: [false, false, false],
	Constants.PlayerInput.DOWN: [false, false, false],
	Constants.PlayerInput.LEFT: [false, false, false],
	Constants.PlayerInput.RIGHT: [false, false, false],
	Constants.PlayerInput.GBA_A: [false, false, false],
	Constants.PlayerInput.GBA_B: [false, false, false],
	Constants.PlayerInput.C_KEY: [false, false, false],
	Constants.PlayerInput.GBA_SELECT: [false, false, false],
}
const I_T_PRESSED : int = 0
const I_T_JUST_PRESSED : int = 1
const I_T_JUST_RELEASED : int = 2

var stage_env
var time_elapsed : float = 0
const TIME_LIMIT_SECONDS = 200

var delta_factor = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	units.append(get_node("Player"))
	player = units[0]
	player.init_unit_w_scene(self)
	player_cam = player.get_node("Camera2D")
	player_cam.make_current()
	
	var youmu = get_node("Youmu")
	units.append(youmu)
	youmu.init_unit_w_scene(self)
	youmu.init(player)
	
	for vengeful_spirit in get_node("VengefulSpirits").get_children():
		units.append(vengeful_spirit)
		vengeful_spirit.init_unit_w_scene(self)
		vengeful_spirit.init(player)
	
	stage_env = load("res://Scripts/StageEnvironment.gd").new(self)
	player.get_node("Camera2D").make_current()
	
	for phantom in get_node("Phantoms").get_children():
		phantom.init_w_player(player)
	
	for npc in get_node("NPCs").get_children():
		npc.position.x = npc.position.x * Constants.SCALE_FACTOR
		npc.position.y = npc.position.y * Constants.SCALE_FACTOR
		npc.scale.x = Constants.SCALE_FACTOR
		npc.scale.y = Constants.SCALE_FACTOR
		npc_data.append([npc.position.x / Constants.GRID_SIZE / Constants.SCALE_FACTOR, npc.position.y / Constants.GRID_SIZE / Constants.SCALE_FACTOR, npc.name, false])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	delta *= delta_factor
	for unit in units:
		unit.hit_check()
		unit.reset_actions()
		unit.handle_input(delta)
		unit.reset_current_action()
		unit.process_unit(delta, time_elapsed)
		stage_env.interact(unit, delta)
		unit.react(delta)
		stage_env.interact_post(unit)
	time_elapsed = time_elapsed + delta
	
	# visual effects
	if (player.facing == Constants.Direction.RIGHT):
		player_cam.offset_h = 1
	else:
		player_cam.offset_h = -1
	
	process_wall_frags(delta)
	process_ui()
	process_npcs()
	if time_elapsed >= TIME_LIMIT_SECONDS:
		Global.collected_phantoms = player.phantom_count
		get_tree().change_scene_to(Global.epilogue_scene)
		return
	
	if Input.is_action_just_released("gba_l"):
		for npc_datum in npc_data:
			if abs(npc_datum[0] - player.pos.x) < 1 and abs(npc_datum[1] - player.pos.y) < 1:
				if npc_datum[3]:
					get_node("CanvasLayer/HUD/MessageBox").npc_control = "AlreadyGiven"
				else:
					if player.levels[Constants.EMOTION.PLEASURE] < 2:
						get_node("CanvasLayer/HUD/MessageBox").npc_control = "NotEnoughPleasure"
					else:
						get_node("CanvasLayer/HUD/MessageBox").npc_control = "EnoughPleasure"
						npc_datum[3] = true
						for i in range(20):
							player.gain_phantom(Constants.EMOTION.JOY)
				get_node("CanvasLayer/HUD/MessageBox").start_sequence(npc_datum[2])

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
				
	# early exit
	if (player.get_current_action() == Constants.UnitCurrentAction.RECOILING
	or player.get_current_action() == Constants.UnitCurrentAction.BREAKING
	or player.get_current_action() == Constants.UnitCurrentAction.DRINKING):
		return
	
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
	
	if input_table[Constants.PlayerInput.C_KEY][I_T_JUST_PRESSED]:
		player.set_action(Constants.ActionType.BREAK)
	
	if input_table[Constants.PlayerInput.GBA_B][I_T_JUST_PRESSED]:
		player.do_with_timeout(Constants.ActionType.DRINK)

func reset_player_current_action():
	# process CURRENT_ACTION
	if player.get_current_action() == Constants.UnitCurrentAction.JUMPING:
		if input_table[Constants.PlayerInput.GBA_A][I_T_JUST_RELEASED]:
			player.set_current_action(Constants.UnitCurrentAction.IDLE)
	# process MOVING_STATUS
	if not player.actions[Constants.ActionType.MOVE] and not player.actions[Constants.ActionType.DASH]:
		player.set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.IDLE)

func wall_broken(grid_x, grid_y, break_class):
	var frag1
	var frag2
	if break_class == 1:
		frag1 = GreenWallFrag1.instance()
		frag2 = GreenWallFrag2.instance()
	else:
		frag1 = RedWallFrag1.instance()
		frag2 = RedWallFrag2.instance()
	get_node("WallFrags").add_child(frag1)
	get_node("WallFrags").add_child(frag2)
	wall_frags.append(frag1)
	wall_frags.append(frag2)
	frag1.scale.x = Constants.SCALE_FACTOR
	frag1.scale.y = Constants.SCALE_FACTOR
	frag2.scale.x = Constants.SCALE_FACTOR
	frag2.scale.y = Constants.SCALE_FACTOR
	frag1.set_modulate(Color(1, 1, 1, 0.67))
	frag2.set_modulate(Color(1, 1, 1, 0.67))
	frag1.position.x = grid_x * Constants.GRID_SIZE * Constants.SCALE_FACTOR
	frag1.position.y = -grid_y * Constants.GRID_SIZE * Constants.SCALE_FACTOR
	frag2.position.x = grid_x * Constants.GRID_SIZE * Constants.SCALE_FACTOR
	frag2.position.y = -grid_y * Constants.GRID_SIZE * Constants.SCALE_FACTOR
	wall_frags_speeds.append(Vector2(-3, 0))
	wall_frags_speeds.append(Vector2(3, 0))

func process_wall_frags(delta):
	var wall_frag_indices_to_remove = []
	for wall_frag_index in range(wall_frags.size()):
		var wall_frag = wall_frags[wall_frag_index]
		var wall_frag_pos : Vector2 = Vector2(wall_frag.position.x / Constants.GRID_SIZE / Constants.SCALE_FACTOR, -wall_frag.position.y / Constants.GRID_SIZE / Constants.SCALE_FACTOR)
		wall_frag_pos += wall_frags_speeds[wall_frag_index] * delta
		wall_frag.position.x = wall_frag_pos.x * Constants.GRID_SIZE * Constants.SCALE_FACTOR
		wall_frag.position.y = -wall_frag_pos.y * Constants.GRID_SIZE * Constants.SCALE_FACTOR
		if wall_frag_pos.y < -1:
			wall_frag_indices_to_remove.append(wall_frag_index)
		wall_frags_speeds[wall_frag_index].y -= Constants.GRAVITY * delta
	var new_wall_frags = []
	var new_wall_frags_speeds = []
	for wall_frag_index in range(wall_frags.size()):
		if not wall_frag_indices_to_remove.has(wall_frag_index):
			new_wall_frags.append(wall_frags[wall_frag_index])
			new_wall_frags_speeds.append(wall_frags_speeds[wall_frag_index])
	for remove_index in wall_frag_indices_to_remove:
		var wall_frag = wall_frags[remove_index]
		wall_frag.queue_free()
	wall_frags = new_wall_frags
	wall_frags_speeds = new_wall_frags_speeds

func process_ui():
	var emotion_index = int(floor(time_elapsed / 2)) % 4
	var vbox_container = get_node("CanvasLayer/HUD/VBoxContainer")
	for child in vbox_container.get_children():
		child.visible = false
		if emotion_index == Constants.EMOTION.JOY and child.name == "JoyMeterControl":
			child.visible = true
			process_meter_control(child, emotion_index)
		elif emotion_index == Constants.EMOTION.WRATH and child.name == "WrathMeterControl":
			child.visible = true
			process_meter_control(child, emotion_index)
		elif emotion_index == Constants.EMOTION.SORROW and child.name == "SorrowMeterControl":
			child.visible = true
			process_meter_control(child, emotion_index)
		elif emotion_index == Constants.EMOTION.PLEASURE and child.name == "PleasureMeterControl":
			child.visible = true
			process_meter_control(child, emotion_index)
	process_drink_ui()
	process_time_remaining_ui()

func process_meter_control(child, emotion):
	var level = player.levels[emotion]
	for a_child in child.get_children():
		if a_child.name.find("Level", 0) == 0:
			a_child.visible = false
		if level == 0 and a_child.name == "Level0":
			a_child.visible = true
		elif level == 1 and a_child.name == "Level1":
			a_child.visible = true
		elif level == 2 and a_child.name == "Level2":
			a_child.visible = true
	var collected = child.get_node("Collected")
	var collected_amount = player.phantom_inventory[emotion]
	var h_p = int(floor((collected_amount % 1000) / 100))
	var t_p = int(floor((collected_amount % 100) / 10))
	var o_p = collected_amount % 10
	var h_p_t_c : TextureRect = collected.get_node("HundredsPlace")
	var t_p_t_c : TextureRect = collected.get_node("TensPlace")
	var o_p_t_c : TextureRect = collected.get_node("OnesPlace")
	h_p_t_c.texture = UI_NUMERICAL_RESOURCES[h_p]
	t_p_t_c.texture = UI_NUMERICAL_RESOURCES[t_p]
	o_p_t_c.texture = UI_NUMERICAL_RESOURCES[o_p]

func process_drink_ui():
	var drink_eta_t_p = int(floor(player.timer_actions[Constants.ActionType.DRINK] / 10))
	var drink_eta_o_p = int(floor(player.timer_actions[Constants.ActionType.DRINK])) % 10
	var drink_control = get_node("CanvasLayer/HUD/Drink")
	drink_control.get_node("TensPlace").texture = UI_NUMERICAL_RESOURCES[drink_eta_t_p]
	drink_control.get_node("OnesPlace").texture = UI_NUMERICAL_RESOURCES[drink_eta_o_p]

func process_time_remaining_ui():
	var time_minute = get_node("CanvasLayer/HUD/TimeMinute")
	var time_ten_sec = get_node("CanvasLayer/HUD/TimeTenSec")
	var time_sec = get_node("CanvasLayer/HUD/TimeSec")
	var time_remaining = TIME_LIMIT_SECONDS - time_elapsed
	var time_remaining_minutes = int(floor(time_remaining / 60))
	var time_remaining_ten_secs = int(floor((int(floor(time_remaining)) % 60) / 10))
	var time_remaining_secs = int(floor(time_remaining)) % 60 % 10
	time_minute.texture = UI_NUMERICAL_RESOURCES[time_remaining_minutes]
	time_ten_sec.texture = UI_NUMERICAL_RESOURCES[time_remaining_ten_secs]
	time_sec.texture = UI_NUMERICAL_RESOURCES[time_remaining_secs]

func process_npcs():
	pass
