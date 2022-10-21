enum UnitType {
	PLAYER,
}

enum ActionType {
	JUMP,
	MOVE,
	DASH,
	BREAK,
}

enum UnitCondition {
	CURRENT_ACTION,
	IS_ON_GROUND,
	MOVING_STATUS,
}

enum UnitCurrentAction {
	IDLE,
	JUMPING,
}

enum UnitMovingStatus {
	IDLE,
	MOVING,
	DASHING,
}

enum PlayerInput {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	GBA_A,
	GBA_B,
	GBA_START,
	GBA_SELECT,
}

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

enum MapElemType {
	SQUARE,
	SLOPE_LEFT,
	SLOPE_RIGHT,
	SMALL_SLOPE_LEFT_1,
	SMALL_SLOPE_LEFT_2,
	SMALL_SLOPE_RIGHT_1,
	SMALL_SLOPE_RIGHT_2,
	LEDGE,
}

const UNIT_TYPE_ACTIONS = {
	UnitType.PLAYER: [
		ActionType.JUMP,
		ActionType.MOVE,
		ActionType.DASH,
		ActionType.BREAK,
	],
}

# in seconds
const ACTION_TIMERS = {
	UnitType.PLAYER: {
		ActionType.DASH: 0.25
	}
}

const UNIT_TYPE_CURRENT_ACTIONS = {
	UnitType.PLAYER: [
		UnitCurrentAction.IDLE,
		UnitCurrentAction.JUMPING,
	],
}

# default conditions
const UNIT_TYPE_CONDITIONS = {
	UnitType.PLAYER: {
		UnitCondition.CURRENT_ACTION: UnitCurrentAction.IDLE,
		UnitCondition.IS_ON_GROUND: false,
		UnitCondition.MOVING_STATUS: UnitMovingStatus.IDLE,
	},
}

# in seconds
const CURRENT_ACTION_TIMERS = {
	UnitType.PLAYER: {
		UnitCurrentAction.JUMPING: 0.4,
	}
}

# Position relative to player's origin, list of directions to check for collision
const ENV_COLLIDERS = {
	UnitType.PLAYER: [
		[Vector2(0, 1.5), [Direction.LEFT, Direction.UP, Direction.RIGHT]],
		[Vector2(0, .75), [Direction.LEFT, Direction.RIGHT]],
		[Vector2(0, 0), [Direction.LEFT, Direction.DOWN, Direction.RIGHT]],
	],
}

const INPUT_MAP = {
	PlayerInput.UP: "ui_up",
	PlayerInput.DOWN: "ui_down",
	PlayerInput.LEFT: "ui_left",
	PlayerInput.RIGHT: "ui_right",
	PlayerInput.GBA_A: "gba_a",
	PlayerInput.GBA_B: "gba_b",
	PlayerInput.GBA_START: "gba_start",
	PlayerInput.GBA_SELECT: "gba_select",
}

const TILE_SET_MAP_ELEMS = {
	"TestTileSet": {
		MapElemType.SQUARE: [0, 1, 2, 3, 4, 5, 6, 7, 8],
		MapElemType.SLOPE_LEFT: [15, 16],
		MapElemType.SLOPE_RIGHT: [17, 18],
		MapElemType.SMALL_SLOPE_LEFT_1: [9],
		MapElemType.SMALL_SLOPE_LEFT_2: [10, 11],
		MapElemType.SMALL_SLOPE_RIGHT_1: [12],
		MapElemType.SMALL_SLOPE_RIGHT_2: [13, 14],
		MapElemType.LEDGE: [19, 20, 21, 22],
	}
}

const UNIT_SPRITES = {
	# "Sprite class": [is animation?, [Node list]]
	UnitType.PLAYER: {
		"Idle": [false, ["Idle"]],
		"Walk": [true, ["Walk"]],
		"Jump": [false, ["Jump1", "Jump2"]],
		"Dash": [true, ["Dash"]],
	}
}

const UNIT_TYPE_MOVE_SPEEDS = {
	UnitType.PLAYER: 6
}

const DASH_SPEED = 10

const UNIT_TYPE_JUMP_SPEEDS = {
	UnitType.PLAYER: 5
}

const SCALE_FACTOR = 3
const GRID_SIZE = 20 # pixels
const GRAVITY = 30
const MAX_FALL_SPEED = -12
const ACCELERATION = 35
const QUANTUM_DIST = 0.001
