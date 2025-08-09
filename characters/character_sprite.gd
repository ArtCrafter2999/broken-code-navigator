class_name CharacterSprite
extends TextureRect

var variant: String;
var align: float
var talking: bool = false;
var holographic: bool = false;

func _ready():
	if not talking:
		self_modulate = PlayScene.DIM_CHARACTER_COLOR
		scale = PlayScene.DIM_CHARACTER_SCALE
