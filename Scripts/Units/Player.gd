extends Unit

# Player-specific code
class_name Player

const Phantom = preload("res://Objects/Phantom.tscn")

var dash_facing : int

var lost_phantoms = []
var lost_phantoms_speeds = []

var phantom_count = 0
var phantom_inventory = {
	Constants.EMOTION.JOY: 0,
	Constants.EMOTION.WRATH: 0,
	Constants.EMOTION.SORROW: 0,
	Constants.EMOTION.PLEASURE: 0,
}
var levels = {
	Constants.EMOTION.JOY: 0,
	Constants.EMOTION.WRATH: 0,
	Constants.EMOTION.SORROW: 0,
	Constants.EMOTION.PLEASURE: 0,
}
const LEVEL1_COUNT = 20
const LEVEL2_COUNT = 50


func gain_phantom(emotion : int):
	phantom_inventory[emotion] += 1
	phantom_count += 1
	refresh_levels();

func lose_phantoms():
	var loss = ceil(phantom_count / 4)
	for i in range(loss):
		var viable_emotions = []
		if phantom_inventory[Constants.EMOTION.JOY] > 0:
			viable_emotions.append(Constants.EMOTION.JOY)
		if phantom_inventory[Constants.EMOTION.WRATH] > 0:
			viable_emotions.append(Constants.EMOTION.WRATH)
		if phantom_inventory[Constants.EMOTION.SORROW] > 0:
			viable_emotions.append(Constants.EMOTION.SORROW)
		if phantom_inventory[Constants.EMOTION.PLEASURE] > 0:
			viable_emotions.append(Constants.EMOTION.PLEASURE)
		var rand_emotion = viable_emotions[scene.rng.randf_range(0.0, 0.99) * viable_emotions.size()]
		phantom_inventory[rand_emotion] -= 1
		refresh_levels()
		var spawned_loss_phantom = Phantom.instance()
		scene.get_node("LostPhantoms").add_child(spawned_loss_phantom)
		lost_phantoms.append(spawned_loss_phantom)
		spawned_loss_phantom.position = position
		spawned_loss_phantom.scale.x = Constants.SCALE_FACTOR
		spawned_loss_phantom.scale.y = Constants.SCALE_FACTOR
		var anim_child : AnimatedSprite
		for child in spawned_loss_phantom.get_children():
			child.visible = false
			if rand_emotion == Constants.EMOTION.JOY and child.name == "JoyAnim":
				child.visible = true
				anim_child = child
			elif rand_emotion == Constants.EMOTION.WRATH and child.name == "WrathAnim":
				child.visible = true
				anim_child = child
			elif rand_emotion == Constants.EMOTION.SORROW and child.name == "SorrowAnim":
				child.visible = true
				anim_child = child
			elif rand_emotion == Constants.EMOTION.PLEASURE and child.name == "PleasureAnim":
				child.visible = true
				anim_child = child
		anim_child.set_modulate(Color(1, 1, 1, 0.67))
		var angle : float = scene.rng.randf_range(0.0, 180.0)
		var max_speed = 10
		var actual_speed = scene.rng.randf_range(0.5, 1.0) * max_speed
		var x_comp = cos(angle) * actual_speed
		var y_comp = sin(angle) * actual_speed
		lost_phantoms_speeds.append(Vector2(x_comp, y_comp))
	phantom_count -= loss
	
func refresh_levels():
	for emotion in [Constants.EMOTION.JOY, Constants.EMOTION.WRATH, Constants.EMOTION.SORROW, Constants.EMOTION.PLEASURE]:
		if phantom_inventory[emotion] < LEVEL1_COUNT:
			levels[emotion] = 0
		elif phantom_inventory[emotion] < LEVEL2_COUNT:
			levels[emotion] = 1
		else:
			levels[emotion] = 2

func set_timer_action(action : int):
	.set_timer_action(action)
	if action == Constants.ActionType.DRINK:
		timer_actions[action] *= 1 - (0.1 * levels[Constants.EMOTION.SORROW])

func advance_timers(delta):
	.advance_timers(delta)
	if not unit_conditions[Constants.UnitCondition.IS_INVINCIBLE]:
		is_flash = false

# dir is which direction unit is taking an attack from: left / right
func hit(dir : int):
	if get_condition(Constants.UnitCondition.IS_INVINCIBLE, false):
		return
	set_action(Constants.ActionType.RECOIL)
	set_current_action(Constants.UnitCurrentAction.RECOILING)
	set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.IDLE)
	set_unit_condition_with_timer(Constants.UnitCondition.IS_INVINCIBLE)
	is_flash = true
	flash_start_timestamp = time_elapsed
	if get_condition(Constants.UnitCondition.IS_ON_GROUND, false):
		var temp_h_speed
		if h_speed > 0:
			if dir == Constants.Direction.LEFT:
				v_speed -= Constants.RECOIL_PUSHBACK
			else:
				v_speed += Constants.RECOIL_PUSHBACK
				if v_speed > 0:
					h_speed = -Constants.QUANTUM_DIST
					v_speed *= -1
		elif h_speed < 0:
			if dir == Constants.Direction.LEFT:
				v_speed += Constants.RECOIL_PUSHBACK
				if v_speed > 0:
					h_speed = Constants.QUANTUM_DIST
					v_speed *= -1
			else:
				v_speed -= Constants.RECOIL_PUSHBACK
		else: # h_speed == 0
			if dir == Constants.Direction.LEFT:
				h_speed = Constants.QUANTUM_DIST
			else:
				h_speed = -Constants.QUANTUM_DIST
			v_speed = -Constants.RECOIL_PUSHBACK
	else:
		if dir == Constants.Direction.LEFT:
			h_speed += Constants.RECOIL_PUSHBACK
		else:
			h_speed -= Constants.RECOIL_PUSHBACK
	facing = dir
	lose_phantoms()

func process_unit(delta, time_elapsed : float):
	.process_unit(delta, time_elapsed)
	# process lost_phantoms
	var lost_phantom_indices_to_remove = []
	for lost_phantom_index in range(lost_phantoms.size()):
		var lost_phantom = lost_phantoms[lost_phantom_index]
		var lost_phantom_pos : Vector2 = Vector2(lost_phantom.position.x / Constants.GRID_SIZE / Constants.SCALE_FACTOR, -lost_phantom.position.y / Constants.GRID_SIZE / Constants.SCALE_FACTOR)
		lost_phantom_pos += lost_phantoms_speeds[lost_phantom_index] * delta
		lost_phantom.position.x = lost_phantom_pos.x * Constants.GRID_SIZE * Constants.SCALE_FACTOR
		lost_phantom.position.y = -lost_phantom_pos.y * Constants.GRID_SIZE * Constants.SCALE_FACTOR
		if lost_phantom_pos.y < pos.y - 5:
			lost_phantom_indices_to_remove.append(lost_phantom_index)
		lost_phantoms_speeds[lost_phantom_index].y -= Constants.GRAVITY * delta
	var new_lost_phantoms = []
	var new_lost_phantoms_speeds = []
	for lost_phantom_index in range(lost_phantoms.size()):
		if not lost_phantom_indices_to_remove.has(lost_phantom_index):
			new_lost_phantoms.append(lost_phantoms[lost_phantom_index])
			new_lost_phantoms_speeds.append(lost_phantoms_speeds[lost_phantom_index])
	for remove_index in lost_phantom_indices_to_remove:
		var lost_phantom = lost_phantoms[remove_index]
		lost_phantom.queue_free()
	lost_phantoms = new_lost_phantoms
	lost_phantoms_speeds = new_lost_phantoms_speeds

func handle_input(delta):
	scene.handle_player_input()
	
func reset_actions():
	.reset_actions()
	if get_current_action() == Constants.UnitCurrentAction.RECOILING:
		set_action(Constants.ActionType.RECOIL)
	elif get_current_action() == Constants.UnitCurrentAction.BREAKING:
		if is_current_action_timer_done(Constants.UnitCurrentAction.BREAKING):
			set_current_action(Constants.UnitCurrentAction.IDLE)
	elif get_current_action() == Constants.UnitCurrentAction.DRINKING:
		if is_current_action_timer_done(Constants.UnitCurrentAction.DRINKING):
			set_current_action(Constants.UnitCurrentAction.IDLE)
			set_unit_condition_with_timer(Constants.UnitCondition.IS_INVINCIBLE)
			is_flash = true
			flash_start_timestamp = time_elapsed

func reset_current_action():
	scene.reset_player_current_action()

func hit_check():
	# check unit collision
	for other_unit in scene.units:
		if other_unit != self:
			var own_hit_box = scene.Constants.UNIT_HIT_BOXES[unit_type]
			var other_hit_box = scene.Constants.UNIT_HIT_BOXES[other_unit.unit_type]
			var hit_check_result : int = GameUtils.check_hitbox_collision(
				pos.y + own_hit_box[scene.Constants.HIT_BOX_BOUND.UPPER_BOUND],
				pos.y + own_hit_box[scene.Constants.HIT_BOX_BOUND.LOWER_BOUND],
				pos.x + own_hit_box[scene.Constants.HIT_BOX_BOUND.LEFT_BOUND],
				pos.x + own_hit_box[scene.Constants.HIT_BOX_BOUND.RIGHT_BOUND],
				other_unit.pos.y + other_hit_box[scene.Constants.HIT_BOX_BOUND.UPPER_BOUND],
				other_unit.pos.y + other_hit_box[scene.Constants.HIT_BOX_BOUND.LOWER_BOUND],
				other_unit.pos.x + other_hit_box[scene.Constants.HIT_BOX_BOUND.LEFT_BOUND],
				other_unit.pos.x + other_hit_box[scene.Constants.HIT_BOX_BOUND.RIGHT_BOUND])
			if hit_check_result != -1:
				hit(hit_check_result)
				break

func execute_actions(delta):
	.execute_actions(delta)
	for action_num in Constants.UNIT_TYPE_ACTIONS[Constants.UnitType.PLAYER]:
		if !actions[action_num]:
			continue
		match action_num:
			# handle custom actions
			Constants.ActionType.DASH:
				dash()
			Constants.ActionType.BREAK:
				do_break()
			Constants.ActionType.DRINK:
				drink()
			Constants.ActionType.RECOIL:
				recoil()
			_:
				pass

func dash():
	set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.DASHING)
	target_move_speed = Constants.UNIT_TYPE_DASH_SPEEDS[unit_type]
	target_move_speed *= 1 + (.1 * levels[Constants.EMOTION.JOY])
	if unit_conditions[Constants.UnitCondition.IS_ON_GROUND]:
		set_sprite("Dash")

func do_break():
	scene.stage_env.attempt_break(pos.x, pos.y, facing, levels[Constants.EMOTION.WRATH])
	set_current_action(Constants.UnitCurrentAction.BREAKING)
	set_sprite("Break")

func drink():
	set_current_action(Constants.UnitCurrentAction.DRINKING)
	set_sprite("Drink")

func recoil():
	if is_current_action_timer_done(Constants.UnitCurrentAction.RECOILING):
		set_current_action(Constants.UnitCurrentAction.IDLE)
	else:
		set_sprite("Recoil")

func move():
	.move()
	target_move_speed *= 1 + (.1 * levels[Constants.EMOTION.JOY])
