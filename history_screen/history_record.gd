extends Control
class_name HistoryRecord

@onready var character_label: RichTextLabel = %CharacterLabel
@onready var dialogue_label: RichTextLabel = %DialogueLabel

var character: String;
var character_color: Color
var text: String;

func _ready() -> void:
	character_label.text = character;
	dialogue_label.text = text;
	character_label.modulate = character_color
