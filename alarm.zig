const std = @import("std");
const os = std.os;
const time = std.time;
const math = std.math;
const fmt = std.fmt;
const posix = std.posix;
const termios = posix.termios;

const Dot = struct { row: i32, col: i32 };

// Digit patterns converted to 0-based indices
const digitPatterns = [10][]const Dot{
    // 0
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 }, Dot{ .row = 0, .col = 4 },
        Dot{ .row = 1, .col = 0 }, Dot{ .row = 1, .col = 4 }, Dot{ .row = 2, .col = 0 }, Dot{ .row = 2, .col = 4 }, Dot{ .row = 3, .col = 0 },
        Dot{ .row = 3, .col = 4 }, Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 0 }, Dot{ .row = 5, .col = 4 },
        Dot{ .row = 6, .col = 0 }, Dot{ .row = 6, .col = 4 }, Dot{ .row = 7, .col = 0 }, Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 0 },
        Dot{ .row = 8, .col = 1 }, Dot{ .row = 8, .col = 2 }, Dot{ .row = 8, .col = 3 }, Dot{ .row = 8, .col = 4 },
    },
    // 1
    &.{
        Dot{ .row = 0, .col = 4 }, Dot{ .row = 1, .col = 4 }, Dot{ .row = 2, .col = 4 }, Dot{ .row = 3, .col = 4 }, Dot{ .row = 4, .col = 4 },
        Dot{ .row = 5, .col = 4 }, Dot{ .row = 6, .col = 4 }, Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 4 },
    },
    // 2
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 }, Dot{ .row = 0, .col = 4 },
        Dot{ .row = 1, .col = 4 }, Dot{ .row = 2, .col = 4 }, Dot{ .row = 3, .col = 4 }, Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 },
        Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 }, Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 0 }, Dot{ .row = 6, .col = 0 },
        Dot{ .row = 7, .col = 0 }, Dot{ .row = 8, .col = 0 }, Dot{ .row = 8, .col = 1 }, Dot{ .row = 8, .col = 2 }, Dot{ .row = 8, .col = 3 },
        Dot{ .row = 8, .col = 4 },
    },
    // 3
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 }, Dot{ .row = 0, .col = 4 },
        Dot{ .row = 1, .col = 4 }, Dot{ .row = 2, .col = 4 }, Dot{ .row = 3, .col = 4 }, Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 },
        Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 }, Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 4 }, Dot{ .row = 6, .col = 4 },
        Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 0 }, Dot{ .row = 8, .col = 1 }, Dot{ .row = 8, .col = 2 }, Dot{ .row = 8, .col = 3 },
        Dot{ .row = 8, .col = 4 },
    },
    // 4
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 4 }, Dot{ .row = 1, .col = 0 }, Dot{ .row = 1, .col = 4 }, Dot{ .row = 2, .col = 0 },
        Dot{ .row = 2, .col = 4 }, Dot{ .row = 3, .col = 0 }, Dot{ .row = 3, .col = 4 }, Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 },
        Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 }, Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 4 }, Dot{ .row = 6, .col = 4 },
        Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 4 },
    },
    // 5
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 }, Dot{ .row = 0, .col = 4 },
        Dot{ .row = 1, .col = 0 }, Dot{ .row = 2, .col = 0 }, Dot{ .row = 3, .col = 0 }, Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 },
        Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 }, Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 4 }, Dot{ .row = 6, .col = 4 },
        Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 0 }, Dot{ .row = 8, .col = 1 }, Dot{ .row = 8, .col = 2 }, Dot{ .row = 8, .col = 3 },
        Dot{ .row = 8, .col = 4 },
    },
    // 6
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 }, Dot{ .row = 0, .col = 4 },
        Dot{ .row = 1, .col = 0 }, Dot{ .row = 2, .col = 0 }, Dot{ .row = 3, .col = 0 }, Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 },
        Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 }, Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 0 }, Dot{ .row = 5, .col = 4 },
        Dot{ .row = 6, .col = 0 }, Dot{ .row = 6, .col = 4 }, Dot{ .row = 7, .col = 0 }, Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 0 },
        Dot{ .row = 8, .col = 1 }, Dot{ .row = 8, .col = 2 }, Dot{ .row = 8, .col = 3 }, Dot{ .row = 8, .col = 4 },
    },
    // 7
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 }, Dot{ .row = 0, .col = 4 },
        Dot{ .row = 1, .col = 4 }, Dot{ .row = 2, .col = 4 }, Dot{ .row = 3, .col = 4 }, Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 4 },
        Dot{ .row = 6, .col = 4 }, Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 4 },
    },
    // 8
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 }, Dot{ .row = 0, .col = 4 },
        Dot{ .row = 1, .col = 0 }, Dot{ .row = 1, .col = 4 }, Dot{ .row = 2, .col = 0 }, Dot{ .row = 2, .col = 4 }, Dot{ .row = 3, .col = 0 },
        Dot{ .row = 3, .col = 4 }, Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 }, Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 },
        Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 0 }, Dot{ .row = 5, .col = 4 }, Dot{ .row = 6, .col = 0 }, Dot{ .row = 6, .col = 4 },
        Dot{ .row = 7, .col = 0 }, Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 0 }, Dot{ .row = 8, .col = 1 }, Dot{ .row = 8, .col = 2 },
        Dot{ .row = 8, .col = 3 }, Dot{ .row = 8, .col = 4 },
    },
    // 9
    &.{
        Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 }, Dot{ .row = 0, .col = 4 },
        Dot{ .row = 1, .col = 0 }, Dot{ .row = 1, .col = 4 }, Dot{ .row = 2, .col = 0 }, Dot{ .row = 2, .col = 4 }, Dot{ .row = 3, .col = 0 },
        Dot{ .row = 3, .col = 4 }, Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 }, Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 },
        Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 4 }, Dot{ .row = 6, .col = 4 }, Dot{ .row = 7, .col = 4 }, Dot{ .row = 8, .col = 4 },
    },
};

const onOffPatterns = struct {
    const on = [2][]const Dot{
        digitPatterns[0],
        &.{
            Dot{ .row = 8, .col = 0 }, Dot{ .row = 7, .col = 0 }, Dot{ .row = 6, .col = 0 }, Dot{ .row = 5, .col = 0 },
            Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 }, Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 },
            Dot{ .row = 4, .col = 4 }, Dot{ .row = 5, .col = 4 }, Dot{ .row = 6, .col = 4 }, Dot{ .row = 7, .col = 4 },
            Dot{ .row = 8, .col = 4 },
        },
    };
    const off = [2][]const Dot{
        digitPatterns[0],
        &.{
            Dot{ .row = 8, .col = 0 }, Dot{ .row = 7, .col = 0 }, Dot{ .row = 6, .col = 0 }, Dot{ .row = 5, .col = 0 },
            Dot{ .row = 4, .col = 0 }, Dot{ .row = 4, .col = 1 }, Dot{ .row = 4, .col = 2 }, Dot{ .row = 4, .col = 3 },
            Dot{ .row = 4, .col = 4 }, Dot{ .row = 3, .col = 0 }, Dot{ .row = 2, .col = 0 }, Dot{ .row = 1, .col = 0 },
            Dot{ .row = 0, .col = 0 }, Dot{ .row = 0, .col = 1 }, Dot{ .row = 0, .col = 2 }, Dot{ .row = 0, .col = 3 },
            Dot{ .row = 0, .col = 4 },
        },
    };
};

const circle = &[_]Dot{
    .{ .row = 0, .col = 14 },
    .{ .row = 0, .col = 15 },
    .{ .row = 0, .col = 16 },
    .{ .row = 0, .col = 17 },
    .{ .row = 1, .col = 18 },
    .{ .row = 1, .col = 19 },
    .{ .row = 1, .col = 20 },
    .{ .row = 2, .col = 21 },
    .{ .row = 2, .col = 22 },
    .{ .row = 3, .col = 23 },
    .{ .row = 4, .col = 24 },
    .{ .row = 5, .col = 25 },
    .{ .row = 6, .col = 26 },
    .{ .row = 7, .col = 26 },
    .{ .row = 8, .col = 27 },
    .{ .row = 9, .col = 27 },
    .{ .row = 10, .col = 27 },
    .{ .row = 11, .col = 28 },
    .{ .row = 12, .col = 28 },
    .{ .row = 13, .col = 28 },
    .{ .row = 14, .col = 28 },
    .{ .row = 15, .col = 28 },
    .{ .row = 16, .col = 28 },
    .{ .row = 17, .col = 28 },
    .{ .row = 18, .col = 27 },
    .{ .row = 19, .col = 27 },
    .{ .row = 20, .col = 27 },
    .{ .row = 21, .col = 26 },
    .{ .row = 22, .col = 26 },
    .{ .row = 23, .col = 25 },
    .{ .row = 24, .col = 24 },
    .{ .row = 25, .col = 23 },
    .{ .row = 26, .col = 22 },
    .{ .row = 26, .col = 21 },
    .{ .row = 27, .col = 20 },
    .{ .row = 27, .col = 19 },
    .{ .row = 27, .col = 18 },
    .{ .row = 28, .col = 17 },
    .{ .row = 28, .col = 16 },
    .{ .row = 28, .col = 15 },
    .{ .row = 28, .col = 14 },
    .{ .row = 28, .col = 13 },
    .{ .row = 28, .col = 12 },
    .{ .row = 27, .col = 11 },
    .{ .row = 27, .col = 10 },
    .{ .row = 27, .col = 9 },
    .{ .row = 26, .col = 8 },
    .{ .row = 26, .col = 7 },
    .{ .row = 25, .col = 6 },
    .{ .row = 24, .col = 5 },
    .{ .row = 23, .col = 4 },
    .{ .row = 22, .col = 3 },
    .{ .row = 21, .col = 3 },
    .{ .row = 20, .col = 2 },
    .{ .row = 19, .col = 2 },
    .{ .row = 18, .col = 2 },
    .{ .row = 17, .col = 1 },
    .{ .row = 16, .col = 1 },
    .{ .row = 15, .col = 1 },
    .{ .row = 14, .col = 1 },
    .{ .row = 13, .col = 1 },
    .{ .row = 12, .col = 1 },
    .{ .row = 11, .col = 1 },
    .{ .row = 10, .col = 2 },
    .{ .row = 9, .col = 2 },
    .{ .row = 8, .col = 2 },
    .{ .row = 7, .col = 3 },
    .{ .row = 6, .col = 3 },
    .{ .row = 5, .col = 4 },
    .{ .row = 4, .col = 5 },
    .{ .row = 3, .col = 6 },
    .{ .row = 2, .col = 7 },
    .{ .row = 2, .col = 8 },
    .{ .row = 1, .col = 9 },
    .{ .row = 1, .col = 10 },
    .{ .row = 1, .col = 11 },
    .{ .row = 0, .col = 11 },
    .{ .row = 0, .col = 12 },
    .{ .row = 0, .col = 13 },
};

const onState = .{ .row = 23, .col = 21 };

const State = enum { TIME, TIMER_STATE, SET_TIME };

var mode: State = .TIME;
var alarmState: enum { on, off } = .off;
var settingHours: bool = true;
var alarmTime: struct { hours: ?u8 = null, minutes: ?u8 = null, seconds: ?u8 = null } = .{};
var hoursVisible: bool = true;
var minutesVisible: bool = true;
var lastBlink: u64 = 0;
const totalTime = 60 * time.ns_per_s; // 1 minute in nanoseconds
const timePerDot = totalTime / circle.len;

fn getCurrentTime() struct { hours: u8, minutes: u8, seconds: u8 } {
    const now = std.time.timestamp();
    const t = std.time.epoch.EpochSeconds{ .secs = @intCast(now) };
    const tm = t.getDaySeconds();
    return .{
        .hours = tm.getHoursIntoDay(),
        .minutes = tm.getMinutesIntoHour(),
        .seconds = tm.getSecondsIntoMinute(),
    };
}

fn isDotLit(row: usize, col: usize) bool {
    const digitPositions = [_]struct { row_offset: i32, col_offset: i32 }{
        .{ .row_offset = 5, .col_offset = 9 }, // Hour tens
        .{ .row_offset = 5, .col_offset = 15 }, // Hour units
        .{ .row_offset = 15, .col_offset = 9 }, // Minute tens
        .{ .row_offset = 15, .col_offset = 15 }, // Minute units
    };

    switch (mode) {
        .TIME, .SET_TIME => {
            const current = getCurrentTime();
            const hours = if (mode == .TIME) current.hours else if (mode == .SET_TIME and !hoursVisible) null else alarmTime.hours orelse current.hours;
            const minutes = if (mode == .TIME) current.minutes else if (mode == .SET_TIME and !minutesVisible) null else alarmTime.minutes orelse current.minutes;
            const seconds = if (mode == .TIME) current.seconds else if (mode == .SET_TIME and !minutesVisible) null else alarmTime.seconds orelse current.seconds;

            if (mode == .TIME) {
                const minuteEven = (minutes orelse 0) % 2 == 0;

                // Check circle
                for (circle, 0..) |dot, index| {
                    const mappedSecond = (index * 60) / circle.len;
                    const minuteEvenDotVisible = minuteEven and mappedSecond < (seconds orelse 0);
                    const minuteOddDotVisible = !minuteEven and mappedSecond > (seconds orelse 0);
                    if (dot.row == row and dot.col == col and (minuteEvenDotVisible or minuteOddDotVisible)) return true;
                }

                if (alarmState == .on and row == onState.row and col == onState.col) return true;
            }

            const digits = [_]?u8{
                if (hours != null) @divTrunc(hours.?, 10) else null,
                if (hours != null) @mod(hours.?, 10) else null,
                if (minutes != null) @divTrunc(minutes.?, 10) else null,
                if (minutes != null) @mod(minutes.?, 10) else null,
            };

            for (digits, 0..) |digit, i| {
                if (digit == null) continue;
                const pattern = digitPatterns[digit.?];
                const pos = digitPositions[i];
                for (pattern) |dot| {
                    const r = pos.row_offset + dot.row;
                    const co = pos.col_offset + dot.col;
                    if (r == row and co == col) return true;
                }
            }
        },
        .TIMER_STATE => {
            const patterns = if (alarmState == .on) onOffPatterns.on else onOffPatterns.off;
            for (patterns, 0..) |pattern, i| {
                const pos = digitPositions[i];
                for (pattern) |dot| {
                    const r = pos.row_offset + dot.row;
                    const co = pos.col_offset + dot.col;
                    if (r == row and co == col) return true;
                }
            }
        },
    }

    return false;
}

var previous_grid: [31][31]bool = undefined; // Track previous State
fn updateScreen(writer: anytype, current: *const [31][31]bool) !void {
    for (0..31) |row| {
        for (0..31) |col| {
            if (current[row][col] != previous_grid[row][col]) {
                // Move cursor to the correct position (1-based for ANSI)
                try writer.print("\x1b[{};{}H", .{ row + 1, col * 2 + 1 });
                try writer.writeAll(if (current[row][col]) "██" else "  ");
            }
        }
    }
    // Move cursor out of the way to prevent flicker
    try writer.writeAll("\x1b[31;1H");
    // Update previous_grid to current state
    @memcpy(&previous_grid, current);
}

fn redraw(writer: anytype) !void {
    var current_grid: [31][31]bool = undefined;
    for (0..31) |row| {
        for (0..31) |col| {
            current_grid[row][col] = isDotLit(row, col);
        }
    }
    try updateScreen(writer, &current_grid);
}

fn handleInput(key: u8) void {
    switch (key) {
        'a' => left(),
        'r' => center(),
        's' => right(),
        else => {},
    }
}

fn left() void {
    if (mode == .TIMER_STATE) {
        alarmState = if (alarmState == .on) .off else .on;
    } else if (mode == .SET_TIME) {
        if (settingHours) {
            alarmTime.hours = if (alarmTime.hours) |h| (h - 1) % 24 else 23;
        } else {
            alarmTime.minutes = if (alarmTime.minutes) |m| (m - 1) % 60 else 59;
        }
    }
}

fn center() void {
    switch (mode) {
        .TIME => {
            mode = .TIMER_STATE;
        },
        .TIMER_STATE => {
            if (alarmState == .on) {
                mode = .SET_TIME;
                const current = getCurrentTime();
                alarmTime.hours = current.hours;
                alarmTime.minutes = current.minutes;
                settingHours = true;
                hoursVisible = true;
                minutesVisible = true;
                lastBlink = 0;
            } else {
                mode = .TIME;
            }
        },
        .SET_TIME => {
            if (settingHours) {
                settingHours = false;
            } else {
                mode = .TIME;
            }
        },
    }
}

fn right() void {
    if (mode == .TIMER_STATE) {
        alarmState = if (alarmState == .on) .off else .on;
    } else if (mode == .SET_TIME) {
        if (settingHours) {
            alarmTime.hours = if (alarmTime.hours) |h| (h + 1) % 24 else 0;
        } else {
            alarmTime.minutes = if (alarmTime.minutes) |m| (m + 1) % 60 else 0;
        }
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    const fd = try posix.open("/dev/tty", .{ .ACCMODE = .RDWR }, 0);
    const state = try posix.tcgetattr(fd);

    const original_termios = try posix.tcgetattr(fd);
    defer posix.tcsetattr(fd, .FLUSH, original_termios) catch {}; // Restore on exit

    var raw = state;
    // see termios(3)
    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;
    raw.cflag.CSIZE = .CS8;
    raw.cflag.PARENB = false;
    raw.cc[@intFromEnum(posix.V.MIN)] = 0;
    raw.cc[@intFromEnum(posix.V.TIME)] = 0;
    try posix.tcsetattr(fd, .FLUSH, raw);

    try stdout.writeAll("\x1b[?25l"); // Hide cursor

    var timer = try time.Timer.start();
    var last_redraw: u64 = 0;
    var buffer: [1]u8 = undefined;

    try stdout.writeAll("\x1b[?25l"); // Hide cursor
    try stdout.writeAll("\x1b[2J");

    // Initialize previous_grid
    for (&previous_grid) |*row| {
        @memset(row, false);
    }

    while (true) {
        // Update display
        const now = timer.read();
        if (mode == .TIME or mode == .TIMER_STATE) {
            if (now - last_redraw > time.ns_per_s / 2) {
                last_redraw = now;
                try redraw(stdout);
            }
        }

        // Handle blinking in SET_TIME mode
        if (mode == .SET_TIME and now - lastBlink > 100000000) {
            lastBlink = now;
            if (settingHours) {
                hoursVisible = !hoursVisible;
                minutesVisible = true;
            } else {
                minutesVisible = !minutesVisible;
                hoursVisible = true;
            }
            try redraw(stdout);
        }

        const n = try stdin.read(&buffer);
        if (n > 0) {
            // A keystroke was received.
            if (buffer[0] == 'q') break;
            handleInput(buffer[0]);
        }

        // Do other periodic tasks, e.g. updating display...
        time.sleep(10 * time.ns_per_ms);
    }

    try stdout.writeAll("\x1b[?25h"); // Restore cursor
}
