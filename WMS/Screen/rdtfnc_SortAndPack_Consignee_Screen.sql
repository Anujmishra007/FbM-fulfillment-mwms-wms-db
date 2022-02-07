-- 5860 = LoadKey screen
DELETE rdt.RDTScn WHERE Scn = 5860 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5860, 'ENG'
   ,@cLine01 = 'WAVE KEY:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'BATCH KEY:'
   ,@cLine04 = '%20i02'
   ,@cLine06 = 'LABEL NO:'
   ,@cLine07 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1851
   
-- 5861 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 5861 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5861, 'ENG'
   ,@cLine01 = 'UCC'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'LOADKEY: %10d02'
   ,@cLine04 = ''
   ,@cLine05 = 'BATCHKEY: %10d03'
   ,@cLine06 = 'POSITION: %10d04'
   ,@cLine07 = 'PALLETID: %10d05'
   ,@cLine08 = 'TOTAL QTY: %10d06'
   ,@cLine09 = 'CLOSE CARTON:'
   ,@cLine10 = '1=YES 2=NO'
   ,@cLine11 = '%01i07'
   ,@cLine14 = '%e'
   ,@nFunc = 1851

-- 5862 = LabelNo screen
DELETE rdt.RDTScn WHERE Scn = 5862 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5862, 'ENG' 
   ,@cLine01 = 'LABEL NO:'
   ,@cLine02 = '%20d01'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1851

---- 5863 = Option screen
--DELETE rdt.RDTScn WHERE Scn = 5863 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 5863, 'ENG'
--   ,@cLine01 = 'PRINT CARTON LABEL?'
--   ,@cLine02 = ''
--   ,@cLine03 = '1 = YES'
--   ,@cLine04 = '2 = NO'
--   ,@cLine05 = ''
--   ,@cLine06 = 'OPTION: %01i01'
--   ,@cLine14 = '%e'
--   ,@nFunc = 1851

SELECT TOP 10 * FROM rdt.rdtscn (NOLOCK) WHERE Scn BETWEEN 5860 AND 5864

SELECT TOP 10 * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID = 1851
--INSERT into rdt.rdtmsg (Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
--VALUES('1851','ENG','FNC','Sort&Pack Consignee','rdtfnc_SortAndPack_Consignee','4','0')