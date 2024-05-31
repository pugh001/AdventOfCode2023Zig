const std = @import("std");
const Answer = struct {
    part1: u64 = 0,
    part2: u64 = 0,
    };
const CardHand = struct { cards: []const u8 = "", bid: u64 = 0, hexValue: []const u8 = undefined , score: u64};

fn cmpByHex(a: CardHand, b: CardHand) bool {


    if ( a.score < b.score) {
        return true;
    } else {
        return false;
    }
}

fn partition(slice: []CardHand, low: usize, high: usize, cmp: fn (a: CardHand, b: CardHand) bool) usize {
    const pivot = slice[high];
    var i: usize = low;

    for (low..high) |j| {
        if (cmp(slice[j], pivot)) {
            // Swap slice[i] and slice[j]
            const temp = slice[i];
            slice[i] = slice[j];
            slice[j] = temp;
            i += 1;
        }
    }

    // Swap slice[i] and slice[high] (or pivot)
    const temp = slice[i];
    slice[i] = slice[high];
    slice[high] = temp;

    return i;
}

fn quicksort(slice: []CardHand, low: usize, high: usize, cmp: fn (a: CardHand, b: CardHand) bool) void {
    if (low < high) {
        const pi = partition(slice, low, high, cmp);
        if (pi > 0) quicksort(slice, low, pi - 1, cmp);
        quicksort(slice, pi + 1, high, cmp);
    }
}

pub fn createDataMapping(allocator: std.mem.Allocator, it: *std.mem.TokenIterator(u8, .any)) ![]CardHand {
    var rulesLoad = std.ArrayList(CardHand).init(allocator);
    defer rulesLoad.deinit();
    while (it.next()) |dataLoading| {
        try rulesLoad.append(try splitRow(dataLoading));
    }

    quicksort(rulesLoad.items, 0, rulesLoad.items.len - 1, cmpByHex);
    return rulesLoad.toOwnedSlice();
}

fn splitRow(dataLoading: []const u8) !CardHand {
    var localRule: CardHand = undefined;
    var value: []const u8 = undefined;
    var rowDataSplit = std.mem.tokenizeAny(u8, dataLoading, " ");

    value = rowDataSplit.next().?;
    localRule.cards = value;

    value = rowDataSplit.next().?;
    localRule.bid = try std.fmt.parseInt(u64, value, 10);

    localRule.hexValue = try setHexValue(localRule.cards);
    localRule.score =  try std.fmt.parseInt(u64,  localRule.hexValue, 16);

    return localRule;
}
pub fn setHexValue(hand: []const u8) ![]const u8 {
    var hexValue = [_]u8{ '0', '0', '0', '0', '0', '0' };
    for (hand[0..], 1..) |card, idx| {
        hexValue[idx] = switch (card) {
        'T' => 'A',
        'J' => '1',
        'Q' => 'C',
        'K' => 'D',
        'A' => 'E',
        else => card,
        };
    }
    hexValue[0] = try setScore(hand);
    const stringValue: []const u8 = hexValue[0..];
    return stringValue;
}
pub fn setScore(hand: []const u8) !u8 {
    var counts = [15]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    for (hand) |card| {
        const index: u8 = switch (card) {
        'T' => 10,
        'J' => 11,
        'Q' => 12,
        'K' => 13,
        'A' => 14,
        else => card - '0',
        };

        counts[index] += 1;
    }

    const jokers: u8 = counts[11];
    counts[11] = 0;
    var countOfCounts = [6]u8{ 0, 0, 0, 0, 0, 0 };



    // Count the frequencies of the counts.
    for (counts) |count| {

        if (count > 0 and count <= 5) {
            countOfCounts[count] += 1;
        }
    }



    var score: u8 = 0;
    // Determine the score based on the rules.
    if (countOfCounts[5] == 1 or jokers == 5) {
        return  '7'; // Five of a kind.
    } else if (countOfCounts[4] == 1) {
        score =  '6'; // Four of a kind.
        if (jokers == 1){
            return '7';
        }
    } else if (countOfCounts[3] == 1 and countOfCounts[2] == 1) {
        return  '5'; // Full house.
    } else if (countOfCounts[3] == 1) {
        score =  '4'; // Three of a kind.
        if (jokers == 1) return '6';
        if (jokers == 2) return '7';
    } else if (countOfCounts[2] == 2) {
        score =  '3'; // Two pair.
        if (jokers == 1) return '5';
    } else if (countOfCounts[2] == 1) {
        score =  '2'; // One pair.
        if (jokers == 1) return '4';
        if (jokers == 2) return '6';
        if (jokers == 3) return '7';
    } else {
        score =  '1'; // High card.
        if (jokers == 1) return '2';
        if (jokers == 2) return '4';
        if (jokers == 3) return '6';
        if (jokers == 4) return '7';
    }
    return score;

}

const Solution = struct {
    allocator: std.mem.Allocator,
    deck: []CardHand,

    pub fn initialize(allocator: std.mem.Allocator, input: []const u8) !Solution {
        var it = std.mem.tokenizeAny(u8, input, "\n");
        const deck = try createDataMapping(allocator, &it);
        return .{
            .allocator = allocator,
            .deck = deck,
        };
    }
    pub fn theAnswerIs(self: *Solution) !u64 {
        var result: u64 = 0;
        var index: u64 = 1;
        for (self.deck[0..]) |cards| {
            const seedAnswer = cards.bid * index;
            result += seedAnswer;
            index += 1;
        }

        return result;
    }
};

pub fn startProcess(input: []const u8) !Answer {
    var result: Answer = .{};
    result.part2 = 0;
    result.part1 = 35;
    const allocator = std.heap.page_allocator;
    var solution = try Solution.initialize(allocator, input);
    result.part2 = try solution.theAnswerIs();
    //result.part2 = try solution.part2AnswerIs();
    //defer solution.releaseAll();

    return result;
}

pub fn main() !void  {
    const input = @embedFile("puzzleInput.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 7: {any}\n", .{result});
}

test "part1_test" {
    std.debug.print("\nTest 1\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 7: {any}\n", .{result});
    try std.testing.expect(result.part1 == 6440);
}

test "part2_test" {
    std.debug.print("\nTest 2\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 5: {any}\n", .{result});
    try std.testing.expect(result.part2 == 5905);
}
