-- 2030  = Batch screen
DELETE rdt.RDTScn WHERE Scn = 2030 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2030, 'ENG',
    @cLine01 = 'BATCH PO'
   ,@cLine03 = 'BATCH:'
   ,@cLine04 = '%15i01'
   ,@cLine14 = '%e'

-- 2031 = BATCH, PO#
DELETE rdt.RDTScn WHERE Scn = 2031 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2031, 'ENG',
    @cLine01 = 'BATCH PO'        
   ,@cLine03 = 'BATCH:'
   ,@cLine04 = '%15d01'
   ,@cLine06 = 'PO#:'
   ,@cLine07 = '%15i02'
   ,@cLine14 = '%e'
 
-- 2032 = Option
DELETE rdt.RDTScn WHERE Scn = 2032 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2032, 'ENG',
    @cLine01 = 'BATCH:'
   ,@cLine02 = '%15d01'
   ,@cLine04 = 'PO#:'
   ,@cLine05 = '%15d02'
   ,@cLine07 = 'Please Confirm PO'
   ,@cLine08 = '1 = Yes'
   ,@cLine09 = '2 = No'
   ,@cLine11 = 'OPTION: %01i03'
   ,@cLine14 = '%e'

-- 2033 = Message
DELETE rdt.RDTScn WHERE Scn = 2033 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2033, 'ENG',
    @cLine02 = 'PO Successfully'
   ,@cLine03 = 'Saved'
   ,@cLine05 = 'Press ENTER or'
   ,@cLine06 = 'ESC to continue'
   ,@cLine14 = '%e'