"""Evidence-based game module analysis shared by importer and reports.

Static classification is a lower bound: runtime callbacks and disk overlays can
contain more code. Inline text/arguments are explicitly excluded from code.
"""
from dataclasses import dataclass, field
from disasm import ROWS, SIZES, decode, render

BASES = {'bardsubs1':0x6600, 'bardsubs2':0xcd00, 'music64':0xc480,
         'dmusic64':0xe000, 'splash64':0x4000, 'util64':0x2000, 'combat':0x9b00}
NAMES = {
    0xa314:'choose_battle_strategy',0x9c4f:'dispatch_party_action',
    0x9f0c:'dispatch_enemy_action',0x9b00:'combat_overlay',0x6600:'enter_engine', 0x6654:'load_current_mode_resource',
    0x665c:'load_cached_resource_x',0x667d:'load_cached_overlay_x',
    0x668d:'load_resource_by_id',0x67ad:'write_resource_byte',
    0x67b9:'require_disk_id',0x67c7:'check_disk_and_read_index',
    0x67fb:'prompt_for_disk',0x685c:'resource_destination_class',
    0x687a:'restart_overlay_with_clean_stack',0x6880:'load_area_resources',
    0x68b9:'load_cached_variant_x',0x68c9:'load_picture_pair',
    0x6917:'read_resource_bytes',0x6a40:'save_loader_workspace',
    0x6a4b:'restore_loader_workspace',0x6aa4:'read_block_to_staging',
    0x6aac:'transfer_next_block',0x6f16:'for_each_party_member_inline',
    0x7407:'print_inline_packed_text',0x740a:'print_inline_text_without_reset',0x7419:'print_packed_text_xy',
    0x7465:'reset_text_bit_reader',0x746f:'decode_text_character',
    0x74f7:'read_six_text_bits',0x74fa:'read_five_text_bits',
    0x751c:'print_unpacked_text_xy',0x8299:'initialize_resource_decoder',
    0x82b8:'decode_resource_byte',0x8330:'read_resource_bits',
    0x848e:'output_text_character',0x8b0f:'read_input_with_inline_flags',
    0x91e2:'party_member_pointer_a',0x91e4:'party_member_pointer_x',
    0xfd8a:'raster_irq',0xfdb9:'nmi_return',0xfdba:'tick_countdowns',
    0xfe4d:'dequeue_keyboard_character',0xfe6c:'scan_keyboard_matrix',
    0xff24:'read_keyboard_column',0xff30:'consume_key',0xff3b:'peek_key',
    0xff3e:'mix_random_byte',0xff5b:'initialize_engine',0xffbe:'clear_party_record',
}
# Only known data boundaries; executable overlap bytes are detected separately.
DATA = [(0x678f,0x67a7),(0x6821,0x685c),(0x686e,0x6876),
        (0x6ad2,0x6ad9),(0x749b,0x74f7),
        (0x9cf0,0x9d16),(0x9d8c,0x9d9e),(0x9f71,0x9f99)]
COMMENTS = {
0xcd00: 'Tables/data begin this module; $cd00 is NOT an execution entry.\nBARDSUBS2 occupies RAM beneath I/O/ROM. A $dxxx reference can refer\nto these tables when $01=$34; do not automatically label it a VIC/SID access.',
0xcd48: 'Low-byte enemy/combat record pointers, indexed by combatant group.\nThe corresponding high bytes are at $cd4c; used by combat dispatch.',
0xd522: 'Seven party-record pointers: $3e00,$3e80,$3f00,$3f80,$bf00,$bf80,$1f80.\nResident helper $91e4 loads one of these into $12/$13.\nStartup clears 120 bytes per record, although the records are spaced by 128.',
0xe273: 'Item maximum-charge table, indexed by item ID (1..255).\n$ff is nondepleting; finite loot charges can be randomized at $af60.\n$70e8 tests for one-use items when removing exhausted inventory entries.',
0xe373: 'Item melee damage dice. $7924 returns this byte in X; $ac48/$ac74\nroll it via $fa5a: (low5+1)d(mask[high3]+1). Broadsword=$21: 2d4.',
0xe473: 'Item armor/damage bonuses. Low nibble reduces displayed AC\n($fc56/$fc85); high nibble adds melee damage ($ab6a..$ab6f).\nMthr Sword=$20: +2 damage; Shield Staff=$12: AC-2 and +1 damage.',
0xe573: 'Item type and attack effect. Low nibble indexes category names\nthrough $7009: weapon=1, shield=2, armor=3, helm=4, gloves=5,\ninstrument=6, figurine=7, ring=8, wand=9, bow=11, quiver=12.\nHigh nibble selects attack effect ($ab64..$ab68); retain numeric codes.',
0xe673: 'Item usable-class mask. $7189 ANDs this with class table $d987.\nClasses share bits; this is not one bit per class. Mandolin=$08 (Bard).',
0xe773: 'Item equipped-effect byte. Low nibble is matched by $6f9e and\nreturned for equipped instruments by $6fd6; e.g. Bardsword selector 5.\nUpper bits and complete selector names remain unresolved.',
0xe873: 'Item use-effect ID: spell or special action, $ff means no use effect.\nLocal item catalogue matches Torch=$7e, Lamp=$7f, thrown weapons=$83,\nfigurines=$84; keep IDs numeric until the dispatch mapping is established.',
0x7924: 'Load item properties: X=item ID on entry. Returns A=type/effect,\nX=damage dice, Y=armor/damage bonus, $57=usable-class mask.',
0x9f2b: 'Choose one of four monster actions at record offsets $16..$1d.\nFirst byte is spell ID (<$80) or special/physical opcode; second byte\nis action-dependent. $f0..$f9 use it as damage dice ($ad83/$fa5a).',
0xa053: 'Monster offset $13 packs distance in 10-foot units: low nibble\nis current distance; high nibble is the amount advanced ($a0af).',
0xb377: 'Monster record offset $20 is the portrait resource ID, passed\nto load_picture_pair ($68c9). Local monster appearance list can be\nused to compare shared portraits; it does not specify combat stats.',
0xed2a: 'Indexed action/property flags used by resident and combat code.\nMasks $07 and $20 occur in callers; full format is not yet established.',
0xa314: 'Battle strategy menu. Packed prompts offer Fight bravely,\nAdvance ahead, and Run away. Input processing selects the next battle phase.',
0x9c4f: 'Party action dispatcher. X selects a party slot; get its record\nthrough $d522/$d523, check presence/status, then dispatch using\naction code at $032a,X or the record action fields.\nThe exact names of all action values are not yet established.',
0x9f0c: 'Enemy action dispatcher. Select a combatant record through\n$cd48/$cd4c; use action descriptors and the $9f71 jump table.\nDo not decode that pointer table as executable instructions.',
0x9cf0: 'Special party-action handler address table (19 little-endian pointers).',
0x9d8c: 'Party command handler address table (9 little-endian pointers).',
0x9f71: 'Special enemy-action handler address table (20 little-endian pointers).',
0x9b00: 'Combat overlay: resource 0, shared by all three data disks, at $9b00.\nBattle menus, party/enemy actions, spell/item dispatch, and rewards.\nPreserve action state, request music command $81, and wait for the\nIRQ-driven player to consume it before continuing the game loop.\nResident helpers live in BARDSUBS1/BARDSUBS2; other overlays can\nreplace this address range, so a runtime memory map is still required.',
0x6600: 'Engine re-entry. Clears bit 0 of $d3; A selects mode/resource.\nA=$fe/$ff take the special resource path; $08 caches ordinary modes.\nSeveral exits reset SP and JMP $9b00: this is an overlay transition, not RTS.',
0x662f: 'Mode zero: derive resource ID from $0c + $1d. Cache it in $03.\n$1053/$1054 choose additional resources; field meanings remain unverified.',
0x6654: 'Translate cached mode $08 to resource ID (mode + 1).',
0x665c: 'Skip reload if X matches $04. Otherwise load resource X+$69,\nthen pad with $20 until the self-modifying output pointer reaches $4780.',
0x667d: 'Cache X in $06, load resource X while preserving A, then JMP $9300.\n$9300 is outside this module and is an overlay execution address.',
0x668d: 'Resource lookup. Input: 16-bit ID $6ad2:$35 (high:low).\nScan 16-bit size entries at $4000. Sum preceding sizes into the\n24-bit byte offset $be57:$be56:$be55, initially $000300.\nA high size byte $ff marks a disk-change record rather than payload.\n$be4b/$be4c = destination; $be4d/$be4e = byte count. Carry reports failure.',
0x678f: 'Eight little-endian resource destinations: $9b00,$9300,$a800,$ad00,\n$1040,$4780,$4300,$0800. The next four words give end limits\n$1f80,$6600,$4780,$1040 for compressed classes 4..7.',
0x6821: 'Four disk-name pointers: Boot, Character, Dungeon A, Dungeon B.\nThese point to packed strings at $6829,$6831,$683c,$684c.',
0x686e: 'Resource-class thresholds: 0,4,13,23,29,100,105,146. IDs below\n29 select code overlays; later classes select compressed resource buffers.',
0x6ad2: 'Mutable loader state: ID high byte, load/decode mode, output end,\nstaging start, and required disk ID. These bytes are not instructions.',
0x749b: 'Character translation table for packed text (base is $749a).\nFive-bit symbols cover common characters; symbol 31 escapes to six bits.',
0x6700: 'Classify resource ID, then select its load/decode destination.\nThe address table at $678f is DATA, not executable instructions.',
0x673f: 'Compressed path: stage compressed bytes immediately below the\nfinal buffer end, initialize the bit decoder, and expand using decode_resource_byte.',
0x676c: 'Decode and emit until the compressed source pointer reaches its limit.\nTwo final decoder calls follow; their format role is not established.',
0x67ad: 'Self-modifying output cursor. $67ae/$67af are the operand bytes\nof this STA, patched before entry. Emit A and advance the 16-bit pointer.',
0x67b9: 'Complement a disk marker to obtain expected disk ID. Repeatedly\ncheck the disk and prompt until its ID matches. Do not assume this returns normally.',
0x67c7: 'Read/check block zero, compare $bbff with expected disk ID at $6ad8.\nOn a match, read $0300 bytes into $4000 (the resource-size index).\nThe success path discards one return address using two PLA instructions.',
0x67fb: 'Print an inline packed disk-insertion prompt, select a disk name\nthrough the pointer table at $6821, then request input and reset the text area.',
0x685c: 'Choose one of eight resource classes using ID thresholds at $686e.\nNonzero high ID byte selects class 7 directly.',
0x687a: 'Discard the entire current call chain (SP=$ff), then execute overlay $9b00.',
0x6880: 'Load resource ($35+$27) if changed, select variant using $1050,\nand another resource using $105d. Saved carry controls coordinate adjustments.',
0x68b9: 'Variant cache $05; map X to resource X+$64.',
0x68c9: 'Load an ID-derived resource pair, decode picture data, then draw it.\nIDs >= $fe route to an alternate rendering path. Exact picture IDs are unknown.',
0x6917: 'Read a byte range from the game resource stream, not a DOS file.\nConvert 24-bit byte offset to 512-byte block number (+1), copy partial\nfirst/last blocks through $ba00/$bb00, transfer full blocks directly.\nUses $be4b..$be4e and $be55..$be57; saves/restores zero-page workspace.',
0x6aa4: 'Set staging buffer to $ba00; continue into next-block transfer.',
0x6aac: 'Set read command $42=1 and call the $be7a wrapper, which invokes\nthe boot loader block API at $c208. Advance block number $46/$47.',
0x6f16: 'Inline callback convention: JSR followed by a little-endian routine address.\nRemove return address, advance it by two argument bytes, and put it back.\nLoop X=0,2,...,12 over seven party slots via $91e4; call the inline\ncallback using the patched JSR at $6f3e. $12/$13 points to the member.',
0x7407: 'Inline packed-string convention: text bits immediately follow the JSR.\nPull the caller return address, start decoding at the next byte,\nthen JMP through the advanced text cursor at $7503 after the terminator.\nThe packed bytes after callers of this routine are DATA, not instructions.',
0x740a: 'Alternate packed-text entry: skip the $8673 display reset and\ncontinue with the same inline string / continuation convention as $7407.',
0x7419: 'Input X/Y = compressed text address (low/high). Decode symbols\nand send characters to $848e. $af/$dc delimit conditional text sections\nselected by $4f. Return X/Y points past consumed compressed bytes.',
0x7465: 'Mark packed input byte empty ($b7=$ff), clear one-character case state $b9.',
0x746f: 'Read a 5-bit symbol, MSB first. 0 ends the string; 30 shifts case;\n31 reads six more bits and adds 30. Translate using the table at $749a.\nThe pending case bit uppercases the next lowercase character.',
0x74f7: 'Overlapping entry points: read_six_text_bits uses LDY #6 and\nBIT $05a0 to skip LDY #5 at $74fa. Shared bit-reader starts at $74fc.\nThe five overlapping bytes are deliberately emitted with !byte.',
0x751c: 'Unpacked character-string printer. Input X/Y is source pointer;\n$ff terminates. Handles the same conditional $af/$dc delimiters.',
0x8299: 'Input X/Y = compressed resource stream. Reset run/bit state,\nthen read a 20-byte literal dictionary into $021f..$0232.',
0x82b8: 'Return next decompressed byte in A. An active run repeats $19.\nOtherwise a leading zero reads an 8-bit literal; leading one decodes\na variable-length dictionary token or a run (8-bit count + value).',
0x8330: 'Read X bits MSB first into A. Source is a self-modifying LDA\nwhose operand is $833c/$833d. $16 counts buffered bits; $b2 holds input.',
0x848e: 'Character output entry used by packed and unpacked text printers.\nDetailed layout/control-code behavior remains to be traced.',
0x8b0f: 'Inline input convention: two flag bytes follow the JSR.\nPatch the caller return address to skip them; store flags at $8cc3/$8cc4.\nPoll keyboard and selection handling; uppercase conversion depends on flags.',
0x91e2: 'Party slot in A is doubled before falling into party_member_pointer_x.',
0x91e4: 'X indexes low/high pointer pairs. Read pointer from $d522/$d523\ninto $12/$13; the caller uses this as the party-record address.',
0xfd8a: 'Preserve A/X/Y and memory mapping, acknowledge VIC raster IRQ.\nScan keyboard, dequeue input, call relocated MUSIC64 vector $c48c,\nthen update timers. Restore mapping and registers before RTI.',
0xfdb9: 'NMI vector installed by initialize_engine points directly to this RTI.',
0xfdba: 'Decrement short timers every IRQ; divide by $3c for slower timers.\nThis is a frame divider in code, not proof of a real-time second on every video standard.',
0xfe6c: 'Drive CIA1 keyboard columns at $dc00; read/debounce rows at $dc01.\nTranslate keys through $fe0d and queue character codes at $fedc onward.',
0xff5b: 'Engine startup after resources have loaded. Initialize caches and\nzero-page state; install IRQ=$fd8a and NMI=$fdb9; enable raster IRQs.\nClear seven party records through the inline callback helper, then\nload overlay $0c at $9300 and enter the main engine at $6600.',
}
HW = {0x0000:'6510 processor-port direction',0x0001:'6510 memory mapping',
      0xc208:'fast-loader logical block API',0xbe02:'named-file loader wrapper',
      0xd011:'VIC display control 1',0xd012:'VIC raster line',0xd016:'VIC display control 2',
      0xd018:'VIC screen/bitmap base selection',0xd019:'VIC interrupt status',
      0xd01a:'VIC interrupt enable',0xd020:'VIC border color',0xd021:'VIC background color',
      0xd400:'SID voice frequency low (+Y voice offset)',0xd401:'SID voice frequency high',
      0xd402:'SID pulse width low',0xd403:'SID pulse width high',0xd404:'SID voice control',
      0xd405:'SID attack/decay',0xd406:'SID sustain/release',0xd40b:'SID voice 2 control',
      0xd412:'SID voice 3 control',0xd415:'SID filter cutoff low',0xd416:'SID filter cutoff high',
      0xd417:'SID filter routing/resonance',0xd418:'SID volume/filter mode',
      0xdc00:'CIA1 keyboard column output',0xdc01:'CIA1 keyboard row input',
      0xfffa:'RAM NMI vector low',0xfffb:'RAM NMI vector high',
      0xfffe:'RAM IRQ vector low',0xffff:'RAM IRQ vector high / unpatched operand placeholder'}


class BitReader:
    def __init__(self, data, offset=0):
        self.data, self.bit = data, offset*8

    def read(self, count):
        value = 0
        for _ in range(count):
            if self.bit >= len(self.data)*8:
                raise ValueError('truncated bit stream')
            value = value*2 + ((self.data[self.bit//8] >> (7-self.bit%8)) & 1)
            self.bit += 1
        return value

    @property
    def end(self):
        return (self.bit+7)//8


def packed_text(data, offset, charset):
    bits = BitReader(data,offset)
    out, upper = [], False
    for _ in range(4096):
        symbol = bits.read(5)
        if symbol == 0:
            return ''.join(out), bits.end
        if symbol == 30:
            upper = True
            continue
        if symbol == 31:
            symbol = bits.read(6)+30
        if symbol >= len(charset):
            raise ValueError('invalid text symbol')
        char = charset[symbol]
        if upper and 0xe1 <= char < 0xfb:
            char &= 0xdf
        upper = False
        char &= 127
        out.append(chr(char) if 32 <= char < 127 else f'<${char:02x}>')
    raise ValueError('unterminated packed text')


@dataclass
class Analysis:
    code: dict = field(default_factory=dict)
    inline: dict = field(default_factory=dict)
    overlaps: set = field(default_factory=set)


def analyze_engine(payloads):
    """Follow resident engine calls across both modules, respecting inline data."""
    stems = [s for s in ('bardsubs1','bardsubs2','combat') if s in payloads]
    regions = [(BASES[s],BASES[s]+len(payloads[s]),s) for s in stems]
    memory = {BASES[s]+n:b for s in stems for n,b in enumerate(payloads[s])}
    charset = payloads['bardsubs1'][0x749a-0x6600:0x74f7-0x6600]
    result = Analysis()
    pending = [0x6600,0xff5b,0xfd8a,0xfdb9,0x68c9,0x751c]
    if 'combat' in payloads:
        pending.append(0x9b00)
        # Proven JMP ($12) dispatch tables, each loaded as paired bytes.
        for start,stop in [(0x9cf0,0x9d16),(0x9d8c,0x9d9e),(0x9f71,0x9f99)]:
            for addr in range(start,stop,2):
                pending.append(memory[addr] | memory[addr+1]<<8)
    blocked = set(p for a,z in DATA for p in range(a,z))
    visited = set()
    inverse = {'bcc':'bcs','bcs':'bcc','beq':'bne','bne':'beq','bmi':'bpl','bpl':'bmi','bvc':'bvs','bvs':'bvc'}
    while pending:
        pc = pending.pop()
        previous = None
        while pc in memory and pc not in visited and pc not in blocked:
            visited.add(pc)
            token = ROWS[memory[pc]]
            if token == '.':
                break
            op, mode = token.lower().split(':')
            size = SIZES[mode]
            if any(pc+n not in memory or pc+n in blocked for n in range(size)):
                break
            raw = bytes(memory[pc+n] for n in range(size))
            val = int.from_bytes(raw[1:],'little')
            end = pc+size
            if mode == 'r':
                val = (end + (val if val<128 else val-256)) & 65535
                pending.append(val)
            elif op in ('jsr','jmp') and mode == 'w':
                # $ffff is a self-modified call operand, not an actual entry.
                if val != 0xffff:
                    pending.append(val)
            result.code[pc] = (op,mode,val,raw)
            if op == 'jsr' and val in (0x7407,0x740a,0x6f16,0x8b0f):
                if val in (0x7407,0x740a):
                    region = next((r for r in regions if r[0]<=end<r[1]),None)
                    if region is None:
                        break
                    base,_,stem = region
                    text, off = packed_text(payloads[stem],end-base,charset)
                    next_pc = base+off
                    note = 'Packed text: '+repr(text)
                else:
                    if end not in memory or end+1 not in memory:
                        break
                    value = memory[end] | memory[end+1]<<8
                    next_pc = end+2
                    if val == 0x6f16:
                        pending.append(value)
                        note = f'Inline party callback: ${value:04x}'
                    else:
                        note = f'Inline input flags: ${value & 255:02x}, ${value >> 8:02x}'
                        if value & 0x40:
                            note += '; following variable filter table remains unresolved'
                result.inline[end] = (next_pc,note)
                blocked.update(range(end,next_pc))
                if val == 0x8b0f and value & 0x40:
                    break  # Input helper can consume a variable filter table too.
                end = next_pc
            if op in ('rts','rti','brk','jmp'):
                break
            if mode == 'r' and ((previous == 'clc' and op == 'bcc') or
                                (previous == 'sec' and op == 'bcs') or
                                inverse.get(previous) == op):
                break  # Known taken branch or complementary branch pair.
            previous = op
            pc = end
    # Overlapping code is valid on 6502 (e.g. BIT skipping a short instruction).
    # Keep those bytes raw instead of inventing a single instruction alignment.
    owners = {}
    for pc,(_,_,_,raw) in result.code.items():
        for p in range(pc,pc+len(raw)):
            owners.setdefault(p,[]).append(pc)
    conflicting = {pc for pcs in owners.values() if len(pcs)>1 for pc in pcs}
    for pc in conflicting:
        result.overlaps.update(range(pc,pc+len(result.code[pc][3])))
    for pc in list(result.code):
        if pc in conflicting or any(p in blocked for p in range(pc,pc+len(result.code[pc][3]))):
            del result.code[pc]
    return result


def annotated_source(data, base, analysis, header, names=None, comments=None):
    names = dict(NAMES if names is None else names)
    comments = dict(COMMENTS if comments is None else comments)
    ranges = [(pc,pc+len(info[3])) for pc,info in sorted(analysis.code.items()) if base<=pc<base+len(data)]
    text = render(data,base,ranges,names)
    code = {pc:info for pc,info in analysis.code.items() if base<=pc<base+len(data)}
    for pc,(_,mode,val,_) in code.items():
        if pc not in comments and mode not in ('i','a','n','r') and val in HW:
            comments[pc] = HW[val] + (' (I/O only when $01 exposes it)' if 0xd000 <= val < 0xe000 else '')
    notes = {a:note for a,(_,note) in analysis.inline.items()}
    notes.update({a:c for a,c in comments.items() if base<=a<base+len(data)})
    referenced = {val for _,mode,val,_ in code.values() if mode in ('r','w','wx','wy','ind')}
    keep_labels = {names.get(pc,f'l_{pc:04x}') for pc in code if pc in referenced or pc in names}
    # Split raw byte directives at annotation boundaries, retaining exact bytes.
    out = [header.rstrip(),'!cpu 6510',f'* = ${base:04x}']
    for line in text.splitlines():
        if line.endswith(':'):
            label = line[:-1]
            pc = next((p for p in code if names.get(p,f'l_{p:04x}') == label),None)
            if pc in notes:
                out += ['',*(('; '+s) for s in notes[pc].splitlines())]
        if '!byte' in line:
            addr = int(line.split('; $')[1].split()[0],16)
            values = line.split('!byte ')[1].split(' ;')[0].split(',')
            chunk = []
            chunk_start = addr
            for n,value in enumerate(values):
                pc=addr+n
                if pc in notes:
                    if chunk:
                        out.append('    !byte '+','.join(chunk))
                        chunk=[]
                    chunk_start=pc
                    out += ['',*(('; '+s) for s in notes[pc].splitlines())]
                chunk.append(value)
            if chunk:
                out.append('    !byte '+','.join(chunk)+f' ; ${chunk_start:04x} retained data / unresolved code')
        else:
            if not line.endswith(':') or line[:-1] in keep_labels:
                out.append(line)
    return '\n'.join(out)+'\n'


def module_source(stem, data):
    """Render nonresident modules with separately established runtime mappings."""
    from disasm import reachable_ranges
    base=BASES[stem]
    if stem in ('music64','dmusic64'):
        entries=[base+n for n in (0,3,6,9,12)]
        names={base:'music_vector_0',base+3:'music_vector_1',base+6:'music_vector_2',
               base+9:'music_vector_3',base+12:'music_tick_vector',base+15:'music_noop',
               base+16:'request_music_command_zero',base+23:'process_music_frame'}
        comments={base:'SID player plus music data, not a sampled sound file.\nFive JMP vectors lead into executable player code.\nMUSIC64 is copied from $4800 to $c480 by startup; DMUSIC64 runs at $e000.',
                  base+16:'Store $80 in command mailbox $ba: command zero with request bit set.',
                  base+23:'Preserve interrupt flags and stack state; apply volume from $33,\nconsume command mailbox $ba, advance player state, and update SID registers.\nEngine raster IRQ calls vector +12 once per acknowledged raster interrupt.'}
    elif stem=='splash64':
        entries=[0x4000,0x47b0,0x47de]
        names={0x4000:'run_intro',0x4726:'initialize_intro_display',
               0x47b0:'intro_raster_irq',0x47de:'intro_nmi_return',
               0x480b:'decode_intro_picture',0x4869:'decode_intro_resource_byte',
               0x48e7:'read_intro_bits',0x4909:'clear_intro_bitmap'}
        comments={0x4000:'Mixed executable intro, fonts/tables, and picture/presentation data.\nInitialize display; decode MAINPIC64 from $0800 into bitmap RAM.\nInstall raster IRQ, drive DMUSIC64 at $e000, animate, and wait for keyboard input.',
                  0x47b0:'Preserve registers and memory mapping; acknowledge raster IRQ,\nfeed music request $87 when idle, and call DMUSIC64 vector $e00c.',
                  0x480b:'Read a 20-byte dictionary from X/Y input. Expand dictionary/run tokens\nand XOR each decoded byte with the previous output while plotting to\naddress tables. This XOR step is in the picture caller, not the token decoder.',
                  0x4869:'Dictionary/run token reader corresponding to BARDSUBS1 $82b8.',
                  0x4909:'Clear 30 pages starting at $2000 ($1e00 bytes of bitmap storage).'}
    else:
        entries=[0x2000]
        names={0x2000:'run_utility_module'}
        comments={0x2000:'Executable utility module loaded at $2000 and called by startup.\nContains code and embedded data; remaining routine roles need analysis.\nThe entry saves the current stack pointer at $22eb and invokes $25ab.'}
    ranges=reachable_ranges(data,base,entries)
    analysis=Analysis(code=decode(data,base,ranges))
    return annotated_source(data,base,analysis,
        '; '+stem.upper()+' -- static code/data classification; unresolved bytes retained.',names,comments)
