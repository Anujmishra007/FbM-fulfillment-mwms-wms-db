
-- Scan orderkey
DELETE rdt.RDTScn WHERE Scn = 5610 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5610, 'ENG',
   @cLine01 = 'Orderkey:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nfunc   =932

-- 5611 = Capture Handover
DELETE rdt.RDTScn WHERE Scn = 5611 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5611, 'ENG'
   ,@cLine01 = 'Orderkey:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CompanyName:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'DeliveryDate:'
   ,@cLine07 = '%20d04'
   ,@cLine08 = 'Route: %12d05'
   ,@cLine09 = 'TotalCartons: %05d06'
   ,@cLine11 = '1=Capture Handover'
   ,@cLine12 = '9=EXIT'
   ,@cLine13 = 'OPTION: %01i07'
   ,@cLine14 = '%e'
   ,@nFunc = 932

-- 5612 = Overwrite the handover date
DELETE rdt.RDTScn WHERE Scn = 5612 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5612, 'ENG'
   ,@cLine01 = 'Orderkey:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'HandOverDate:'
   ,@cLine04 = '%20d08'
   ,@cLine05 = 'Overwrite'
   ,@cLine06 = 'Handover Date?'
   ,@cLine08 = '1=Yes'
   ,@cLine09 = '9=Exit'
   ,@cLine10 = 'Option: %01i09'
   ,@cLine14 = '%e'
   ,@nFunc = 932

-- 5613 = Capture handover success
DELETE rdt.RDTScn WHERE Scn = 5613 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5613, 'ENG'
   ,@cLine01 = 'Orderkey:%10d01'
   ,@cLine04 = 'Capture'
   ,@cLine05 = 'Handover Date'
   ,@cLine06 = 'Successfully!'
   ,@cLine14 = '%e'
   ,@nFunc = 932