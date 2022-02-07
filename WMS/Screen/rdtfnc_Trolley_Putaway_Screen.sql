-- 3410 = UCC screen
DELETE rdt.RDTScn WHERE Scn = 3410 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3410, 'ENG'
   ,@cLine01 = 'TROLLEY NO:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 741

-- 3411 = LOC, ID screen
DELETE rdt.RDTScn WHERE Scn = 3411 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3411, 'ENG'
   ,@cLine01 = 'TROLLEY NO:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'UCC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20i03'
   ,@cLine07 = ''
   ,@cLine08 = 'POSITION: %05d04'
   ,@cLine13 = '%20d05' -- extendedinfo
   ,@cLine14 = '%e'
   ,@nFunc = 741

-- 3412 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 3412 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3412, 'ENG'
   ,@cLine01 = 'TROLLEY NO:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'UCC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'QTY: %05i03'
   ,@cLine14 = '%e'
   ,@nFunc = 741
   
 -- 3413 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 3413 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3413, 'ENG' 
   ,@cLine01 = 'TROLLEY NO:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'UCC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'QTY: %05d03'
   ,@cLine08 = ''
   ,@cLine09 = 'SUGGESTED LOC:'
   ,@cLine10 = '%10d04'
   ,@cLine11 = '%10i05'
   ,@cLine14 = '%e'
   ,@nFunc = 741
