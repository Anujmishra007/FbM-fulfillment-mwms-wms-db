-- 3400 = UCC screen
DELETE rdt.RDTScn WHERE Scn = 3400 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3400, 'ENG'
   ,@cLine01 = 'UCC:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'OR'
   ,@cLine05 = ''
   ,@cLine06 = 'TROLLEY NO:'
   ,@cLine07 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 740

-- 3401 = LOC, ID screen
DELETE rdt.RDTScn WHERE Scn = 3401 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3401, 'ENG'
   ,@cLine01 = 'PWAYZONE: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'SUGGESTED LOC:'
   ,@cLine04 = '%10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'TROLLEY NO:'
   ,@cLine07 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 740

 -- 3402 = Discrepency screen
DELETE rdt.RDTScn WHERE Scn = 3402 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3402, 'ENG',
    @cLine01 = 'UCC ON TROLLEY: %04d01'
   ,@cLine02 = ''
   ,@cLine03 = 'CLOSE TROLLEY?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 740
