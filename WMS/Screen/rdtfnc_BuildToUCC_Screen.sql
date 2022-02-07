--SCN DETAILS

DELETE rdt.RDTScn WHERE Scn = 5330 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5330, 'ENG',
   @cLine01 = 'MOVE TO UCC'
   ,@cLine03 = 'FROM LOC: %10i01'
   ,@cLine14 = '%e'
   ,@nfunc   =1832

DELETE rdt.RDTScn WHERE Scn = 5331 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5331, 'ENG',
   @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18i02'
   ,@cLine14 = '%e'
   ,@nfunc   =1832
   
DELETE rdt.RDTScn WHERE Scn = 5332 AND Lang_Code = 'ENG'
   
EXECUTE rdt.rdtAddScn 5332, 'ENG',
   @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine05 = 'TO LOC: %10i03' 
   ,@cLine14 = '%e'
   ,@nfunc   =1832

DELETE rdt.RDTScn WHERE Scn = 5333 AND Lang_Code = 'ENG'
   
EXECUTE rdt.rdtAddScn 5333, 'ENG',
   @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine05 = 'TO LOC: %10d03' 
   ,@cLine06 = 'TO ID:'
   ,@cLine07 = '%18i04'  
   ,@cLine14 = '%e'
   ,@nfunc   =1832
   
DELETE rdt.RDTScn WHERE Scn = 5334 AND Lang_Code = 'ENG'
   
EXECUTE rdt.rdtAddScn 5334, 'ENG',
   @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i03'  
   ,@cLine14 = '%e'
   ,@nfunc   =1832

DELETE rdt.RDTScn WHERE Scn = 5335 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5335, 'ENG',
   @cLine01 = 'SKU/UPC:     %05d08'
   ,@cLine02 = '%20i11'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '1:%18d04'
   ,@cLine07 = '2:%18d05' 
   ,@cLine08 = '3:%16d06'
   ,@cLine09 = '4:%16d07' 
   ,@cLine10 = '1:%18d09'
   ,@cLine11 = 'QTY AVL: %05d12 %05d13' 
   ,@cLine12 = 'QTY MV:  %05i14 %05i15'  
   ,@cLine13 = '%20d10' 
   ,@cLine14 = '%e'
   ,@nfunc   =1832

DELETE rdt.RDTScn WHERE Scn = 5336 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5336, 'ENG',
   @cLine01 = 'TO UCC:'
   ,@cLine02 = '%60i01' 
   ,@cLine12 = '%20d15' 
   ,@cLine14 = '%e'
   ,@nfunc   =1832

DELETE rdt.RDTScn WHERE Scn = 5337 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5337, 'ENG',
   @cLine01 = 'CLOSE PALLET?'
   ,@cLine02 = '1 = YES' 
   ,@cLine03 = '2 = NO' 
   ,@cLine06 = 'OPTION: %01i01' 
   ,@cLine14 = '%e'
   ,@nfunc   =1832