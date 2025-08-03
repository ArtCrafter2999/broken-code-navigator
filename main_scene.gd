extends Control

@export var characters: Array[Character] = []

@onready var backgrounds_container: Control = $Backgrounds
@onready var background: TextureRect = $Backgrounds/Background

const TEST_DIALOGUE = preload("res://dialogues/test dialogue.dialogue")
const BALLOON = preload("res://balloon/balloon.tscn")

var characters_dict: Dictionary[String, Character] = {}
var ballon: Balloon

func _ready() -> void:
	for character in characters:
		characters_dict[character.name] = character;
	DialogueManager.got_dialogue.connect(_got_dialogue)
	
	ballon = DialogueManager.show_dialogue_balloon_scene(BALLOON, TEST_DIALOGUE, "start", [self])
	
func set_background(name: String, fade_in: float = 0, fade_out: float = 0):
	var new_background = TextureRect.new();
	new_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_background.texture = load("res://backgrounds/%s.png" % name)
	backgrounds_container.add_child(new_background)
	if fade_out:
		var tween = get_tree().create_tween()
		tween.tween_property(background, "modulate", Color.TRANSPARENT, fade_out)
		await tween.finished;
	if fade_in:
		new_background.modulate = Color.TRANSPARENT
		var tween = get_tree().create_tween()
		tween.tween_property(new_background, "modulate", Color.WHITE, fade_in)
		await tween.finished;
	background.queue_free()
	background = new_background;

func _got_dialogue(line: DialogueLine):
	if characters_dict.has(line.character):
		var character = characters_dict[line.character]
		ballon.character_label.modulate = character.color;
	else:
		ballon.character_label.modulate = Color.WHITE;
