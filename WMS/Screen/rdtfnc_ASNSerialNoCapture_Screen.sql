
-- Screen 1
DELETE rdt.RDTScn WHERE Scn = 5730 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5730, 'ENG', 
   @cLine01 = 'ASN: %20i01',
   @cLine14 = '%e',
   @nFunc   = 645

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 5731 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5731, 'ENG', 
   @cLine01 = 'ASN: %20d01',
   @cLine02 = 'SKU: %20i02',
   @cLine14 = '%e',
   @nFunc   = 645

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 5732 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5732, 'ENG', 
   @cLine01 = 'ASN: %20d01',
   @cLine02 = 'SKU: %20d02',
   @cLine03 = 'Pallet ID:',
   @cLine04 = '%20i03',
   @cLine14 = '%e',
   @nFunc   = 645

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 5733 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5733, 'ENG', 
   @cLine01 = 'ASN: %20d01',
   @cLine02 = 'SKU: %20d02',
   @cLine03 = 'Pallet ID:',
   @cLine04 = '%20d03',
   @cLine05 = 'BATCHNO:',
   @cLine06 = '%20i04',
   @cLine14 = '%e',
   @nFunc   = 645

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 5734 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5734, 'ENG', 
   @cLine01 = 'Carton SN:',
   @cLine02 = '%60i05',
   @cLine14 = '%e',
   @nFunc   = 645

-- Screen 6
DELETE rdt.RDTScn WHERE Scn = 5735 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5735, 'ENG', 
   @cLine01 = 'Carton SN:',
   @cLine02 = '%20d05',
   @cLine03 = 'BOTTLE SN:',
   @cLine04 = '%100iV_MAX',
   @cLine06 = 'Bot SN SCANNED:',
   @cLine07 = '%02d06 / %02d07 ',
   @cLine14 = '%e',
   @nFunc   = 645

