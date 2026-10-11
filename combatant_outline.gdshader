shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(0.85);

void fragment() {

	vec4 sprite = texture(TEXTURE, UV);
	
	// DAMAGE FLASH
	sprite.rgb = mix(sprite.rgb, flash_color.rgb, flash_amount);

	COLOR = sprite;
}