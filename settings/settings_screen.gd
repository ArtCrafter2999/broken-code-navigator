class_name SettingsScreen;
extends Control

signal back_pressed;

@onready var window_button: RadioButton = %WindowButton
@onready var full_screen_button: RadioButton = %FullScreenButton
@onready var sfx_slider: LabeledSlider = %SfxSlider
@onready var music_slider: LabeledSlider = %MusicSlider
@onready var voice_slider: LabeledSlider = %VoiceSlider
@onready var text_size_slider: LabeledSlider = %TextSizeSlider
@onready var noise: CheckBox = %Noise
@onready var chromatic_abberation: CheckBox = %ChromaticAbberation

var opened = false;

func open():
	if opened: return;
	opened = true;
	full_screen_button.button_pressed = \
			GameState.get_setting(&"window_mode") == DisplayServer.WINDOW_MODE_FULLSCREEN;
	window_button.button_pressed = \
			GameState.get_setting(&"window_mode") == DisplayServer.WINDOW_MODE_WINDOWED;
	sfx_slider.set_value_no_signal(GameState.get_setting(&"sfx_volume"))
	music_slider.set_value_no_signal(GameState.get_setting(&"music_volume"))
	voice_slider.set_value_no_signal(GameState.get_setting(&"voice_volume"))
	text_size_slider.set_value_no_signal(GameState.get_setting(&"font_size"))
	noise.button_pressed = GameState.get_setting(&"noise")
	chromatic_abberation.button_pressed = GameState.get_setting(&"chromatic_abberation")
	show();
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT);
	
func close():
	if not opened: return;
	opened = false;
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
	print("hidden")
	hide();

func _on_window_button_pressed() -> void:
	GameState.set_setting(&"window_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	GameState.save();


func _on_full_screen_button_pressed() -> void:
	GameState.set_setting(&"window_mode", DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_noise_toggled(toggled_on: bool) -> void:
	GameState.set_setting(&"noise", toggled_on)


func _on_chromatic_abberation_toggled(toggled_on: bool) -> void:
	GameState.set_setting(&"chromatic_abberation", toggled_on)


func _on_sfx_slider_value_changed(value: float) -> void:
	GameState.set_setting(&"sfx_volume", value)


func _on_music_slider_value_changed(value: float) -> void:
	GameState.set_setting(&"music_volume", value)


func _on_voice_slider_value_changed(value: float) -> void:
	GameState.set_setting(&"voice_volume", value)

func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_text_size_slider_value_changed(value: float) -> void:
	GameState.set_setting(&"font_size", value)
