#import "Basic";
#import "File";
#import "Sort";
#import "String";
#import "Math";
#import "Hash_Table";
#import "File_Utilities";

#load "utils.jai";

EXAMPLE_INPUT :: #string DONE
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
DONE

EXAMPLE_ANSWER_FIRST :: 480;
EXAMPLE_ANSWER_SECOND :: 875318608908;

INPUT_FILE :: "./inputs/13.txt";

Vec2 :: struct {
    x: s64;
    y: s64;
}

Configuration :: struct {
    a: Vec2;
    b: Vec2;
    prize: Vec2;
}

first_star :: (configs: []Configuration) -> s64 {
    sum := 0;
    for configs {
        sum += token_count(it);
    }
    return sum;
}

second_star :: (configs: []Configuration) -> s64 {
    sum := 0;
    for configs {
        using it;
        prize.x += 10000000000000;
        prize.y += 10000000000000;
        sum += token_count(it);
    }
    return sum;
}

token_count :: (using config: Configuration) -> s64 {
    det := (a.x * b.y) - (a.y * b.x);
    assert(det != 0, "Matrix is not invertible");

    xa := (b.y * prize.x - b.x * prize.y) / det;
    xb := (a.x * prize.y - a.y * prize.x) / det;

    res := Vec2.{ a.x * xa + b.x * xb, a.y * xa + b.y * xb };

    if res.x != prize.x || res.y != prize.y  return 0;
    return (xa * 3) + xb;
}

parse_input :: (input: string) -> []Configuration {
    delimeters :: u8.[#char " ", #char "\n"];
    cursor := 0;
    state := 0; // 0 - A, 1 - B, 2 - Prize
    configs: [..]Configuration;
    tmp: Configuration;

    while cursor < input.count {
        token, is_new_line := next_token(input, *cursor, delimeters);
        defer if is_new_line {
            state = (state + 1) % 3;
            if state != 0  continue;
            array_add(*configs, tmp);
        }
        if token[0] != #char "X" && token[0] != #char "Y"  continue;

        dest_v := *tmp.a;
        if state == 1  dest_v = *tmp.b;
        else if state == 2  dest_v = *tmp.prize;

        dest := ifx token[0] == #char "X" then *dest_v.x else *dest_v.y;

        digits_str := slice(token, 2, token.count - 2);
        digits := string_to_int(digits_str);
        // if token[1] == #char "-" then digits *= -1;

        dest.* = digits;
    }

    return configs;
}

validate_example :: () {
    input := EXAMPLE_INPUT;

    configs := parse_input(input);
    defer array_free(configs);

    first := first_star(configs);
    second := second_star(configs);

    assert(first == EXAMPLE_ANSWER_FIRST);
    assert(second == EXAMPLE_ANSWER_SECOND);
}

main :: () {
    validate_example();
    if !file_exists(INPUT_FILE) {
        print("Input file for day 03 not found: '%'\n", INPUT_FILE);
        return;
    }

    input := read_entire_file(INPUT_FILE);

    configs := parse_input(input);
    defer array_free(configs);

    first := first_star(configs);
    second := second_star(configs);

    print("First star: %\n", first);
    print("Second star: %\n", second);
}
