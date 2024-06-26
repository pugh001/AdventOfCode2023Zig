const std = @import("std");
const Answer = struct {
    part1: i128 = 0,
    part2: i128 = 0,
};
const keyXY = struct {
    x: i128 = 0,
    y: i128 = 0,

    pub fn hash(self: keyXY) i128 {
        var hasher = std.hash.Fnv1a_128.init();
        hasher.hash(self.x);
        hasher.hash(self.y);
        return hasher.final();
    }
    pub fn eql(a: keyXY, b: keyXY) bool {
        return a.x == b.x and a.y == b.y;
    }
};

const DirectionMoving = struct { key: keyXY, entered: u8, exit: u8, movesMade: i128 = 1 };
const Directions = struct { N: bool, E: bool, S: bool, W: bool, value: u8 };
const myGrid = std.AutoHashMap(keyXY, Directions);
const polygonMap = std.AutoHashMap(keyXY, u8);

pub fn startProcess(input: []const u8) !Answer {
    var result: Answer = .{};
    result.part2 = 0;
    result.part1 = 0;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var directionMap = myGrid.init(allocator);

    var it = std.mem.tokenizeAny(u8, input, "\n");
    var x: i128 = 0;
    var y: i128 = 0;
    var maxX: i128 = 0;
    var maxY: i128 = 0;
    var startKey: keyXY = .{};
    var thisTurns: Directions = .{ .E = false, .N = false, .S = false, .W = false, .value = ' ' };
    while (it.next()) |dataRow| {
        for (dataRow) |char| {
            //std.debug.print("{c}", .{char});
            thisTurns = .{ .E = false, .N = false, .S = false, .W = false, .value = char };
            if (char == 'F') {
                thisTurns.E = true;
                thisTurns.S = true;
            } else if (char == '7') {
                thisTurns.S = true;
                thisTurns.W = true;
            } else if (char == '|') {
                thisTurns.S = true;
                thisTurns.N = true;
            } else if (char == 'L') {
                thisTurns.N = true;
                thisTurns.E = true;
            } else if (char == 'J') {
                thisTurns.N = true;
                thisTurns.W = true;
            } else if (char == '-') {
                thisTurns.E = true;
                thisTurns.W = true;
            } else if (char == 'S') {
                startKey = .{ .x = x, .y = y };
            }

            const key: keyXY = .{ .x = x, .y = y };

            try directionMap.put(key, thisTurns);
            x += 1;
        }
        //std.debug.print("\n", .{});
        y += 1;
        maxX = x - 1;
        x = 0;
    }
    maxY = y - 1;

    std.debug.print("Final Looking For:{any}\n", .{startKey});
    var tempKey: DirectionMoving = try getStartDirection(startKey, &directionMap, maxX, maxY);

    var polygon = polygonMap.init(allocator);
    defer polygon.deinit();

   var check: Directions  = directionMap.get(tempKey.key).?;
    try polygon.put(tempKey.key, check.value);
    std.debug.print("Add: {c}, {c}, {},{}; {c}\n", .{ tempKey.entered, tempKey.exit, tempKey.key.x, tempKey.key.y ,check.value});


    while (true) {
        //std.debug.print("K next:{any} Enter:{c} Exit:{c}  Move:{}\n", .{ tempKey.key, tempKey.entered, tempKey.exit, tempKey.movesMade });

        tempKey = try followThePath( tempKey, &directionMap);

        check = directionMap.get(tempKey.key).?;
        std.debug.print("Add: {c}, {c}, {},{}; {c}\n", .{ tempKey.entered, tempKey.exit, tempKey.key.x, tempKey.key.y ,check.value});

        try polygon.put(tempKey.key, check.value);
        if (tempKey.key.eql(startKey)) {
            break;
        }
    }
    std.debug.print("......\n", .{});
    result.part2 = part2(&polygon, maxX, maxY);
    result.part1 = @divTrunc(tempKey.movesMade, 2);
    return result;
}
pub fn part2(poly: *polygonMap, maxX: i128, maxY: i128) i128 {
    var yIdx: i128 = 0;
    var counter: i128 = 0;
    var value: u8 = '%';
    while (true) {
        var xIdx: i128 = 0;
        var inside: bool = false;
        while (true) {
            const nextKey: keyXY = .{ .x = xIdx, .y = yIdx };
            if (poly.contains(nextKey)) {
                value = poly.get(nextKey) orelse  '?';
                if (value == '-') {
                    std.debug.print("{c}", .{value});
                } else {
                    inside = !inside;
                    if (inside) {
                        std.debug.print("s", .{});
                    }
                    else {
                        std.debug.print("{c}", .{value});
                    }
                }
            } else {
                if (inside) {
                    std.debug.print("*", .{});
                    counter += 1;
                } else {
                    std.debug.print("O", .{});
                }
            }
            xIdx += 1;
            if (xIdx > maxX) {
                break;
            }
        }
        std.debug.print(": {}\n", .{counter});
        yIdx += 1;
        if (yIdx > maxY) {
            break;
        }
    }

    //https://en.wikipedia.org/wiki/Point_in_polygon

    return counter;
}
pub fn followThePath( key: DirectionMoving, directionMap: *myGrid) !DirectionMoving {
    var exit: u8 = key.exit;
    var entrance: u8 = key.exit;
    var newY = key.key.y;
    var newX = key.key.x;
    const counter = key.movesMade + 1;
    if (key.exit == 'S') {
        entrance = 'N';
        newY += 1;
    }
    if (key.exit == 'N') {
        entrance = 'S';
        newY -= 1;
    }
    if (key.exit == 'E') {
        entrance = 'W';
        newX += 1;
    }
    if (key.exit == 'W') {
        entrance = 'E';
        newX -= 1;
    }

    const tempKey: keyXY = .{ .x = newX, .y = newY };

   // if (tempKey.eql(finalKey)) {
   //     const setDirections: DirectionMoving = .{ .key = tempKey, .entered = entrance, .exit = 'x', .movesMade = counter };
    //     return setDirections;
   // }
    const thisTurns: Directions = directionMap.get(tempKey).?;

    if (thisTurns.N and entrance == 'N') {
        //std.debug.print("North = : {any}", .{thisTurns});
        if (thisTurns.E) {
            exit = 'E';
        }
        if (thisTurns.W) {
            exit = 'W';
        }
        if (thisTurns.S) {
            exit = 'S';
        }
    }
    if (thisTurns.S and entrance == 'S') {
        //std.debug.print("South: {any}", .{thisTurns});
        if (thisTurns.E) {
            exit = 'E';
        }
        if (thisTurns.W) {
            exit = 'W';
        }
        if (thisTurns.N) {
            exit = 'N';
        }
    }
    if (thisTurns.E and entrance == 'E') {
        //std.debug.print("East: {any}", .{thisTurns});
        if (thisTurns.S) {
            exit = 'S';
        }
        if (thisTurns.W) {
            exit = 'W';
        }
        if (thisTurns.N) {
            exit = 'N';
        }
    }
    if (thisTurns.W and entrance == 'W') {
        //std.debug.print("West: {any}", .{thisTurns});
        if (thisTurns.S) {
            exit = 'S';
        }
        if (thisTurns.E) {
            exit = 'E';
        }
        if (thisTurns.N) {
            exit = 'N';
        }
    }
    const setDirections: DirectionMoving = .{ .key = tempKey, .entered = entrance, .exit = exit, .movesMade = counter };
    ////std.debug.print("Count: {}\n", .{counter});
    return setDirections;
}
pub fn getStartDirection(key: keyXY, directionMap: *myGrid, maxX: i128, maxY: i128) !DirectionMoving {
    var setDirections: DirectionMoving = .{ .key = key, .entered = 'x', .exit = 'x', .movesMade = 0 };
    var exit: u8 = undefined;

    if (key.y < maxY) {
        const newY = key.y + 1;
        const tempKey: keyXY = .{ .x = key.x, .y = newY };
        const thisTurns: Directions = directionMap.get(tempKey).?;

        ////std.debug.print("Look Down:{any}\n", .{thisTurns});
        if (thisTurns.N) {
            //std.debug.print("Up True = : {any}", .{thisTurns});
            if (thisTurns.E) {
                exit = 'E';
            }
            if (thisTurns.W) {
                exit = 'W';
            }
            if (thisTurns.S) {
                exit = 'S';
            }
            setDirections = .{ .key = tempKey, .entered = 'N', .exit = exit };
            return setDirections;
        }
    }
    if (key.y > 0) {
        const newY = key.y - 1;
        const tempKey: keyXY = .{ .x = key.x, .y = newY };
        const thisTurns: Directions = directionMap.get(tempKey).?;

        ////std.debug.print("Turn:{any}\n", .{thisTurns});
        if (thisTurns.S) {
            ////std.debug.print("Turns: {any}", .{thisTurns});
            if (thisTurns.E) {
                exit = 'E';
            }
            if (thisTurns.W) {
                exit = 'W';
            }
            if (thisTurns.N) {
                exit = 'N';
            }
            setDirections = .{ .key = tempKey, .entered = 'S', .exit = exit };
            return setDirections;
        }
    }
    if (key.x < maxX) {
        const newX = key.x + 1;
        const tempKey: keyXY = .{ .x = newX, .y = key.y };
        const thisTurns: Directions = directionMap.get(tempKey).?;

        ////std.debug.print("Turn:{any}\n", .{thisTurns});
        if (thisTurns.E) {
            //std.debug.print("Turns: {any}", .{thisTurns});
            if (thisTurns.S) {
                exit = 'S';
            }
            if (thisTurns.W) {
                exit = 'W';
            }
            if (thisTurns.N) {
                exit = 'N';
            }
            setDirections = .{ .key = tempKey, .entered = 'E', .exit = exit };
            return setDirections;
        }
    }
    if (key.x > 0) {
        const newX = key.x - 1;
        const tempKey: keyXY = .{ .x = newX, .y = key.y };
        const thisTurns: Directions = directionMap.get(tempKey).?;

        //std.debug.print("Turn:{any}\n", .{thisTurns});
        if (thisTurns.W) {
            //std.debug.print("Turns: {any}", .{thisTurns});
            if (thisTurns.S) {
                exit = 'S';
            }
            if (thisTurns.E) {
                exit = 'E';
            }
            if (thisTurns.N) {
                exit = 'N';
            }
            setDirections = .{ .key = tempKey, .entered = 'W', .exit = exit };
            return setDirections;
        }
    }
    return setDirections;
}
pub fn main() !void {
    const input = @embedFile("puzzleInput.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result: {any}\n", .{result});
}

test "part1_test" {
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result: {any}\n", .{result});
    try std.testing.expect(result.part1 == 70);
}
test "part2_test" {
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result: {any}\n", .{result});
    try std.testing.expect(result.part2 == 8);
}
