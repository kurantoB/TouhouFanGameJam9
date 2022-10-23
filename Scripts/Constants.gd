enum UnitType {
	PLAYER,
	VENGEFUL_SPIRIT,
	YOUMU,
}

enum ActionType {
	JUMP,
	MOVE,
	DASH,
	BREAK,
	DRINK,
	RECOIL,
}

enum UnitCondition {
	CURRENT_ACTION,
	IS_ON_GROUND,
	MOVING_STATUS,
	IS_INVINCIBLE,
}

enum UnitCurrentAction {
	IDLE,
	JUMPING,
	BREAKING,
	DRINKING,
	RECOILING,
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
	C_KEY,
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
	HAZARD,
}

enum HIT_BOX_BOUND {
	UPPER_BOUND,
	LOWER_BOUND,
	LEFT_BOUND,
	RIGHT_BOUND,
}

enum EMOTION {
	JOY,
	WRATH,
	SORROW,
	PLEASURE,
}

const UNIT_TYPE_ACTIONS = {
	UnitType.PLAYER: [
		ActionType.JUMP,
		ActionType.MOVE,
		ActionType.DASH,
		ActionType.BREAK,
		ActionType.DRINK,
		ActionType.RECOIL,
	],
	UnitType.VENGEFUL_SPIRIT: [
		ActionType.JUMP,
		ActionType.MOVE,
	],
	UnitType.YOUMU: [
		ActionType.JUMP,
		ActionType.MOVE,
		ActionType.DASH,
	],
}

# in seconds
const ACTION_TIMERS = {
	UnitType.PLAYER: {
		ActionType.DASH: 0.25,
		ActionType.DRINK: 20,
	},
	UnitType.VENGEFUL_SPIRIT: {},
	UnitType.YOUMU: {},
}

const UNIT_TYPE_CURRENT_ACTIONS = {
	UnitType.PLAYER: [
		UnitCurrentAction.IDLE,
		UnitCurrentAction.JUMPING,
		UnitCurrentAction.BREAKING,
		UnitCurrentAction.DRINKING,
		UnitCurrentAction.RECOILING,
	],
	UnitType.VENGEFUL_SPIRIT: [
		UnitCurrentAction.IDLE,
		UnitCurrentAction.JUMPING,
	],
	UnitType.YOUMU: [
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
		UnitCondition.IS_INVINCIBLE: false,
	},
	UnitType.VENGEFUL_SPIRIT: {
		UnitCondition.CURRENT_ACTION: UnitCurrentAction.IDLE,
		UnitCondition.IS_ON_GROUND: false,
		UnitCondition.MOVING_STATUS: UnitMovingStatus.IDLE,
	},
	UnitType.YOUMU: {
		UnitCondition.CURRENT_ACTION: UnitCurrentAction.IDLE,
		UnitCondition.IS_ON_GROUND: false,
		UnitCondition.MOVING_STATUS: UnitMovingStatus.IDLE,
	},
}

# in seconds
const CURRENT_ACTION_TIMERS = {
	UnitType.PLAYER: {
		UnitCurrentAction.JUMPING: 0.4,
		UnitCurrentAction.BREAKING: 0.2,
		UnitCurrentAction.DRINKING: 1,
		UnitCurrentAction.RECOILING: 0.67,
	},
	UnitType.VENGEFUL_SPIRIT: {
		UnitCurrentAction.JUMPING: 0.5,
	},
	UnitType.YOUMU: {
		UnitCurrentAction.JUMPING: 0.3,
	},
}

const UNIT_CONDITION_TIMERS = {
	# condition type: [duration, on value, off value]
	UnitType.PLAYER: {
		UnitCondition.IS_INVINCIBLE: [2.5, true, false],
	},
	UnitType.VENGEFUL_SPIRIT: {},
	UnitType.YOUMU: {},
}

# Position relative to player's origin, list of directions to check for collision
const ENV_COLLIDERS = {
	UnitType.PLAYER: [
		[Vector2(0, 1.2), [Direction.LEFT, Direction.UP, Direction.RIGHT]],
		[Vector2(-.25, .8), [Direction.LEFT]],
		[Vector2(.25, .8), [Direction.RIGHT]],
		[Vector2(-.25, .4), [Direction.LEFT]],
		[Vector2(.25, .4), [Direction.RIGHT]],
		[Vector2(0, 0), [Direction.LEFT, Direction.DOWN, Direction.RIGHT]],
	],
	UnitType.VENGEFUL_SPIRIT: [
		[Vector2(0, 1), [Direction.LEFT, Direction.UP, Direction.RIGHT]],
		[Vector2(-.25, .5), [Direction.LEFT]],
		[Vector2(.25, .5), [Direction.RIGHT]],
		[Vector2(0, 0), [Direction.LEFT, Direction.DOWN, Direction.RIGHT]],
	],
	UnitType.YOUMU: [
		[Vector2(0, 1.2), [Direction.LEFT, Direction.UP, Direction.RIGHT]],
		[Vector2(-.25, .8), [Direction.LEFT]],
		[Vector2(.25, .8), [Direction.RIGHT]],
		[Vector2(-.25, .4), [Direction.LEFT]],
		[Vector2(.25, .4), [Direction.RIGHT]],
		[Vector2(0, 0), [Direction.LEFT, Direction.DOWN, Direction.RIGHT]],
	],
}

const UNIT_HIT_BOXES = {
	UnitType.PLAYER: {
		HIT_BOX_BOUND.UPPER_BOUND: 1.2,
		HIT_BOX_BOUND.LOWER_BOUND: 0,
		HIT_BOX_BOUND.LEFT_BOUND: -0.33,
		HIT_BOX_BOUND.RIGHT_BOUND: 0.33,
	},
	UnitType.VENGEFUL_SPIRIT: {
		HIT_BOX_BOUND.UPPER_BOUND: 1,
		HIT_BOX_BOUND.LOWER_BOUND: 0,
		HIT_BOX_BOUND.LEFT_BOUND: -0.33,
		HIT_BOX_BOUND.RIGHT_BOUND: 0.33,
	},
	UnitType.YOUMU: {
		HIT_BOX_BOUND.UPPER_BOUND: 1.2,
		HIT_BOX_BOUND.LOWER_BOUND: 0,
		HIT_BOX_BOUND.LEFT_BOUND: -0.33,
		HIT_BOX_BOUND.RIGHT_BOUND: 0.33,
	},
}

const INPUT_MAP = {
	PlayerInput.UP: "ui_up",
	PlayerInput.DOWN: "ui_down",
	PlayerInput.LEFT: "ui_left",
	PlayerInput.RIGHT: "ui_right",
	PlayerInput.GBA_A: "gba_a",
	PlayerInput.GBA_B: "gba_b",
	PlayerInput.C_KEY: "c_key",
	PlayerInput.GBA_START: "gba_start",
	PlayerInput.GBA_SELECT: "gba_select",
}

const TILE_SET_MAP_ELEMS = {
	"Placeholder": {
		MapElemType.SQUARE: [0],
		MapElemType.SLOPE_LEFT: [5],
		MapElemType.SLOPE_RIGHT: [6],
		MapElemType.SMALL_SLOPE_LEFT_1: [1],
		MapElemType.SMALL_SLOPE_LEFT_2: [2],
		MapElemType.SMALL_SLOPE_RIGHT_1: [4],
		MapElemType.SMALL_SLOPE_RIGHT_2: [3],
		MapElemType.LEDGE: [7],
		MapElemType.HAZARD: [8, 9, 10, 11],
	}
}

# To use for determining bounce-back direction
const TILE_SET_HAZARD_REF_X = {
	"Placeholder": {
		8: -1,
		9: -1,
		10: Direction.RIGHT,
		11: Direction.LEFT,
	}
}

const UNIT_SPRITES = {
	# "Sprite class": [is animation?, [Node list]]
	UnitType.PLAYER: {
		"Idle": [true, ["Idle"]],
		"Walk": [true, ["Walk"]],
		"Jump": [false, ["Jump1", "Jump2"]],
		"Dash": [true, ["Dash"]],
		"Break": [true, ["Break"]],
		"Drink": [true, ["Drink"]],
		"Recoil": [false, ["Recoil"]],
	},
	UnitType.VENGEFUL_SPIRIT: {
		"Idle": [true, ["Idle"]],
		"Walk": [true, ["Idle"]],
		"Jump": [true, ["Idle", "Idle"]],
	},
	UnitType.YOUMU: {
		"Idle": [false, ["Idle"]],
		"Walk": [true, ["Walk"]],
		"Jump": [false, ["Jump", "Jump"]],
		"Dash": [true, ["Dash"]],
	},
}

const UNIT_TYPE_MOVE_SPEEDS = {
	UnitType.PLAYER: 6,
	UnitType.VENGEFUL_SPIRIT: 3,
	UnitType.YOUMU: 5,
}

const UNIT_TYPE_DASH_SPEEDS = {
	UnitType.PLAYER: 10,
	UnitType.VENGEFUL_SPIRIT: 0,
	UnitType.YOUMU: 9,
}

const UNIT_TYPE_JUMP_SPEEDS = {
	UnitType.PLAYER: 5,
	UnitType.VENGEFUL_SPIRIT: 5,
	UnitType.YOUMU: 5,
}

const SCALE_FACTOR = 3
const GRID_SIZE = 20 # pixels
const GRAVITY = 30
const MAX_FALL_SPEED = -12
const ACCELERATION = 35
const RECOIL_PUSHBACK = 10
const QUANTUM_DIST = 0.001

# Cosmetics
const FLASH_CYCLE = 0.25

# Misc
const PHANTOM_SPAWN_COOLDOWN = 40
