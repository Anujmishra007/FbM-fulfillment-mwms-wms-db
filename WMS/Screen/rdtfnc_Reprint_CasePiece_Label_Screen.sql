--rdtfnc_Reprint_CasePiece_Label
-- 2810 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2810 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2810, 'ENG',
    @cLine01 = 'REPRINT LABEL'
   ,@cLine03 = '1 = CASE LABEL'
   ,@cLine04 = '2 = PIECE LABEL'
   ,@cLine06 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc   = 622
   
 
-- 2811 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2811 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2811, 'ENG',
    @cLine01 = '%10d01'
   ,@cLine03 = 'PICKSLIP NO:'
   ,@cLine04 = '%10i02'
   ,@cLine05 = 'FROM CARTON: %05i03'
   ,@cLine06 = 'TO CARTON  : %05i04'
   ,@cLine10 = 'PRESS ESC TO GO BACK'
   ,@cLine14 = '%e'
   ,@nFunc   = 622

