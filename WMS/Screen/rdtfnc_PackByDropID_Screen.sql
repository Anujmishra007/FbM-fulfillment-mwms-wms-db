-- 5340 = PickSlipNo, carton, drop ID screen
DELETE rdt.RDTScn WHERE Scn = 5340 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5340, 'ENG'
   ,@cLine01 = 'PSNO: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'OR'
   ,@cLine04 = ''
   ,@cLine05 = 'DROP ID: '
   ,@cLine06 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 843

-- 5341 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 5341 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5341, 'ENG'
   ,@cLine01 = 'PSNO: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'TOTAL PICK:   %05d02'
   ,@cLine04 = 'TOTAL PACK:   %05d03'
   ,@cLine05 = 'TOTAL CARTON: %05d04'
   ,@cLine06 = ''
   ,@cLine07 = 'CARTON NO:  %05i05'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = 'OPTION: %01i06'
   ,@cLine11 = '1=NEW 2=EDT 3=REPACK'
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 843

-- 5342 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 5342 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5342, 'ENG'
   ,@cLine01 = 'PSNO: %10d01'
   ,@cLine02 = 'CARTON NO: %05d02'
   ,@cLine03 = ''
   ,@cLine04 = 'DROP ID: '
   ,@cLine05 = '%20i03'
   ,@cLine06 = ''
   ,@cLine07 = 'SCANNED: %05d04'
   ,@cLine14 = '%e'
   ,@nFunc = 843

-- 5343 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 5343 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5343, 'ENG'
   ,@cLine01 = 'PSNO: %10d01'
   ,@cLine02 = 'CARTON NO: %05d02'
   ,@cLine03 = ''
   ,@cLine04 = 'CARTON: %10i03'
   ,@cLine05 = ''
   ,@cLine06 = 'WEIGHT: %10i04'
   ,@cLine14 = '%e'
   ,@nFunc = 843

-- 5344 = Confirm repack screen
DELETE rdt.RDTScn WHERE Scn = 5344 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5344, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM REPACK?'
   ,@cLine03 = 'CARTON NO: %01d01'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 843
