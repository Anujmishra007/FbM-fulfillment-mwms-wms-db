-- 1800 = Menu for Print carton label & manifest
DELETE rdt.RDTScn WHERE Scn = 1800 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1800, 'ENG', 
   @cLine01 = 'LABEL NO:',   
   @cLine02 = '%20i01',   
   @cLine04 = 'CONSIGNEE: ',   
   @cLine05 = '%15d02',   
   @cLine07 = 'CARTONNO: %04d03',
   @cLine14 = '%e'