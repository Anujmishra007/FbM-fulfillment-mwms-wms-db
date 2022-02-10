-- 4220-4229

-- 4220 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4220 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4220, 'ENG', 
   @cLine01 = 'ASN: %10i01',
   @cLine14 = '%e',
   @nFunc = 599

-- 4221 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4221 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4221, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18i02',
   @cLine14 = '%e',
   @nFunc = 599

-- 4222 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4222 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4222, 'ENG', 
   @cLine01 = '%18d01',
   @cLine02 = 'SKU:',
   @cLine03 = '%20d02', -- SKU
   @cLine04 = '%20d03', -- DESCR1
   @cLine05 = '%20d04', -- DESCR2
   @cLine06 = '%20d05', -- UOM RATIO & DESCR
   @cLine07 = '%20d06', -- QTY
   @cLine08 = '%20d07', -- LOTTABLE (1)
   @cLine09 = '%20d08', -- LOTTABLE (2)
   @cLine10 = '%20d09', -- LOTTABLE (3)
   @cLine11 = '%20d10', -- LOTTABLE (4)
   @cLine12 = '%20d11', -- LOTTABLE (5)
   @cLine13 = '1 = CFM; ENT=NEXT %01i12',
   @cLine14 = '%e',
   @nFunc = 599

-- 4223 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4223 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4223, 'ENG', 
   @cLine01 = 'CONFIRM REVERSE BY?',
   @cLine03 = '1 = ID',
   @cLine04 = '2 = SKU',
   @cLine06 = 'OPTION %01i01',
   @cLine14 = '%e',
   @nFunc = 599