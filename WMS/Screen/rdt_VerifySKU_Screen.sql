
-- 3950 = Verif SKU screen
DELETE rdt.RDTScn WHERE Scn = 3950 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3950, 'ENG', 
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02' 	
   ,@cLine04 = '%20d03' 	
   ,@cLine05 = '%20i12'
   ,@cLine06 = 'WEIGHT: %10i04'
   ,@cLine07 = 'CUBE  : %10i05'
   ,@cLine08 = 'L     : %10i06'
   ,@cLine09 = 'W     : %10i07'
   ,@cLine10 = 'H     : %10i08'
   ,@cLine11 = 'INNER : %10i09'
   ,@cLine12 = 'CASE  : %10i10'
   ,@cLine13 = 'PALLET: %10i11'
   ,@cLine14 = '%e'
