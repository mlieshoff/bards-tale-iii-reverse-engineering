import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT / 'tools'))
from d64 import Disk, SIZE, SECTORS, offset
from gamefs import physical_sector, directory, read_file
from disasm import decode, reachable_ranges


class GeometryTests(unittest.TestCase):
    def test_all_logical_sectors_map_to_every_physical_sector_once(self):
        expected = {(t,s) for t,n in enumerate(SECTORS,1) for s in range(n)}
        actual = [physical_sector(n) for n in range(683)]
        self.assertEqual(len(set(actual)),683)
        self.assertEqual(set(actual),expected)
        self.assertEqual(actual[664:],[(18,s) for s in range(18,-1,-1)])
        self.assertEqual(offset(35,16)+256,SIZE)

    def test_invalid_addresses_rejected(self):
        for t,s in [(0,0),(36,0),(18,19),(1,-1)]:
            with self.assertRaises(ValueError):
                offset(t,s)
        for n in [-1,683]:
            with self.assertRaises(ValueError):
                physical_sector(n)

    def test_file_chain_final_length_and_cycle(self):
        disk = Disk.__new__(Disk)
        raw = bytearray(SIZE)
        start = offset(1,0)
        raw[start:start+5] = b'\x00\x04abc'
        disk.data = bytes(raw)
        self.assertEqual(list(disk.chain(1,0)),[(1,0,b'abc')])
        raw[start:start+2] = b'\x01\x00'
        disk.data = bytes(raw)
        with self.assertRaisesRegex(ValueError,'cyclic'):
            list(disk.chain(1,0))

    def test_flow_does_not_treat_data_after_jump_as_code(self):
        data = bytes.fromhex('4c 05 20 ff ff 60')
        ranges = reachable_ranges(data,0x2000,[0x2000])
        self.assertEqual(ranges,[(0x2000,0x2003),(0x2005,0x2006)])
        self.assertEqual(len(decode(data,0x2000,ranges)),2)


@unittest.skipUnless((ROOT/'build/boot.d64').exists(),'run make verify first')
class ReconstructionTests(unittest.TestCase):
    def test_boot_prg_and_game_files_are_integrated_into_disk(self):
        disk = Disk(ROOT/'build/boot.d64')
        for entry, stem in zip(disk.directory(),('prodos','loader')):
            payload = b''.join(b for _,_,b in disk.chain(entry['track'],entry['sector']))
            self.assertEqual(payload,(ROOT/'build/boot'/f'{stem}.prg').read_bytes())
        entries = list(directory(disk))
        self.assertEqual(len(entries),10)
        self.assertEqual(entries[0]['name'],'BARD64.SYSTEM')
        self.assertEqual(entries[0]['load_address'],0x2000)
        for entry in entries:
            stem = entry['name'].lower().replace('.','-')
            self.assertEqual(read_file(disk,entry),(ROOT/'build/game'/f'{stem}.bin').read_bytes())
        self.assertEqual(disk.sector(18,13),(ROOT/'build/drive/bootstrap.bin').read_bytes())
        self.assertEqual(b''.join(disk.sector(18,s) for s in range(14,18)),
                         (ROOT/'build/drive/loader.bin').read_bytes())

if __name__ == '__main__':
    unittest.main()
