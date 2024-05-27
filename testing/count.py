import vcd

def count_token_types(vcd_file):
    count_change_time = 0
    count_change_scalar = 0
    count_change_vector = 0
    count_valid_pixel = 0
    count_invalid_pixel = 0

    signals = {}
    valid = False  # Track the valid signal state

    with open(vcd_file, 'rb') as f:  # Open the file in binary mode
        for token in vcd.tokenize(f):
            # Identify and store signal identifiers
            if token.kind == vcd.reader.TokenKind.VAR:
                var = token.data
                if var.reference == 'out_stream_tdata':
                    signals['data'] = var.id_code
                elif var.reference == 'out_stream_tvalid':
                    signals['valid'] = var.id_code
            # Handle vector changes
            elif token.kind == vcd.reader.TokenKind.CHANGE_VECTOR:
                count_change_vector += 1
                changes = {token.data.id_code: token.data.value}
                if signals.get('valid') in changes:
                    valid_change = changes[signals['valid']]
                    valid = valid_change == '1'
                if signals.get('data') in changes:
                    if valid:
                        count_valid_pixel += 1
                    else:
                        count_invalid_pixel += 1
            # Handle scalar changes
            elif token.kind == vcd.reader.TokenKind.CHANGE_SCALAR:
                count_change_scalar += 1
                changes = {token.data.id_code: token.data.value}
                if signals.get('valid') in changes:
                    valid_change = changes[signals['valid']]
                    valid = valid_change == '1'
            # Handle time changes
            elif token.kind == vcd.reader.TokenKind.CHANGE_TIME:
                count_change_time += 1

    return count_valid_pixel, count_invalid_pixel, count_change_time, count_change_scalar, count_change_vector

# Path to the VCD file
vcd_file = 'test.vcd'

# Count token types
count_valid_pixel, count_invalid_pixel, count_change_time, count_change_scalar, count_change_vector = count_token_types(vcd_file)

# Print the counts
print(f"Number of valid pixel data entries: {count_valid_pixel}")
print(f"Number of invalid pixel data entries: {count_invalid_pixel}")
print(f"Number of CHANGE_TIME tokens (kind 14): {count_change_time}")
print(f"Number of CHANGE_SCALAR tokens (kind 15): {count_change_scalar}")
print(f"Number of CHANGE_VECTOR tokens (kind 16): {count_change_vector}")
