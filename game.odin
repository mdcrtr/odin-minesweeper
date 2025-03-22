package main

import rl "vendor:raylib"

W :: 16
H :: 16
B :: 16
OX :: 34
OY :: 34

GameOutcome :: enum {
    PLAYING,
    LOST,
    WON
}

Conf :: struct {
    screen_width: int,
    screen_height: int
}

Game :: struct {
    screen_width: int,
    screen_height: int,
    zoom: int,
    camera: rl.Camera2D,
    outcome: GameOutcome,
    grid: Grid
}

game_resize :: proc(game: ^Game) {
    game.screen_width = int(rl.GetScreenWidth())
    game.screen_height = int(rl.GetScreenHeight())
    size := min(game.screen_width, game.screen_height)
    game.zoom = size / 140
    game.camera.zoom = f32(game.zoom)
}

hit_bomb :: proc(game: ^Game) {
    grid_reveal_bombs(&game.grid)
    game.outcome = .LOST
}

game_create :: proc(conf: Conf) -> Game {    
    return {
        screen_width = conf.screen_width,
        screen_height = conf.screen_height,
        zoom = 1,
        outcome = .PLAYING,
        grid = grid_create(W, H),
        camera = {
            offset = {OX, OY},
            zoom = 1
        }
    }
}

game_free :: proc(game: ^Game) {
    grid_free(&game.grid)
}

game_init :: proc(game: ^Game) {
    grid_init(&game.grid, B)
    game.outcome = .PLAYING
}

game_update :: proc(game: ^Game) {
    if rl.IsWindowResized() {
        game_resize(game)
    }

    btn_left := rl.IsMouseButtonPressed(.LEFT)
    btn_right := rl.IsMouseButtonPressed(.RIGHT)

    if !(btn_left || btn_right) {
        return
    }

    if game.outcome != .PLAYING {
        if btn_left {
            game_init(game)
        }
        return
    }

    x := int(rl.GetMouseX() - OX) / int(game.camera.zoom) / S
    y := int(rl.GetMouseY() - OY) / int(game.camera.zoom) / S

    cell := grid_get_cell(&game.grid, x, y)
    if cell == nil {
        return
    }

    if btn_left {
        if cell.bomb {
            hit_bomb(game)
        }
        else {
            grid_reveal(&game.grid, x, y)
        }
    }
    else if btn_right {
        cell_toggle_flag(cell)
    }

    if grid_is_win(&game.grid) {
        game.outcome = .WON
    }
}

game_draw :: proc(game: ^Game) {
    rl.BeginDrawing()
    rl.BeginMode2D(game.camera)
    rl.ClearBackground(rl.BLACK)
    grid_draw(&game.grid)
    rl.EndMode2D()
    if game.outcome == .WON {
        rl.DrawText("you have won", 0, 0, 32, rl.RED)
    }
    else if game.outcome == .LOST {
        rl.DrawText("you have lost", 0, 0, 32, rl.RED)
    }
    rl.EndDrawing()
}