-- Scn = 1200. Vehicle No, REF No
DELETE rdt.RDTScn WHERE Scn = 1200 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1200, 'ENG', 
   @cLine01 = 'CLOSE TRUCK',
   @cLine03 = 'VEHICLE NO:',
   @cLine04 = '%20i01',
   @cLine06 = 'REF NO:',
   @cLine07 = '1. %17i02',
   @cLine08 = '2. %17i03',
   @cLine09 = '3. %17i04',
   @cLine10 = '4. %17i05',
   @cLine11 = '5. %17i06',
   @cLine14 = '%e'

-- 1201. Dialogue Option
DELETE rdt.RDTScn WHERE Scn = 1201 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1201, 'ENG', 
   @cLine01 = 'Close this truck?',
   @cLine03 = '1=YES',
   @cLine04 = '2=NO',
   @cLine06 = 'OPTION: %01i01',      
   @cLine14 = '%e'         

-- 1202. Message
DELETE rdt.RDTScn WHERE Scn = 1202 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1202, 'ENG', 
   @cLine01 = 'Truck closed',
   @cLine02 = 'successfully',
   @cLine04 = 'Press ENTER or ESC',
   @cLine05 = 'to continue',
   @cLine14 = '%e'
