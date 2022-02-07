--scn 4680 --- 4689

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('842', 'ENG', 'FNC', 'ECOMM', 'rdtfnc_ECOMM', '0')



DELETE rdt.RDTScn WHERE Scn = 4680 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4680, 'ENG',
    @cLine01 = 'E-COMM'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'           
   ,@nFunc = 842


DELETE rdt.RDTScn WHERE Scn = 4681 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4681, 'ENG',
    @cLine01 = 'E-COMM'
   ,@cLine03 = 'TOTE TYPE: %10d01'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = 'ORDERKEY:'
   ,@cLine07 = '%10d03'
   ,@cLine08 = 'SKU/UPC:'
   ,@cLine09 = '%20i04'
   ,@cLine10 = 'TTL PICK: %05d05'
   ,@cLine11 = 'TTL SCAN: %05d06'
   ,@cLine14 = '%e'
   ,@nFunc = 842

DELETE rdt.RDTScn WHERE Scn = 4682 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4682, 'ENG',
    @cLine01 = 'E-COMM'
   ,@cLine03 = 'ORDERKEY: %10d01'
   ,@cLine05 = '%20d02' -- TrackNo
   ,@cLine06 = '%20i03'
   ,@cLine07 = '%20d04' -- Carton Type
   ,@cLine08 = '%20i05'
   ,@cLine09 = '%20d06' -- Weight
   ,@cLine10 = '%20i07'
   ,@cLine14 = '%e'
   ,@nFunc = 842   


DELETE rdt.RDTScn WHERE Scn = 4683 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4683, 'ENG',
    @cLine01 = 'E-COMM'
   ,@cLine03 = '1 = SHORT PACK'
   ,@cLine04 = '5 = CLOSE PACK'
   ,@cLine05 = '9 = EXIT PACK'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 842


DELETE rdt.RDTScn WHERE Scn = 4684 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4684, 'ENG',
    @cLine01 = 'E-COMM'
   ,@cLine02 = 'More Tote to be'
   ,@cLine03 = 'scanned, Continue?'
   ,@cLine05 = '%18d01'
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18d03'
   ,@cLine08 = '%18d04'
   ,@cLine09 = '%18d05'
   ,@cLine10 = '%18d06'
   ,@cLine11 = '1 = Yes 9 = No'
   ,@cLine12 = 'OPTION: %01i07'
   ,@cLine14 = '%e'
   ,@nFunc = 842



select * from rdt.rdtscn with (nolock) where scn between 4680 and 4689 
