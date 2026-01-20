extends ColorRect

var shader_material: ShaderMaterial: 
	get: return material

func _process(_delta: float) -> void:
	var rendering_method = ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method")
	if (rendering_method == "gl_compatibility"):
		modulate = Color.TRANSPARENT;
	else:
		shader_material.set_shader_parameter("noise", \
				GameState.get_setting(&"noise"))
		shader_material.set_shader_parameter("chromatic_abberation", \
				GameState.get_setting(&"chromatic_abberation"))
