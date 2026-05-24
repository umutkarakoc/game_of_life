const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    rl.initWindow(1280, 720, "Game Of Life");
    defer rl.closeWindow();

    var game: Game = .{};

    while (!rl.windowShouldClose()) {
        game.dt = rl.getFrameTime();
        game.update();
        game.draw();
    }
}

const GameState = enum { Idle, Play, Dead };

const Game = struct {
    sw: i32 = 1280,
    sh: i32 = 720,
    dt: f32 = 0,

    cell_size: i32 = 10,
    columns: i32 = 128,
    rows: i32 = 72,

    grid: [128][72]bool = [_][72]bool{[_]bool{false} ** 72} ** 128,
    cursor_x: i32 = 0,
    cursor_y: i32 = 0,
    create_cell_action: bool = false,

    pub fn update(game: *Game) void {
        var cursor_x: i32 = @divTrunc(rl.getMouseX(), game.cell_size);
        var cursor_y: i32 = @divTrunc(rl.getMouseY(), game.cell_size);

        if (cursor_x >= 128) {
            cursor_x = 127;
        }
        if (cursor_y >= 72) {
            cursor_y = 71;
        }
        if (cursor_x < 0) {
            cursor_x = 0;
        }
        if (cursor_y < 0) {
            cursor_y = 0;
        }

        game.cursor_x = @intCast(cursor_x);
        game.cursor_y = @intCast(cursor_y);
        game.create_cell_action = rl.isMouseButtonReleased(rl.MouseButton.left);
    }

    pub fn draw(game: *Game) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        const current = &game.grid[@intCast(game.cursor_x)][@intCast(game.cursor_y)];

        //create new cell if clicked
        if (game.create_cell_action) {
            if (!current.*) {
                current.* = true;
            }
        }

        //Draw Grid
        for (0..@intCast(game.columns)) |x| {
            const pos_x: i32 = @intCast(x);
            rl.drawLine(
                pos_x * game.cell_size,
                0,
                pos_x * game.cell_size,
                game.sh,
                .light_gray,
            );
        }
        for (0..@intCast(game.rows)) |y| {
            const pos_y: i32 = @intCast(y);
            rl.drawLine(
                0,
                pos_y * game.cell_size,
                game.sw,
                pos_y * game.cell_size,
                .light_gray,
            );
        }

        //Draw cell preview
        if (!current.*) {
            rl.drawRectangle(
                game.cursor_x * game.cell_size,
                game.cursor_y * game.cell_size,
                game.cell_size,
                game.cell_size,
                .dark_gray,
            );
        }

        //Draw cells
        for (0..@intCast(game.columns)) |x| {
            for (0..@intCast(game.rows)) |y| {
                if (game.grid[x][y]) {
                    const px: i32 = @intCast(x);
                    const py: i32 = @intCast(y);
                    rl.drawRectangle(
                        px * game.cell_size,
                        py * game.cell_size,
                        game.cell_size,
                        game.cell_size,
                        .black,
                    );
                }
            }
        }
    }
};
