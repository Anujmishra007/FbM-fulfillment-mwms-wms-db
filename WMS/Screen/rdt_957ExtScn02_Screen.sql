-- 6387 = SSCC FCR-454
DELETE rdt.RDTScn WHERE Scn = 6387 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6387, 'ENG'
   ,@cLine01 = 'SSCC'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 957

-- 6388 = UCCNo FCR-454
DELETE rdt.RDTScn WHERE Scn = 6388 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6388, 'ENG'
   ,@cLine01 = 'LOC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'Style: %13d02'
   ,@cLine04 = 'Size: %13d03'
   ,@cLine05 = 'Measurement: %07d04'
   ,@cLine06 = 'UCC:'
   ,@cLine07 = '%20i05'
   ,@cLine08 = 'Total Case: %08d06'
   ,@cLine09 = 'Total Scan: %08d07'
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5"],"3":["6","7"],"4":["8","9"],"5":["10"]}'
   ,@nFunc = 957

-- 6389 = TOLOC FCR-454
DELETE rdt.RDTScn WHERE Scn = 6389 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6389, 'ENG'
   ,@cLine01 = 'TOLOC:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 957

-- 6410 = Close Pallet? FCR-454
DELETE rdt.RDTScn WHERE Scn = 6410 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6410, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Close Pallet?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5"],"3":["8"]}'
   ,@nFunc = 957

-- 6849 = WaveKey FCR-10076
DELETE rdt.RDTScn WHERE Scn = 6849 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6849, 'ENG'
   ,@cLine01 = 'WaveKey: %10i01'
   ,@cLine02 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 957

-- 6860 = Pick zone screen
DELETE rdt.RDTScn WHERE Scn = 6860 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6860, 'ENG'
   ,@cLine01 = 'WaveKey: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'PKZONE: %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'DROPID:'
   ,@cLine06 = '%20i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3"],"3":["5","6"]}'
   ,@nFunc = 957