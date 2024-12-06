#import "Basic";
#import "File";
#import "Sort";
#import "String";
#import "Math";
#import "Hash_Table";
#import "File_Utilities";

#load "utils.jai";

EXAMPLE_INPUT :: #string DONE
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
DONE

EXAMPLE_ANSWER_FIRST :: 143;
EXAMPLE_ANSWER_SECOND :: 123;

INPUT_FILE :: "./inputs/05.txt";

Rule :: struct {
    first: s64 = -1;
    second: s64 = -1;
}

first_star :: (rules: []Rule, updates: [][]s64) -> s64 {
    verify_rule :: (rules: []Rule, positions: Table(s64, s64)) -> bool {
        for rules {
            first_pos := table_find_pointer(*positions, it.first);
            second_pos := table_find_pointer(*positions, it.second);

            if first_pos == null || second_pos == null  continue;

            if first_pos.* > second_pos.*  return false;
        }
        return true;
    }

    sum := 0;
    for update: updates {
        table: Table(s64, s64);
        defer deinit(*table);
        for update  table_set(*table, it, it_index);

        correct := verify_rule(rules, table);
        if !correct  continue;
        sum += update[update.count / 2];
    }

    return sum;
}

second_star :: (rules: []Rule, updates: [][]s64) -> s64 {
    fix_by_rule :: (rules: []Rule, positions: *Table(s64, s64)) -> bool {
        correct := true;
        for < rules {
            first_pos_ptr := table_find_pointer(positions, it.first);
            second_pos_ptr := table_find_pointer(positions, it.second);

            if first_pos_ptr == null || second_pos_ptr == null  continue;

            first_pos := first_pos_ptr.*;
            second_pos := second_pos_ptr.*;

            if first_pos < second_pos  continue;

            correct = false;
            table_set(positions, it.first, second_pos);
            table_set(positions, it.second, first_pos);
        }
        return correct;
    }

    sum := 0;
    for update: updates {
        table: Table(s64, s64);
        defer deinit(*table);
        for update  table_set(*table, it, it_index);

        correct := fix_by_rule(rules, *table);
        if correct  continue;

        while !correct  correct = fix_by_rule(rules, *table);

        for table  if (it == update.count / 2)  sum += it_index;
    }

    return sum;
}

parse_input :: (input: string) -> rules: []Rule, updates: [][]s64 {
    rules: [..]Rule;
    updates: [..][]s64;

    delimeters :: u8.[#char "|", #char ",", #char "\n"];
    cursor := 0;

    rules_section := true;
    tmp_rule: Rule;
    tmp_update: [..]s64;
    while cursor < input.count {
        token, is_new_line := next_token(input, *cursor, delimeters, false);
        if rules_section {
            if token == "" {
                rules_section = false;
                continue;
            }

            number := string_to_int(token);
            if tmp_rule.first == -1 {
                tmp_rule.first = number;
            } else {
                tmp_rule.second = number;
                array_add(*rules, tmp_rule);
                tmp_rule = .{};
            }
        } else {
            number := string_to_int(token);
            array_add(*tmp_update, number);
            if is_new_line {
                array_add(*updates, array_copy(tmp_update));
                array_reset_keeping_memory(*tmp_update);
            }
        }
    }

    return rules, updates;
}

validate_example :: () {
    input := EXAMPLE_INPUT;

    rules, updates := parse_input(input);
    defer array_free(rules);
    defer array_free(updates);

    first := first_star(rules, updates);
    second := second_star(rules, updates);

    assert(first == EXAMPLE_ANSWER_FIRST);
    assert(second == EXAMPLE_ANSWER_SECOND);

    for updates  array_free(it);
}

main :: () {
    validate_example();
    if !file_exists(INPUT_FILE) {
        print("Input file for day 03 not found: '%'\n", INPUT_FILE);
        return;
    }

    input := read_entire_file(INPUT_FILE);

    rules, updates := parse_input(input);
    defer array_free(rules);
    defer array_free(updates);

    first := first_star(rules, updates);
    second := second_star(rules, updates);

    print("First star: %\n", first);
    print("Second star: %\n", second);

    for updates  array_free(it);
}
