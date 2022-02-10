-- 1565 = Menu for Print carton label
DELETE rdt.RDTScn WHERE Scn = 1565 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1565, 'ENG', 
   @cLine01 = 'LABEL NO: ', 
   @cLine02 = '%20i01', 
   @cLine14 = '%e'