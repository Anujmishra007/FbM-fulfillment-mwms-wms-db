INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('876', 'ENG', 'FNC', 'Serial No By OrderKey', 'rdtfnc_SerialNoByOrder', '0')

-- 3020 = ExternOrderKey screen
DELETE rdt.RDTScn WHERE Scn = 3020 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3020, 'ENG',
    @cLine01 = 'EXTERNORDERKEY:'
   ,@cLine02 = '%30i01'
   ,@cLine04 = 'OR'
   ,@cLine06 = 'ORDERKEY:' -- (ChewKP01)
   ,@cLine07 = '%10i02'    -- (ChewKP01) 
   ,@cLine12 = 'COUNT: %05d03'
   ,@cLine14 = '%e'

-- 3021 = SerialNo screen
DELETE rdt.RDTScn WHERE Scn = 3021 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3021, 'ENG',
    @cLine01 = 'EXTERNORDERKEY:'
   ,@cLine02 = '%30d01'
   ,@cLine03 = ''
   ,@cLine04 = 'ORDERKEY:'    -- (ChewKP01)
   ,@cLine05 = '%10d04'       -- (ChewKP01)
   ,@cLine07 = 'SERIALNO:'
   ,@cLine08 = '%200iV_MAX'    -- (ChewKP01)
   ,@cLine10 = 'COUNT: %05d03'
   ,@cLine11 = '%20d05'       -- (ChewKP02) ExtendedInfo
   ,@cLine14 = '%e'

UPDATE RDT.RDTSCN SET FUNC = 875 WHERE SCN BETWEEN 3020 AND 3029
