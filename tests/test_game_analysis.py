import sys
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from game_analysis import BitReader, packed_text, analyze_engine
from resources import decode_resource_bytes, read_resources
from inspect_assets import intro_picture, picture_rgb
from d64 import Disk


def bit_bytes(bits):
    bits += '0'*(-len(bits)%8)
    return bytes(int(bits[n:n+8],2) for n in range(0,len(bits),8))


class DecoderTests(unittest.TestCase):
    def test_msb_first_bit_reader_and_truncation(self):
        bits=BitReader(bytes([0b10110001]))
        self.assertEqual(bits.read(3),5)
        self.assertEqual(bits.read(5),17)
        self.assertEqual(bits.end,1)
        with self.assertRaisesRegex(ValueError,'truncated'):
            bits.read(1)

    def test_packed_text_case_shift_and_escape(self):
        chars=bytearray(94)
        chars[2]=0xe1
        chars[35]=0xa1
        bits='11110'+'00010'+'00010'+'11111'+'000101'+'00000'
        text,end=packed_text(bit_bytes(bits),0,chars)
        self.assertEqual(text,'Aa!')
        self.assertEqual(end,4)

    def test_dictionary_literals_and_run_tokens(self):
        dictionary=bytes(range(20))
        # Literal Z; dictionary entries using 3/4/5/6-bit codes; run of three $aa.
        bits=('0'+'01011010'+'1'+'000'+'1'+'001'+'1'+'0100'+
              '1'+'10110'+'1'+'111100'+'1'+'111111'+'00000011'+'10101010')
        data=dictionary+bit_bytes(bits)
        decoded,used=decode_resource_bytes(data,9)
        self.assertEqual(decoded,bytes([0x5a,0,1,2,9,17,0xaa,0xaa,0xaa]))
        self.assertEqual(used,len(data))
        with self.assertRaises(ValueError):
            decode_resource_bytes(data[:20],1)


@unittest.skipUnless((ROOT/'build/boot.d64').exists(),'run make verify first')
class ActualGameTests(unittest.TestCase):
    def test_overlay_and_disk_references(self):
        all_resources={slug:read_resources(Disk(ROOT/f'build/{slug}.d64'))
                       for slug in ('character','dungeon-a','dungeon-b')}
        shared=all_resources['character'][0].payload
        self.assertEqual(len(shared),7205)
        for records in all_resources.values():
            self.assertEqual(records[0].payload,shared)
            self.assertEqual(records[0].destination,0x9b00)
            self.assertEqual(len(records),384)
        ref=all_resources['character'][2]
        self.assertEqual(ref.kind,'disk-reference')
        self.assertEqual(ref.disk_id,2)
        self.assertEqual(ref.stream_offset,all_resources['character'][3].stream_offset)
        self.assertEqual(all_resources['character'][29].destination,0x1040)

    def test_inline_text_is_not_decoded_as_instructions(self):
        payloads={s:(ROOT/f'build/game/{s}.bin').read_bytes() for s in ('bardsubs1','bardsubs2')}
        payloads['combat']=read_resources(Disk(ROOT/'build/character.d64'))[0].payload
        analysis=analyze_engine(payloads)
        self.assertEqual(analysis.inline[0x67fe],(0x680c,"Packed text: 'Please insert your '"))
        battle_menu=[note for _,note in analysis.inline.values() if 'Fight bravely' in note]
        self.assertTrue(battle_menu)
        for start,(stop,_) in analysis.inline.items():
            for pc,(_,_,_,raw) in analysis.code.items():
                self.assertFalse(set(range(start,stop)) & set(range(pc,pc+len(raw))))
        self.assertNotIn(0x678f,analysis.code)  # Resource pointer table.
        self.assertNotIn(0xffff,analysis.code)  # Self-modifying call placeholder.
        self.assertIn(0x74fa,analysis.overlaps)  # LDY #5 inside BIT's operand.

    def test_picture_decoding_consumes_entire_input(self):
        mainpic=(ROOT/'build/game/mainpic64.bin').read_bytes()
        splash=(ROOT/'build/game/splash64.bin').read_bytes()
        bitmap,consumed=intro_picture(mainpic,splash)
        self.assertEqual(consumed,len(mainpic))
        self.assertEqual(len(bitmap),8000)
        self.assertGreater(len(set(bitmap)),64)
        rgb=picture_rgb((ROOT/'build/game/bard3-pic64.bin').read_bytes())
        self.assertEqual(len(rgb),320*192*3)

if __name__=='__main__':
    unittest.main()
