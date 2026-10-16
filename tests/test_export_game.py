import hashlib
import json
from pathlib import Path
import struct
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from export_game import decoded_prefix, monster_records, item_records, portrait_rgb, sid_file, ITEM_TABLES
from resources import read_resources
from d64 import Disk


class MonsterTests(unittest.TestCase):
    def test_hp_formula_and_unknown_bytes_preserved(self):
        raw=bytearray(48)
        raw[:16]=b'Test Monster'+b'\xff'*4
        raw[16]=(2<<5)|3  # 4d8
        raw[17:19]=(10).to_bytes(2,'little')
        raw[19]=0x25  # current distance 50 feet, advance 20 feet
        raw[22:26]=bytes([0xf0,0x21,7,0xff])  # physical 2d4; spell parameter is not dice
        raw[32]=146
        raw[47]=99
        record=monster_records(bytes(raw),[1,3,7,15,31,63,127,255])[0]
        self.assertEqual(record['name'],'Test Monster')
        self.assertEqual(record['distance'],dict(current_10_feet=5,advance_10_feet=2))
        self.assertEqual(record['portrait_resource_id'],146)
        self.assertEqual(record['actions'][0]['damage'],
                         dict(dice_count=2,dice_sides=4,minimum=2,maximum=8))
        self.assertEqual(record['actions'][1]['spell_id'],7)
        self.assertNotIn('damage',record['actions'][1])
        self.assertEqual(record['hit_points'],dict(dice_count=4,dice_sides=8,bonus=10,minimum=14,maximum=42))
        self.assertEqual(bytes(record['raw_bytes']),bytes(raw))
        with self.assertRaisesRegex(ValueError,'48-byte'):
            monster_records(bytes(raw[:-1]),[1]*8)


@unittest.skipUnless((ROOT/'build/character.d64').exists(),'run make verify first')
class ActualExportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.subs1=(ROOT/'build/game/bardsubs1.bin').read_bytes()
        cls.subs2=(ROOT/'build/game/bardsubs2.bin').read_bytes()
        cls.resources=read_resources(Disk(ROOT/'build/character.d64'))

    def test_monster_bank_record_boundary(self):
        raw=self.resources[105].payload
        decoded,used=decoded_prefix(raw,1152)
        self.assertEqual(len(decoded),16*48)
        self.assertEqual(used,len(raw))
        rows=monster_records(decoded,[1,3,7,15,31,63,127,255])
        self.assertEqual(rows[0]['name'],'Hookfang')
        self.assertEqual(rows[-1]['name'],'Gila monster')
        self.assertEqual(b''.join(bytes(row['raw_bytes']) for row in rows),decoded)

    def test_item_names_and_property_bounds(self):
        items=item_records(self.subs1,self.subs2)
        self.assertEqual(len(items),255)
        self.assertEqual([item['name'] for item in items[:3]],['Torch','Lamp','Broadsword'])
        self.assertEqual(set(items[0]['properties']),set(ITEM_TABLES))
        self.assertEqual(len(items[0]['properties']),7)
        self.assertEqual(items[-1]['id'],255)
        # Independent item-catalogue examples, not merely decoder round trips.
        self.assertEqual(items[2]['melee_damage'],
                         dict(dice_count=2,dice_sides=4,bonus=0,minimum=2,maximum=8))
        self.assertEqual(items[22]['melee_damage']['bonus'],2)  # Mthr Sword
        self.assertEqual(items[44]['armor_class_reduction'],2)  # Shield Staff
        self.assertEqual(items[44]['melee_damage']['minimum'],2)
        self.assertIsNone(items[12]['melee_damage'])  # Chain Mail
        for item in items:
            for name,address in ITEM_TABLES.items():
                self.assertEqual(item['properties'][name],self.subs2[address-0xcd00+item['id']])

    def test_portrait_complete_input_and_dimensions(self):
        frame=(ROOT/'build/game/bard3-pic64.bin').read_bytes()
        resource=self.resources[146]
        width,height,pixels,used=portrait_rgb(resource.payload,self.subs1,self.subs2,frame)
        self.assertEqual((width,height),(88,88))
        self.assertEqual(len(pixels),88*88*3)
        self.assertEqual(used,len(resource.payload))
        self.assertGreater(len(set(pixels)),4)

    def test_sid_container_preserves_original_player(self):
        for stem,base in [('music64',0xc480),('dmusic64',0xe000)]:
            payload=(ROOT/f'build/game/{stem}.bin').read_bytes()
            sid=sid_file(payload,base,'test')
            self.assertEqual(sid[:4],b'PSID')
            version,offset,load,init,play,songs,start,speed=struct.unpack_from('>7HI',sid,4)
            self.assertEqual((version,offset,songs,start,speed),(2,124,17,1,0))
            self.assertEqual((load,init,play),(base-128,base-128,base-64))
            self.assertEqual(sid[offset+128:],payload)
            self.assertEqual(sid[offset+64:offset+71],bytes([0xa9,0x35,0x85,0x01,0x4c,(base+12)&255,(base+12)>>8]))


@unittest.skipUnless((ROOT/'extracted/manifest.json').exists(),'run make extract first')
class ExportManifestTests(unittest.TestCase):
    def test_all_exported_files_match_manifest_and_json_schemas(self):
        folder=ROOT/'extracted'
        manifest=json.loads((folder/'manifest.json').read_text())
        for entry in manifest['files']:
            content=(folder/entry['path']).read_bytes()
            self.assertEqual(len(content),entry['size'],entry['path'])
            self.assertEqual(hashlib.sha256(content).hexdigest(),entry['sha256'],entry['path'])
            if entry['path'].endswith('.json'):
                self.assertEqual(json.loads(content)['schema_version'],
                                 2 if Path(entry['path']).name in ('items.json','monsters.json') else 1)
        counts=manifest['counts']
        self.assertEqual(counts['monster_banks'],41)
        self.assertEqual(counts['monster_records'],575)
        self.assertEqual(counts['unique_portrait_pngs'],85)
        monsters=json.loads((folder/'data/monsters.json').read_text())
        self.assertEqual(sum(len(bank['records']) for bank in monsters['banks']),575)
        items=json.loads((folder/'data/items.json').read_text())
        self.assertTrue(all(len(item['properties'])==7 for item in items['records']))
        pictures=json.loads((folder/'data/pictures.json').read_text())
        for picture in pictures['portraits']:
            self.assertTrue((folder/picture['file']).is_file())

if __name__=='__main__':
    unittest.main()
