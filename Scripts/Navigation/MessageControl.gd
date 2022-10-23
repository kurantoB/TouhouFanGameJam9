extends Control

export var starting_sequence : String
var current_sequence : Control
var current_message : RichTextLabel
var sequence_num : int

var npc_control : String


# Called when the node enters the scene tree for the first time.
func _ready():
	if not starting_sequence.empty():
		start_sequence(starting_sequence)
	else:
		visible = false

func start_sequence(sequence_name):
	visible = true
	var scene = get_node_or_null("/root/Scene")
	if scene != null:
		scene.delta_factor = 0
	current_sequence = get_node("Control").get_node(sequence_name)
	current_sequence.visible = true
	sequence_num = 0
	show_message()
	if sequence_name == "Epilogue":
		var last_message : RichTextLabel = current_sequence.get_child(24)
		last_message.text = "Thanks for playing! You gathered " + str(Global.collected_phantoms) + " phantoms."

func show_message():
	if current_message != null:
		current_message.visible = false
	var children
	if current_sequence.name == "Yuyuko":
		current_sequence.get_node(npc_control).visible = true
		children = current_sequence.get_node(npc_control).get_children()
	else:
		children = current_sequence.get_children()
	if sequence_num == children.size():
		current_sequence.visible = false
		visible = false
		if current_sequence.name == "Yuyuko":
			current_sequence.get_node(npc_control).visible = false
		var scene = get_node_or_null("/root/Scene")
		if scene != null:
			scene.delta_factor = 1
		if get_tree().get_current_scene().get_name() == "Intro":
			get_tree().change_scene_to(Global.main_scene)
		return
	if current_sequence.name == "Yuyuko":
		current_message = current_sequence.get_node(npc_control).get_child(sequence_num)
	else:
		current_message = current_sequence.get_child(sequence_num)
	current_message.visible = true

func advance_message():
	sequence_num += 1
	show_message()

func _process(delta):
	if visible and Input.is_action_just_released("gba_a"):
		advance_message()
