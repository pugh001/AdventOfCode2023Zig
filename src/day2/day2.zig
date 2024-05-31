const std = @import("std");
const Cube = struct {
    red: i32 = 0,
    green: i32 = 0,
    blue: i32 = 0,
};

const Answer = struct {
    part1: i32 = 0,
    part2: i32 = 0,
};

pub fn getGames(input: []const u8) !Answer {
    const red: i32 = 12;
    const green: i32 = 13;
    const blue: i32 = 14;

    var result: Answer = .{};
    var counter: i32 = 0;
    var it = std.mem.tokenizeAny(u8, input, "\n");
    var gameId: i32 = 0;
    while (it.next()) |game| {
        var gameLine = std.mem.tokenizeAny(u8, game, ":");
        if (gameLine.next()) |gameIdWithText| {
            gameId = std.fmt.parseInt(i32, gameIdWithText[5..], 10) catch 0;
        }
        if (gameId == 0) {
            continue;
        }
        var isFailed = false;

        if (gameLine.next()) |gameValue| {
            var values = std.mem.tokenizeAny(u8, gameValue, ";");
            var cubePart2: Cube = .{};
            while (values.next()) |cubes| {
                var cubes1: Cube = .{};
                var cubeCountandColour = std.mem.tokenizeAny(u8, cubes, ",");
                while (cubeCountandColour.next()) |cubeDetail| {
                    var cubeValueSplit = std.mem.tokenizeAny(u8, cubeDetail, " ");
                    if (cubeValueSplit.next()) |cubeValue| {
                        //std.debug.print("cubeValue: {s}\n", .{cubeValue});
                        counter = std.fmt.parseInt(i32, cubeValue, 10) catch 0;
                        //std.debug.print("counter: {}\n", .{counter});
                    }
                    if (cubeValueSplit.next()) |cubeColour| {
                        //std.debug.print("colour: {s}\n", .{cubeColour});
                        switch (cubeColour[0]) {
                            'r' => {
                                cubes1.red += counter;
                                cubePart2.red = @max(cubePart2.red, counter);
                            },
                            'g' => {
                                cubes1.green += counter;
                                cubePart2.green = @max(cubePart2.green, counter);
                            },
                            'b' => {
                                cubes1.blue += counter;
                                cubePart2.blue = @max(cubePart2.blue, counter);
                            },
                            else => {
                                std.debug.print("Unknown\n", .{});
                            },
                        }
                    }
                    if (cubes1.red > red or cubes1.green > green or cubes1.blue > blue) {
                        isFailed = true;
                    }
                }
            }
            result.part2 += cubePart2.red * cubePart2.green * cubePart2.blue;
        }
        if (isFailed == false) {
            result.part1 += gameId;
        }
        isFailed = false;
        gameId = 0;
    }
    return result;
}
pub fn main() !void  {
    const input = @embedFile("puzzleInput.txt");
    const result: Answer = try getGames(input);
    std.debug.print("Result Day 2: {any}\n", .{result});
}

test "day1_part1_test" {
    std.debug.print("\nTest 1\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try getGames(input);
    try std.testing.expect(result.part1 == 8);
}

test "day1_part2_test" {
    std.debug.print("\nTest 2\n", .{});
    const input = @embedFile("Part2Example.txt");
    const result: Answer = try getGames(input);
    try std.testing.expect(result.part2 == 2286);
}
