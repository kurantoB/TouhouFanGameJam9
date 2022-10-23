extends NPCUnit


func before_tick():
	if (abs(player.pos.x - pos.x)) < 3 or scene.rng.randf() < 0.67:
		facing = scene.Constants.Direction.LEFT if player.pos.x < pos.x else scene.Constants.Direction.RIGHT
	elif scene.rng.randf() < 0.5:
		facing = scene.Constants.Direction.LEFT
	else:
		facing = scene.Constants.Direction.RIGHT

func execute_actions(delta):
	.execute_actions(delta)
	for action_num in Constants.UNIT_TYPE_ACTIONS[unit_type]:
		if !actions[action_num]:
			continue
		match action_num:
			# handle custom actions
			Constants.ActionType.DASH:
				dash()
			_:
				pass

func dash():
	set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.DASHING)
	target_move_speed = Constants.UNIT_TYPE_DASH_SPEEDS[unit_type]
	if unit_conditions[Constants.UnitCondition.IS_ON_GROUND]:
		set_sprite("Dash")
