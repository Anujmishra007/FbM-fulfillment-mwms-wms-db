-- 3780 = PickSlipNo
DELETE rdt.RDTScn WHERE Scn = 3780 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3780, 'ENG'
   ,@cLine01 = 'PSNO: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 877

-- 3781 = Barcode
DELETE rdt.RDTScn WHERE Scn = 3781 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3781, 'ENG'
   ,@cLine01 = 'PSNO: %10d01'
   ,@cLine02 = 'BARCODE:'
   ,@cLine03 = '%60i02'
   ,@cLine11 = 'CASE SCAN/TOTAL:'
   ,@cLine12 = '%10d03'
   ,@cLine14 = '%e'
   ,@nFunc = 877

-- 3782 = SKU
DELETE rdt.RDTScn WHERE Scn = 3782 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3782, 'ENG'
   ,@cLine01 = 'SKU/UPC:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 877

-- 3783 = Case ID
DELETE rdt.RDTScn WHERE Scn = 3783 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3783, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = ''
   ,@cLine06 = 'BATCH NO:'
   ,@cLine07 = '%18i04'
   ,@cLine08 = ''
   ,@cLine09 = 'CASE ID:'
   ,@cLine10 = '%18i05'
   ,@cLine14 = '%e'
   ,@nFunc = 877
