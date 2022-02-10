-- 2640 - 2649

-- 2220  = PrinterID , DropID screen
DELETE rdt.RDTScn WHERE Scn = 2640 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2640, 'ENG',
    @cLine01 = 'PRINT PALLET LABEL'
   ,@cLine03 = 'Printer:'
   ,@cLine04 = '%10i01' 
   ,@cLine06 = 'DropID:'
   ,@cLine07 = '%18i02' 
   ,@cLine08 = 'OR' 
   ,@cLine09 = 'Label No:'
   ,@cLine10 = '%20i03' 
	,@cLine14 = '%e'
   
DELETE rdt.RDTScn WHERE Scn = 2641 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2641, 'ENG',
    @cLine01 = 'PRINT PALLET LABEL'
   ,@cLine07 = 'Label Printed.'
   ,@cLine14 = '%e'   
   
UPDATE rdt.RDTSCN WITH (ROWLOCK)
SET Func = 912
WHERE Scn Between 2640 AND 2649 


INSERT INTO rdt.rdtmsg ( Message_ID , Lang_Code , Message_Type, Message_Text , StoredProcName , EventType )
VALUES ( 912 , 'ENG', 'FNC' , 'Print Pallet Label' , 'rdtfnc_Print_Pallet_Label', '' ) 

