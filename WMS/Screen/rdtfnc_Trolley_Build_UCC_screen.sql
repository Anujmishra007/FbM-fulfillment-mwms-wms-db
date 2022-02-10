-- 5770 = UCC screen
DELETE rdt.RDTScn WHERE Scn = 5770 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5770, 'ENG'
   ,@cLine01 = 'UCC:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'UCC ON TROLLEY: %10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'TROLLEY NO:'
   ,@cLine07 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1843

 -- 5771 = Discrepency screen
DELETE rdt.RDTScn WHERE Scn = 5771 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5771, 'ENG',
    @cLine01 = 'UCC ON TROLLEY: %04d01'
   ,@cLine02 = ''
   ,@cLine03 = 'CLOSE TROLLEY?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1843