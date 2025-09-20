extends ColorRect

var shader_material: ShaderMaterial: 
	get: return material

func _process(delta: float) -> void:
	shader_material.set_shader_parameter("noise", GameState.get_setting(&"noise"))
	shader_material.set_shader_parameter("chromatic_abberation", GameState.get_setting(&"chromatic_abberation"))
