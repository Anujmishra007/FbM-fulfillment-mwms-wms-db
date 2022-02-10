-- 1630 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1630 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1630, 'ENG',
    @cLine01 = 'PWAYZONE: %10i01'
   ,@cLine02 = 'PICKZONE: %10i02'
   ,@cLine03 = 'AISLE: %10i03'
   ,@cLine04 = 'LEVEL: %04i04'
   ,@cLine05 = 'STARTLOC: %10i05'
   ,@cLine07 = 'EMPTY: %01i06'
   ,@cLine08 = 'HOLD : %01i07'
   ,@cLine09 = '1=YES 2=NO BLANK=ALL'
   ,@cLine11 = 'LOC TYPE: %01i08'
   ,@cLine12 = '1=BULK 2=PICK'
   ,@cLine14 = '%e'
   ,@nFunc = 558
 
-- 1631 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1631 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1631, 'ENG',
    @cLine01 = 'NO LOC        ID/MAX'
   ,@cLine02 = '1  %18d01'
   ,@cLine03 = '2  %18d02'
   ,@cLine04 = '3  %18d03'
   ,@cLine05 = '4  %18d04'
   ,@cLine06 = '5  %18d05'
   ,@cLine07 = '6  %18d06'
   ,@cLine08 = '7  %18d07'
   ,@cLine09 = '8  %18d08'
   ,@cLine10 = '9  %18d09'
   ,@cLine11 = '10 %18d10'
   ,@cLine13 = 'MORE INF ON LOC#: %02i11'
   ,@cLine14 = '%e'
   ,@nFunc = 558
 
-- 1632 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1632 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1632, 'ENG',
    @cLine01 = 'PWAYZONE: %10d01'
   ,@cLine02 = 'PICKZONE: %10d02'
   ,@cLine03 = 'LOG. LOC: %10d03'
   ,@cLine04 = 'CCLOGLOC: %10d04'
   ,@cLine06 = 'TYPE: %10d05'
   ,@cLine07 = 'FLAG: %10d06'
   ,@cLine08 = 'HANDLING: %10d07'
   ,@cLine09 = 'STATUS: %10d08'
   ,@cLine10 = 'LOSEID: %01d09'
   ,@cLine11 = 'ABC: %01d10'
   ,@cLine12 = 'COMMINGLE SKU: %01d11'
   ,@cLine13 = 'COMMINGLE LOT: %01d12'
   ,@cLine14 = '%e'
   ,@nFunc = 558 

 
