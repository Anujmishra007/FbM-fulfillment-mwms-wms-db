--5840- 5849 --rdtfnc_Pick_QC
-- 5840 --pickslipNo
DELETE rdt.RDTScn WHERE Scn = 5840 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5840, 'ENG'
   ,@cLine01 = 'PICKSLIP NO:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1848 

-- 5841 --ReasonCode
DELETE rdt.RDTScn WHERE Scn = 5841 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5841, 'ENG'
   ,@cLine01 = 'PICKSLIP NO:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'REASON CODE:'
   ,@cLine05 = '%08i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1848 

-- 5842 --SKU
DELETE rdt.RDTScn WHERE Scn = 5842 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5842, 'ENG'
   ,@cLine01 = 'PICKSLIP NO:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'REASON CODE:'
   ,@cLine05 = '%08d02'
   ,@cLine06 = ''
   ,@cLine07 = 'SKU'
   ,@cLine08 = '%20i03'
   ,@cLine09 = '%20d04'
   ,@cLine10 = '%20d05'
   ,@cLine11 = '%20d06'
   ,@cLine12 = 'QTY: %010d07'
   ,@cLine14 = '%e'
   ,@nFunc = 1848 
   
-- 5843 --CONFIRM?
DELETE rdt.RDTScn WHERE Scn = 5843 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5843, 'ENG'
   ,@cLine01 = 'SHORT PICK CONFIRM:'
   ,@cLine02 = '1. CONFIRM'
   ,@cLine03 = '2. CANCEL'
   ,@cLine04 = ''
   ,@cLine05 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1848 

   SELECT TOP 10 * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5840 and 5849