const std = @import("std");
const Answer = struct {
    part1: u64 = 0,
    part2: u64 = 0,
};

pub fn startProcess(input: []const u8) !Answer {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var result: Answer = .{};

    var it = std.mem.tokenizeAny(u8, input, "\n");

    //const ally = std.testing.allocator;
    var part2list = std.ArrayList(u32).init(allocator);
    defer part2list.deinit();
    while (it.next()) |_|{
        try part2list.append(1);
    }
    var idx: i32 = 0;
    //for (part2list.items) |value| {
        //std.debug.print("check: {} {} \n", .{value, idx});
     //   idx += 1;
    //}
    const maxLines: usize = part2list.items.len;
    it.reset();
    var lineOn: usize = 0;
    while (it.next()) |lineLoading| {

        var counter: u6 = 0;
        var ticketSplit = std.mem.tokenizeAny(u8, lineLoading, ":");
        _ = ticketSplit.next(); //the card ## rest is numbers

        if (ticketSplit.next()) |numbersAndSpaces| {
            var winningList = std.AutoHashMap(u32, void).init(allocator);


            var cards = std.mem.tokenizeAny(u8, numbersAndSpaces, "|");
            var firstPass: bool = true;
            while (cards.next()) |winingTicket| {
                var winningNumbers = std.mem.tokenizeAny(u8, winingTicket, " ");
                if (firstPass) {
                    while (winningNumbers.next()) |value| {
                        const numberWin = try std.fmt.parseInt(u32, value, 10);
                        try winningList.put(numberWin, {});
                    }
                    firstPass = false;
                } else {
                    while (winningNumbers.next()) |selection| {
                        const numberSelected = try std.fmt.parseInt(u32, selection, 10);

                        if (winningList.contains(numberSelected)) {
                            //std.debug.print("Winner {}", .{numberSelected});
                            counter += 1;
                        }
                        // }
                        firstPass = true;
                    }
                }
            }

            lineOn += 1;
            if (counter > 0){
                result.part1 += @as(u64, 1) << (counter-1);
                var i = lineOn;
                const cardsHeld =  part2list.items[i-1];
                while(i < maxLines and counter > 0) {

                    part2list.items[i] += cardsHeld;


                    i = i + 1;
                    counter = counter - 1;
                }
            }
            //std.debug.print("====\n", .{});

        }
    }
    result.part2 = 0;
    idx = 0;
    for (part2list.items) |value| {
        //std.debug.print("check: {} {} \n", .{value, idx});
        idx += 1;
        result.part2 += value;
    }

    return result;
}

pub fn main() !void  {
    const input = @embedFile("puzzleInput.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 3: {any}\n", .{result});
}

test "part1_test" {
    std.debug.print("\nTest 1\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 4: {any}\n", .{result});
    try std.testing.expect(result.part1 == 13);
}

test "part2_test" {
    std.debug.print("\nTest 2\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 4: {any}\n", .{result});
    try std.testing.expect(result.part2 == 30);
}
