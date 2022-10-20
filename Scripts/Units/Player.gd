extends Unit

# Player-specific code
class_name Player

var dash_facing : int


func execute_actions(delta):
	.execute_actions(delta)
	for action_num in Constants.UNIT_TYPE_ACTIONS[Constants.UnitType.PLAYER]:
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
	target_move_speed = Constants.DASH_SPEED
	if unit_conditions[Constants.UnitCondition.IS_ON_GROUND]:
		set_sprite("Dash")

func handle_input(delta):
	scene.handle_player_input()

func reset_current_action():
	scene.reset_player_current_action()
