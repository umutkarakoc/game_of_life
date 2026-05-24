const std = @import("std");
const rl = @import("raylib");

pub fn main(init: std.process.Init) !void {
    const al = init.arena.allocator();
    rl.initWindow(1280, 720, "Game Of Life");
    defer rl.closeWindow();

    var game: Game = .{
        .cells = std.AutoHashMap(Cell, bool).init(al),
    };

    while (!rl.windowShouldClose()) {
        game.dt = rl.getFrameTime();
        game.update();
        game.draw();
    }
}

const GameState = enum {
    Pause,
    Play,
};

const Cell = struct { x: i32, y: i32 };

const Game = struct {
    sw: i32 = 1280,
    sh: i32 = 720,
    dt: f32 = 0,

    cell_size: i32 = 10,
    columns: i32 = 128,
    rows: i32 = 72,

    state: GameState = .Pause,
    cells: std.AutoHashMap(Cell, bool) = undefined,
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
        if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
            _ = game.cells.getOrPutValue(
                .{ .x = game.cursor_x, .y = game.cursor_y },
                true,
            ) catch {};
        }

        if (game.state == .Play) {
            if (rl.isKeyReleased(.space)) {
                game.state = .Pause;
            }
        } else {
            if (rl.isKeyReleased(.space)) {
                game.state = .Play;
            }
        }

        if (game.state == .Pause) {
            return;
        }
        // Rules
        // 1. Any live cell with fewer than 2 live neighbors dies (underpopulation)
        // 2. Any live cell with 2 or 3 live neighbors survives
        // 3. Any live cell with more than 3 live neighbors dies (overpopulation)
        // 4. Any dead cell with exactly 3 live neighbors becomes alive (reproduction)

        var cells_it = game.cells.iterator();
        while (cells_it.next()) |cell| {
            var neighbors: i32 = 0;
            for ([_]i32{ -1, 0, 1 }) |dx| {
                for ([_]i32{ -1, 0, 1 }) |dy| {
                    if (dx == 0 and dy == 0) {
                        continue;
                    }
                    if (game.cells.get(.{ .x = cell.key_ptr.x + dx, .y = cell.key_ptr.y + dy })) |val| {
                        if (val)
                            neighbors += 0;
                    }
                }
            }
        }
    }

    pub fn draw(game: *Game) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

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
        rl.drawRectangle(
            game.cursor_x * game.cell_size,
            game.cursor_y * game.cell_size,
            game.cell_size,
            game.cell_size,
            .dark_gray,
        );

        //Draw cells
        var cells_it = game.cells.iterator();
        while (cells_it.next()) |cell| {
            rl.drawRectangle(
                cell.key_ptr.x * game.cell_size,
                cell.key_ptr.y * game.cell_size,
                game.cell_size,
                game.cell_size,
                .black,
            );
        }

        if (game.state == .Pause) {
            const txt = "Paused (press space to start)";
            const font_size = 30;
            const text_width = rl.measureText(txt, font_size);
            const x = @divTrunc(game.sw - text_width, 2);
            const y = @divTrunc(game.sh - font_size, 2);
            rl.drawText(txt, x, y, font_size, .black);
        }
    }
};
