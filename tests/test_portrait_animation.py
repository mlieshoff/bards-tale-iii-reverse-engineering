import struct
import sys
from pathlib import Path
import tempfile
import unittest
import zlib

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from portrait_animation import animation_steps, apng_rgb


class AnimationTests(unittest.TestCase):
    def test_xor_delay_restart_and_short_end_marker(self):
        # Track 0: XOR $aa at first pixel byte, wait two ticks, restart.
        # End marker is allowed to omit the X byte which the engine discards.
        data = bytes([8,0,0,0,0,0,0,0, 13,0,0,2,0, 0xaa,0,255])
        frames, info = animation_steps(data, bytes(1), lambda col,line:0, max_ticks=10)
        self.assertEqual(info['active_tracks'],1)
        self.assertEqual(info['patch_applications'],2)
        self.assertEqual(info['loop_start_tick'],0)
        self.assertEqual([f[0] for f in frames],[b'\0',b'\xaa',b'\0'])
        self.assertEqual(frames[1][1],2)

    def test_coordinate_jump_and_bad_pointer(self):
        data = bytes([8,0,0,0,0,0,0,0, 13,0,0,1,0, 0,4,9,0x55,0,255])
        seen=[]
        frames, _ = animation_steps(data,bytes(1),lambda col,line:seen.append((col,line)) or 0,max_ticks=1)
        self.assertEqual(seen,[(4,9)])
        self.assertEqual(frames[-1][0],b'\x55')
        with self.assertRaisesRegex(ValueError,'outside decoded'):
            animation_steps(bytes([255,255])+bytes(6),bytes(1),lambda c,l:0)

    def test_apng_chunks_crc_sequence_and_pixels(self):
        with tempfile.TemporaryDirectory() as tmp:
            path=Path(tmp)/'test.apng'
            apng_rgb(path,1,1,[(b'\xff\0\0',1),(b'\0\xff\0',2)])
            raw=path.read_bytes()
        offset=8
        chunks=[]
        while offset < len(raw):
            length=struct.unpack_from('>I',raw,offset)[0]
            kind=raw[offset+4:offset+8]
            payload=raw[offset+8:offset+8+length]
            crc=struct.unpack_from('>I',raw,offset+8+length)[0]
            self.assertEqual(crc,zlib.crc32(kind+payload)&0xffffffff)
            chunks.append((kind,payload))
            offset+=length+12
        self.assertEqual([k for k,v in chunks],[b'IHDR',b'acTL',b'fcTL',b'IDAT',b'fcTL',b'fdAT',b'IEND'])
        self.assertEqual(struct.unpack('>II',chunks[1][1]),(2,1))
        self.assertEqual(zlib.decompress(chunks[3][1]),b'\0\xff\0\0')
        self.assertEqual(zlib.decompress(chunks[5][1][4:]),b'\0\0\xff\0')
