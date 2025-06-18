package main

import "core:os"
import "core:strconv"
import rl "vendor:raylib"

Config :: struct {
	screen_width:  int,
	screen_height: int,
	grid_width:    int,
	grid_height:   int,
	bomb_count:    int,
}

process_args :: proc() -> Config {
	conf := Config {
		screen_width  = 1024,
		screen_height = 1024,
		grid_width    = 10,
		grid_height   = 10,
		bomb_count    = 12,
	}
	if len(os.args) == 2 {
		value, ok := strconv.parse_int(os.args[1])
		if ok {
			conf.screen_width = value
			conf.screen_height = value
		}
	}
	return conf
}

SceneState :: enum {
	Menu,
	Game,
}

main :: proc() {
	conf := process_args()
	rl.SetTraceLogLevel(.ERROR)
	rl.SetConfigFlags({rl.ConfigFlag.WINDOW_RESIZABLE})
	rl.InitWindow(i32(conf.screen_width), i32(conf.screen_height), "minesweeper")
	rl.SetTargetFPS(30)
	loadTexture("minesweeper.png")

	scene_state := SceneState.Menu

	menu := menu_init(conf)
	game := game_create(conf)

	for !rl.WindowShouldClose() {
		switch scene_state {
		case .Menu:
			if menu.play_pressed {
				scene_state = .Game
				conf.grid_width = menu_get_grid_width(menu)
				conf.grid_height = menu_get_grid_height(menu)
				conf.bomb_count = menu_get_bomb_count(menu)
				game_free(&game)
				game = game_create(conf)
				game_resize(&game)
			} else {
				menu_update(&menu)
				rl.BeginDrawing()
				rl.ClearBackground(rl.BLACK)
				menu_draw(menu)
				rl.EndDrawing()
			}
		case .Game:
			if game.outcome == .FINISHED {
				scene_state = .Menu
				menu = menu_init(conf)
			} else {
				game_update(&game)
				rl.BeginDrawing()
				rl.ClearBackground(rl.BLACK)
				game_draw(&game)
				rl.EndDrawing()
			}
		}
		free_all(context.temp_allocator)
	}

	game_free(&game)
	rl.CloseWindow()
}
