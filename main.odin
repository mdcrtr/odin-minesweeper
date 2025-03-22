package main

import "core:os"
import "core:strconv"
import rl "vendor:raylib"

process_args :: proc() -> Conf {
    conf := Conf{
        screen_width = 1024,
        screen_height = 1024
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

main :: proc() {
    conf := process_args()
    rl.SetTraceLogLevel(.ERROR)
    rl.SetConfigFlags({rl.ConfigFlag.WINDOW_RESIZABLE})
    rl.InitWindow(i32(conf.screen_width), i32(conf.screen_height), "minesweeper")
    rl.SetTargetFPS(30)
    loadTexture("minesweeper.png")

    game := game_create(conf)
    game_init(&game)
    game_resize(&game)
    for !rl.WindowShouldClose() {
        game_update(&game)
        game_draw(&game)
    }

    game_free(&game)
    rl.CloseWindow()
}