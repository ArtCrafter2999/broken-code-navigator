extends Node2D

const TEST_DIALOGUE = preload("res://dialogues/test dialogue.dialogue")
const BALLOON = preload("res://balloon/balloon.tscn")

func _ready() -> void:
	DialogueManager.show_dialogue_balloon_scene(BALLOON, TEST_DIALOGUE, "start", [self])
