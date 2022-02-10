-- 1560 = Menu for Print carton label
DELETE rdt.RDTScn WHERE Scn = 1560 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1560, 'ENG', 
   @cLine01 = 'LABEL NO:',   
   @cLine02 = '%20i01',   
   @cLine04 = 'OR',   
   @cLine06 = 'UCC NO:',   
   @cLine07 = '%20i02',   
   @cLine10 = 'CONSIGNEE: ',   
   @cLine11 = '%15d03',   
   @cLine12 = 'CARTONNO: %04d04',
   @cLine14 = '%e'