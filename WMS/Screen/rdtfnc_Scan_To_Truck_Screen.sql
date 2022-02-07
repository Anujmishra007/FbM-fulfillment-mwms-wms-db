-- 1990  = MBOL#, LOAD# screen
DELETE rdt.RDTScn WHERE Scn = 1990 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1990, 'ENG',
    @cLine01 = 'MBOL#: %10i01'
   ,@cLine03 = 'LOAD#: %10i02'
   ,@cLine14 = '%e'

-- 1991 = URN # screen
DELETE rdt.RDTScn WHERE Scn = 1991 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1991, 'ENG',
    @cLine01 = 'URN NO/CASE ID:'        
   ,@cLine02 = '%40i01'
   ,@cLine04 = '# OF CASES:'
   ,@cLine05 = '%11d02'
   ,@cLine14 = '%e'
 
-- 1992 = LOAD CLOSE screen
DELETE rdt.RDTScn WHERE Scn = 1992 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1992, 'ENG',
    @cLine01 = 'LOAD CLOSED'        
   ,@cLine03 = '1 = NEXT LOAD'
   ,@cLine05 = 'OPTION: %01i01'
   ,@cLine14 = '%e'

-- 1993 = Case Remaining Msg screen
DELETE rdt.RDTScn WHERE Scn = 1993 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1993, 'ENG',
    @cLine01 = '%11d01'
   ,@cLine02 = 'Cases Remaining'        
   ,@cLine03 = 'Press ENTER OR ESC'
   ,@cLine04 = 'To Continue'
   ,@cLine14 = '%e'

-- 1994 = Over-Scanned Msg screen
DELETE rdt.RDTScn WHERE Scn = 1994 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1994, 'ENG',
    @cLine01 = 'Over-Scanned'        
   ,@cLine03 = 'Cases Not Tally'
   ,@cLine05 = 'Press ENTER OR ESC'
   ,@cLine06 = 'To Continue'
   ,@cLine14 = '%e'