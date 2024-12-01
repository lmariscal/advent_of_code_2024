next_token :: (str: string, cursor: *s64, $delimiters: []u8 = u8.[#char " ", #char "\n", #char "\t", #char "\r"]) -> token: string {
    result: string = .{ data = str.data + cursor.*, count = 0 };

    while cursor.* < str.count {
        if array_find(delimiters, str[cursor.*]) {
            result.count = cursor.* - (result.data - str.data);
            break;
        }
        cursor.* += 1;
    }

    while cursor.* < str.count && array_find(delimiters, str[cursor.*])
        cursor.* += 1;

    return result;
}
