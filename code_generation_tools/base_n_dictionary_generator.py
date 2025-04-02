import string

array_builder = "char[] charSet = ["

for char in string.digits + string.ascii_uppercase + string.ascii_lowercase + string.punctuation:
    if char == "'":
        array_builder += f"'\\\'',"
        continue
    if char == '\\':
        char += char
    array_builder += f"'{char}',"
    
array_builder = array_builder[0:-1] + "];"

print(array_builder)
print(len(array_builder))