"""NMOS 6502 source rendering for explicitly identified code ranges only.

No linear sweep over unknown disk data. Unknown opcodes in code are errors.
"""
ROWS = '''
BRK:i ORA:ix . . . ORA:z ASL:z . PHP:i ORA:n ASL:a . . ORA:w ASL:w .
BPL:r ORA:iy . . . ORA:zx ASL:zx . CLC:i ORA:wy . . . ORA:wx ASL:wx .
JSR:w AND:ix . . BIT:z AND:z ROL:z . PLP:i AND:n ROL:a . BIT:w AND:w ROL:w .
BMI:r AND:iy . . . AND:zx ROL:zx . SEC:i AND:wy . . . AND:wx ROL:wx .
RTI:i EOR:ix . . . EOR:z LSR:z . PHA:i EOR:n LSR:a . JMP:w EOR:w LSR:w .
BVC:r EOR:iy . . . EOR:zx LSR:zx . CLI:i EOR:wy . . . EOR:wx LSR:wx .
RTS:i ADC:ix . . . ADC:z ROR:z . PLA:i ADC:n ROR:a . JMP:ind ADC:w ROR:w .
BVS:r ADC:iy . . . ADC:zx ROR:zx . SEI:i ADC:wy . . . ADC:wx ROR:wx .
. STA:ix . . STY:z STA:z STX:z . DEY:i . TXA:i . STY:w STA:w STX:w .
BCC:r STA:iy . . STY:zx STA:zx STX:zy . TYA:i STA:wy TXS:i . . STA:wx . .
LDY:n LDA:ix LDX:n . LDY:z LDA:z LDX:z . TAY:i LDA:n TAX:i . LDY:w LDA:w LDX:w .
BCS:r LDA:iy . . LDY:zx LDA:zx LDX:zy . CLV:i LDA:wy TSX:i . LDY:wx LDA:wx LDX:wy .
CPY:n CMP:ix . . CPY:z CMP:z DEC:z . INY:i CMP:n DEX:i . CPY:w CMP:w DEC:w .
BNE:r CMP:iy . . . CMP:zx DEC:zx . CLD:i CMP:wy . . . CMP:wx DEC:wx .
CPX:n SBC:ix . . CPX:z SBC:z INC:z . INX:i SBC:n NOP:i . CPX:w SBC:w INC:w .
BEQ:r SBC:iy . . . SBC:zx INC:zx . SED:i SBC:wy . . . SBC:wx INC:wx .
'''.split()
assert len(ROWS) == 256
SIZES = dict(i=1, a=1, n=2, z=2, zx=2, zy=2, ix=2, iy=2, r=2,
             w=3, wx=3, wy=3, ind=3)


def decode(data, base, ranges):
    result = {}
    for start, stop in ranges:
        pc = start
        while pc < stop:
            token = ROWS[data[pc - base]]
            if token == '.':
                raise ValueError(f'unknown opcode at ${pc:04x}')
            op, mode = token.lower().split(':')
            size = SIZES[mode]
            if pc + size > stop:
                raise ValueError(f'instruction crosses code boundary at ${pc:04x}')
            raw = data[pc - base:pc - base + size]
            value = int.from_bytes(raw[1:], 'little')
            if mode == 'r':
                value = (pc + 2 + (value if value < 128 else value - 256)) & 65535
            result[pc] = (op, mode, value, raw)
            pc += size
    return result


def render(data, base, ranges, names):
    code = decode(data, base, ranges)
    labels = {pc: names.get(pc, f'l_{pc:04x}') for pc in code}
    out = []
    pc = base
    while pc < base + len(data):
        if pc not in code:
            end = pc + 1
            while end < base + len(data) and end not in code and end - pc < 16:
                end += 1
            out.append('    !byte ' + ','.join(f'${b:02x}' for b in data[pc-base:end-base]) + f' ; ${pc:04x} data')
            pc = end
            continue
        op, mode, val, raw = code[pc]
        num = labels.get(val, f'${val:04x}') if mode in ('w','wx','wy','ind','r') else f'${val:02x}'
        arg = {'i':'', 'a':'', 'n':'#'+num, 'z':num, 'zx':num+',x',
               'zy':num+',y', 'ix':'('+num+',x)', 'iy':'('+num+'),y',
               'w':num, 'wx':num+',x', 'wy':num+',y', 'ind':'('+num+')', 'r':num}[mode]
        if mode in ('w', 'wx', 'wy') and val < 256:
            op += '+2'  # Preserve absolute encoding when a zero-page form exists.
        out.append(f'{labels[pc]}:')
        out.append(f'    {op} {arg}'.rstrip() + ' ; $%04x  %s' % (pc, raw.hex(' ')))
        pc += len(raw)
    return '\n'.join(out) + '\n'


def reachable_ranges(data, base, entries):
    """Conservative static flow discovery; excludes indirect and runtime targets."""
    pending = list(entries)
    instructions = {}
    occupied = set()
    while pending:
        pc = pending.pop()
        while base <= pc < base + len(data) and pc not in occupied:
            token = ROWS[data[pc-base]]
            if token == '.':
                break
            op, mode = token.lower().split(':')
            end = pc + SIZES[mode]
            if end > base + len(data) or any(p in occupied for p in range(pc,end)):
                break
            instructions[pc] = end
            occupied.update(range(pc,end))
            value = int.from_bytes(data[pc-base+1:end-base],'little')
            if mode == 'r':
                pending.append((pc+2+(value if value < 128 else value-256)) & 65535)
            elif op in ('jsr','jmp') and mode == 'w':
                pending.append(value)
            if op in ('rts','rti','brk','jmp'):
                break
            pc = end
    ranges = []
    for start, end in sorted(instructions.items()):
        if ranges and ranges[-1][1] == start:
            ranges[-1] = (ranges[-1][0],end)
        else:
            ranges.append((start,end))
    return ranges
