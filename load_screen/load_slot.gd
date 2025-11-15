class_name LoadSlot
extends BaseButton

signal context_menu_open
signal on_delete
signal on_rename

@onready var audio_click: AudioStreamPlayer = $AudioClick
@onready var audio_hover: AudioStreamPlayer = $AudioHover

@onready var outline: TextureRect = $CenterContainer/Outline
@onready var hover_outline: TextureRect = $CenterContainer/HoverOutline
@onready var pressed_outline: TextureRect = $CenterContainer/PressedOutline

@onready var screen: TextureRect = %Screen

@onready var context_menu: Panel = $ContextMenu

var image: Image;

var file_name: String;

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			context_menu_open.emit()
			context_menu.visible = true
			context_menu.position = event.position
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and \
				context_menu.visible:
			context_menu.visible = false;
			get_viewport().set_input_as_handled()

func _ready() -> void:
	mouse_entered.connect(func (): 
		if disabled: return;
		audio_hover.play()
		fade_in(hover_outline, 0.3))
	mouse_exited.connect(func (): 
		if disabled: return;
		fade_out(hover_outline, 0.3))
	button_down.connect(func ():
		if disabled: return;
		audio_click.play()
		fade_in(pressed_outline, 0.3))
	button_up.connect(func ():
		if disabled: return;
		fade_out(pressed_outline, 0.3))

func _process(delta: float) -> void:
	#mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
	if not screen.texture:
		screen.texture = ImageTexture.new();
	
	(screen.texture as ImageTexture).set_image(image)

func fade_in(texture: Control, time: float):
	if not texture: return;
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.WHITE, time).from(Color.TRANSPARENT)
	
func fade_out(texture: Control, time: float):
	if not texture: return;
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.TRANSPARENT, time).from(Color.WHITE)

func to_black(texture: Control, time: float):
	if not texture: return;
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.BLACK, time)
	
func to_white(texture: Control, time: float):
	if not texture: return;
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.WHITE, time)


func _on_rename_pressed() -> void:
	on_rename.emit()


func _on_delete_pressed() -> void:
	on_delete.emit()
