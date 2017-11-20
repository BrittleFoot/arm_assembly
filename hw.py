import sys
if len(sys.argv) != 3:
    print()
    print('Формат командной строки:')
    print('    ./s1.py input find substring')
    sys.exit(2)

l = 0
for line in open(sys.argv[1], 'r'):
    if sys.argv[2] in line:
        sys.stdout.write('%.8X' % l + ':' + line)