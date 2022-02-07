-- 1780 = Menu for RDT Scan Out
DELETE rdt.RDTScn WHERE Scn = 1780 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1780, 'ENG', 
   @cLine01 = 'Pickslip No: ', 
   @cLine02 = '%10i01', 
   @cLine14 = '%e'