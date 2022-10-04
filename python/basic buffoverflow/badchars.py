from __future__ import print_function
listRem = "\\x04\\x11\\x40\\x78\\a2".split("\\x")
for x in range(1, 256):
    if "{:02x}".format(x) not in listRem:
        print("\\x" + "{:02x}".format(x), end='')
print()
