package main

CellState :: enum {
    HIDDEN,
    REVEALED,
    FLAGGED
}

Cell :: struct {
    x: int,
    y: int,
    bomb_count: int,
    tile: int,
    state: CellState,
    bomb: bool,
}

cell_init :: proc(tile: int, x: int, y: int) -> Cell {
    return {
        x = x * S,
        y = y * S,
        tile = tile
    }
}

cell_toggle_flag :: proc(cell: ^Cell) {
    if cell.state == .HIDDEN {
        cell.state = .FLAGGED
        cell.tile = FLAG
    }
    else if cell.state == .FLAGGED {
        cell.state = .HIDDEN
        cell.tile = TILE
    }
}

cell_reveal :: proc(cell: ^Cell) {
    cell.state = .REVEALED
    if cell.bomb {
        cell.tile = BOMB
    }
    else if cell.bomb_count > 0 {
        cell.tile = 15 + cell.bomb_count
    }
    else {
        cell.tile = BACKGROUND
    }
}

cell_draw :: proc(cell: Cell) {
    spr(cell.tile, cell.x, cell.y)
}
