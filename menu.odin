package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Button :: struct {
	rect: rl.Rectangle,
	text: cstring,
}

button_draw :: proc(button: Button) {
	rl.DrawRectangleRec(button.rect, rl.GRAY)
	rl.DrawRectangleLinesEx(button.rect, 1, rl.WHITE)
	rl.DrawText(button.text, i32(button.rect.x) + 8, i32(button.rect.y) + 8, 40, rl.BLACK)
}

Slider :: struct {
	rect:        rl.Rectangle,
	button_down: Button,
	button_up:   Button,
	label:       cstring,
	value:       int,
	min_value:   int,
	max_value:   int,
}

slider_init :: proc(
	x: int,
	y: int,
	label: cstring,
	value: int,
	min_value: int,
	max_value: int,
) -> Slider {
	fx := f32(x)
	fy := f32(y)
	return {
		rect = {fx, fy, 500, 60},
		button_down = {rect = {fx, fy, 60, 60}, text = "<"},
		button_up = {rect = {fx + 440, fy, 60, 60}, text = ">"},
		label = label,
		value = value,
		min_value = min_value,
		max_value = max_value,
	}
}

slider_update :: proc(slider: ^Slider, mouse_pos: rl.Vector2) {
	if !point_in_rec(mouse_pos, slider.rect) {
		return
	}

	if point_in_rec(mouse_pos, slider.button_down.rect) {
		if slider.value > slider.min_value {
			slider.value -= 1
		}
	}

	if point_in_rec(mouse_pos, slider.button_up.rect) {
		if slider.value < slider.max_value {
			slider.value += 1
		}
	}
}

slider_draw :: proc(slider: Slider) {
	rl.DrawRectangleRec(slider.rect, rl.GRAY)
	rl.DrawText(slider.label, i32(slider.rect.x), i32(slider.rect.y) - 40, 40, rl.WHITE)
	button_draw(slider.button_down)
	button_draw(slider.button_up)
	text := fmt.ctprint(slider.value)
	rl.DrawText(text, i32(slider.rect.x) + 180, i32(slider.rect.y), 40, rl.WHITE)
}

Menu :: struct {
	sliders:      [3]Slider,
	button_play:  Button,
	play_pressed: bool,
}

menu_write_config :: proc(menu: Menu, config: ^Config) {
	config.grid_width = menu.sliders[0].value
	config.grid_height = menu.sliders[1].value
	config.bomb_count = menu.sliders[2].value
}

menu_init :: proc(menu: ^Menu, config: Config) {
	menu.sliders = {
		slider_init(100, 80, "Grid Width", config.grid_width, 5, 20),
		slider_init(100, 200, "Grid Height", config.grid_height, 5, 20),
		slider_init(100, 320, "Bomb Count", config.bomb_count, 4, 40),
	}
	menu.button_play = {
		rect = {100, 500, 440, 60},
		text = "Play",
	}
	menu.play_pressed = false
}

menu_update :: proc(menu: ^Menu) {
	mouse_pos := rl.GetMousePosition()
	mouse_pressed := rl.IsMouseButtonPressed(.LEFT)

	if !mouse_pressed {
		return
	}

	for &slider in menu.sliders {
		slider_update(&slider, mouse_pos)
	}

	if point_in_rec(mouse_pos, menu.button_play.rect) {
		menu.play_pressed = true
	}
}

menu_draw :: proc(menu: Menu) {
	rl.ClearBackground(rl.BLACK)

	for slider in menu.sliders {
		slider_draw(slider)
	}

	button_draw(menu.button_play)
}
