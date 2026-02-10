-- 4250 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4250 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4250, 'ENG'
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'REFNO:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3","4"]}'
   ,@nFunc = 605
 
-- 4251 = ID screen
DELETE rdt.RDTScn WHERE Scn = 4251 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4251, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'REFNO:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = ''
   ,@cLine05 = 'ID:'
   ,@cLine06 = '%60i03'   --WMS5536 Extend to 60 chars
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["5","6"]}'
   ,@nFunc = 605
 

 
-- 4252 = ID detail screen
DELETE rdt.RDTScn WHERE Scn = 4252 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4252, 'ENG'
   ,@cLine01 = '%18d01'
   ,@cLine02 = 'SKU:           %05d13'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = 'QTY: %07d06 %07d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20d11'
   ,@cLine12 = '%20d12'
   ,@cLine13 = '1=RCVPL 2=NEXT %01i14'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4","5"],"3":["6","7"],"4":["8","9","10","11","12"],"5":["13"]}'
   ,@nFunc = 605



   -- 6441 = ID detail screen
DELETE rdt.RDTScn WHERE Scn = 6441 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6441, 'ENG'
   ,@cLine01 = '%18d01'
   ,@cLine02 = 'SKU:           %05d13'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = 'QTY: %07d06 %07d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20d11'
   ,@cLine12 = '%20d12'
   ,@cLine13 = '1=RCVPL 2=NEXT 3=VAS 4=DMG %01i14'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4","5"],"3":["6","7"],"4":["8","9","10","11","12"],"5":["13"]}'
   ,@nFunc = 605


-- 6621 = TOLOC screen, step99
DELETE rdt.RDTScn WHERE Scn = 6621 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6621, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'REFNO:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = ''
   ,@cLine05 = 'TOLOC:'
   ,@cLine06 = '%60i03'   --WMS5536 Extend to 60 chars
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["5","6"]}'
   ,@nFunc = 605
