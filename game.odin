package main

import rl "vendor:raylib"

GameOutcome :: enum {
	PLAYING,
	LOST,
	WON,
	FINISHED,
}

Game :: struct {
	camera:    rl.Camera2D,
	outcome:   GameOutcome,
	grid:      Grid,
	mouse_pos: rl.Vector2,
}

game_resize :: proc(game: ^Game) {
	screen_size := rl.Vector2{f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
	design_size := rl.Vector2{f32(game.grid.width * S), f32(game.grid.height * S + 8)}
	screen_aspect := screen_size.x / screen_size.y
	design_aspect := design_size.x / design_size.y
	if screen_aspect > design_aspect {
		game.camera.zoom = screen_size.y / design_size.y
	} else {
		game.camera.zoom = screen_size.x / design_size.x
	}
}

hit_bomb :: proc(game: ^Game) {
	grid_reveal_bombs(&game.grid)
	game.outcome = .LOST
}

game_create :: proc(config: Config) -> Game {
	return {
		outcome = .PLAYING,
		grid = grid_create(config.grid_width, config.grid_height, config.bomb_count),
		camera = {zoom = 1},
	}
}

game_free :: proc(game: ^Game) {
	grid_free(&game.grid)
}

game_update :: proc(game: ^Game) {
	if rl.IsWindowResized() {
		game_resize(game)
	}

	btn_left := rl.IsMouseButtonPressed(.LEFT)
	btn_right := rl.IsMouseButtonPressed(.RIGHT)

	mouse_pos := rl.GetScreenToWorld2D(rl.GetMousePosition(), game.camera)
	game.mouse_pos = mouse_pos

	if !(btn_left || btn_right) {
		return
	}

	if game.outcome != .PLAYING {
		if btn_left {
			game.outcome = .FINISHED
		}
		return
	}

	x := int(mouse_pos.x) / S
	y := int(mouse_pos.y) / S

	cell := grid_get_cell(&game.grid, x, y)
	if cell == nil {
		return
	}

	if btn_left {
		if cell.bomb {
			hit_bomb(game)
		} else {
			grid_reveal(&game.grid, x, y)
		}
	} else if btn_right {
		cell_toggle_flag(cell)
	}

	if grid_is_win(&game.grid) {
		game.outcome = .WON
	}
}

game_draw :: proc(game: ^Game) {
	rl.BeginMode2D(game.camera)
	grid_draw(&game.grid)
	rl.DrawCircleV(game.mouse_pos, 2, rl.GREEN)
	rl.EndMode2D()


	y := i32(rl.GetScreenHeight()) - 44
	if game.outcome == .WON {
		rl.DrawText("you have won", 8, y, 40, rl.RED)
	} else if game.outcome == .LOST {
		rl.DrawText("you have lost", 8, y, 40, rl.RED)
	}
}
