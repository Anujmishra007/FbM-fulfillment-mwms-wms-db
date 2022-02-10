--5650=5659,@nFunc = 1840
-- 5650 = ASN
DELETE rdt.RDTScn WHERE Scn = 5650 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5650, 'ENG'
   ,@cLine01 = 'ASN:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1840

-- 5651 = UCC
DELETE rdt.RDTScn WHERE Scn = 5651 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5651, 'ENG'
   ,@cLine01 = 'ASN:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'DevicePosition:SKU'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'UCC:'
   ,@cLine08 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1840

-- 5652 = Reset UCC
DELETE rdt.RDTScn WHERE Scn = 5652 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5652, 'ENG'
   ,@cLine01 = 'Reset UCC?'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = '1=YES'
   ,@cLine05 = '2=NO'
   ,@cLine06 = 'OPTION: %2i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1840
   
-- 5653 = SINGLE SKU
DELETE rdt.RDTScn WHERE Scn = 5653 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5653, 'ENG'
   ,@cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU'
   ,@cLine05 = '%20i02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = 'SCAN QTY: %05d04'
   ,@cLine08 = 'CTN QTY: %05d05'
   ,@cLine09 = 'CTN TOTAL QTY: %05d06'
   ,@cLine14 = '%e'
   ,@nFunc = 1840
   
-- 5654 = MIXED SKU
DELETE rdt.RDTScn WHERE Scn = 5654 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5654, 'ENG'
   ,@cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU'
   ,@cLine05 = '%20i02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = 'SCAN QTY: %05d04'
   ,@cLine08 = 'CTN QTY: %05d05'
   ,@cLine09 = 'CTN TOTAL QTY: %05d06'
   ,@cLine10 = 'POSITION:  %10d07'
   ,@cLine14 = '%e'
   ,@nFunc = 1840
   
-- 5655 = Display Varians
DELETE rdt.RDTScn WHERE Scn = 5655 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5655, 'ENG'
   ,@cLine01 = 'SKU : QTY'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine14 = '%e'
   ,@nFunc = 1840

-- 5656 = Adjustment
DELETE rdt.RDTScn WHERE Scn = 5656 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5656, 'ENG'
   ,@cLine01 = 'VARIANCE FOUND,'
   ,@cLine02 = 'CREATE ADJUSTMENT?'
   ,@cLine03 = ''
   ,@cLine04 = '1: YES'
   ,@cLine05 = '2: NO'
   ,@cLine06 = 'OPTION: %05i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1840
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5650 AND 5659