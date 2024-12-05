#import "Basic";
#import "File";
#import "Sort";
#import "String";
#import "Math";
#import "Hash_Table";
#import "File_Utilities";

#load "utils.jai";

EXAMPLE_INPUT :: #string DONE
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
DONE

EXAMPLE_ANSWER_FIRST :: 161;
EXAMPLE_ANSWER_SECOND :: 48;

INPUT_FILE :: "./inputs/03.txt";

parse_function :: (input: string, cursor: *s64) -> valid: bool, args: []s64 = .[] {
    current := cursor.* + 1;
    arg_builder: [..]u8;
    args: [..]s64;

    while current < input.count {
        defer current += 1;

        if input[current] == #char ")" {
            if arg_builder.count != 0 {
                val := string_to_int(string.{ data = arg_builder.data, count = arg_builder.count });
                array_add(*args, val);
                array_reset(*arg_builder);
            }
            cursor.* = current + 1;
            return true, args;
        }
        if input[current] == #char "(" {
            cursor.* += 1;
            return false;
        }
        if input[current] == #char "," {
            val := string_to_int(string.{ data = arg_builder.data, count = arg_builder.count });
            array_add(*args, val);
            array_reset(*arg_builder);
            continue;
        }

        if !is_digit(input[current]) {
            cursor.* += 1;
            return false;
        }

        array_add(*arg_builder, input[current]);
    }

    return false;
}

parse_input :: (input: string, $use_dos: bool) -> s64 {
    cursor := 0;
    name_builder: [..]u8;
    sum := 0;
    do := true;

    while cursor < input.count {
        if input[cursor] == #char " " || input[cursor] == #char "\n" {
            cursor += 1;
            continue;
        }

        if input[cursor] == #char "(" {
            name: string = .{
                data = name_builder.data,
                count = name_builder.count,
            };
            valid, args := parse_function(input, *cursor);

            if valid {
                if ends_with(name, "mul") && args.count == 2 {
                    if do  sum += args[0] * args[1];
                }
                #if use_dos {
                    if ends_with(name, "don't") && args.count == 0 {
                        do = false;
                    } else if ends_with(name, "do") && args.count == 0 {
                        do = true;
                    }
                }
            }

            array_reset(*name_builder);
            continue;
        }

        array_add(*name_builder, input[cursor]);

        cursor += 1;
    }

    return sum;
}

validate_example :: () {
    input := EXAMPLE_INPUT;

    first := parse_input(input, false);
    second := parse_input(input, true);

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

    first := parse_input(input, false);
    second := parse_input(input, true);

    print("First: %\n", first);
    print("Second: %\n", second);
}
