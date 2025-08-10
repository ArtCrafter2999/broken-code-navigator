class_name Credits
extends Control

signal credits_ended

const BALLOON = preload("res://balloon/balloon.tscn")
const LIBERTY_MESSAGE = preload("res://dialogues/liberty_message.dialogue")

var moving_speed: float = 100
var started = false
var moving = false;
var leaving = false;

@onready var v_box_container: VBoxContainer = $VBoxContainer

func start() -> void:
	show();
	v_box_container.position.y = 1090;
	modulate = Color.BLACK;
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 2)
	await tween.finished
	moving = true;
	
func quit():
	v_box_container.position.y = 1090;
	started = false
	moving = false;
	leaving = false;
	hide();

func _process(delta: float) -> void:
	if not moving: return;
	if v_box_container.position.y > -3000.0:
		v_box_container.position.y -= moving_speed * delta * \
				5 if Input.is_anything_pressed() else 1;
	elif not leaving:
		leaving = true;
		await get_tree().create_timer(1).timeout
		var balloon: Balloon = DialogueManager.show_dialogue_balloon_scene(BALLOON, LIBERTY_MESSAGE, "start")
		balloon.show_buttons = false;
		#await get_tree().process_frame
		await DialogueManager.dialogue_ended
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.BLACK, 2)
		await tween.finished
		credits_ended.emit();
