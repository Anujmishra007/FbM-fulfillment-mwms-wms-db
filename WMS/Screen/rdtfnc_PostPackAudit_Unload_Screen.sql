-- Scn = 1206. Vehicle No, REF No
DELETE rdt.RDTScn WHERE Scn = 1206 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1206, 'ENG', 
   @cLine01 = 'UNLOAD FROM TRUCK',
   @cLine03 = 'VEHICLE NO:',
   @cLine04 = '%20i01',
   @cLine06 = 'REF NO:',
   @cLine07 = '1. %17i02',
   @cLine08 = '2. %17i03',
   @cLine09 = '3. %17i04',
   @cLine10 = '4. %17i05',
   @cLine11 = '5. %17i06',
   @cLine14 = '%e'

-- Scn = 1207. Vehicle No, REF No
DELETE rdt.RDTScn WHERE Scn = 1207 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1207, 'ENG', 
   @cLine01 = 'UNLOAD FROM TRUCK',
   @cLine03 = 'VEHICLE NO:',
   @cLine04 = '%20d01',
   @cLine06 = 'STOR:',
   @cLine07 = '%15i02',
   @cLine14 = '%e'

-- Scn = 1208. Vehicle No, REF No
DELETE rdt.RDTScn WHERE Scn = 1208 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1208, 'ENG', 
   @cLine01 = 'UNLOAD FROM TRUCK',
   @cLine03 = 'VEHICLE NO:',
   @cLine04 = '%20d01',
   @cLine06 = 'STOR:',
   @cLine07 = '%15d02',
   @cLine09 = 'CASE/TOTE:',
   @cLine10 = '%18i03',
   @cLine12 = 'SCAN: %05d04',
   @cLine14 = '%e'

-- Scn = 1209. Vehicle No, REF No
DELETE rdt.RDTScn WHERE Scn = 1209 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1209, 'ENG', 
   @cLine01 = 'UNLOAD FROM TRUCK',
   @cLine03 = 'UNLOAD ALL?',
   @cLine05 = '1=YES',
   @cLine06 = '2=NO',
   @cLine08 = 'OPTION: %01i01',      
   @cLine14 = '%e'


