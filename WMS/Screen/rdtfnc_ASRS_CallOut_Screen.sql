-- 4170 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4170 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4170, 'ENG',
    @cLine01 = 'TO LOC: '
   ,@cLine02 = '%10i01'
   ,@cLine04 = 'CCREF NO: '
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc   = 1820

-- 4171 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4171 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4171, 'ENG',
    @cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'CCREF NO: %10d02'
   ,@cLine04 = 'COUNT SHEET #:'
   ,@cLine05 = '%10i03'
   ,@cLine06 = 'LAST SCAN SHEET #:'   
   ,@cLine07 = '%10d04'
   ,@cLine08 = '# OF SCAN: %05d05'
   ,@cLine14 = '%e'
   ,@nFunc   = 1820