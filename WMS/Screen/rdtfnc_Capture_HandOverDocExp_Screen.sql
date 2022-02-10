--rdtfnc_Capture_HandOverDocExp
--5900 - 5909

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1853 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1853, 'ENG', 'FNC', 'HandoverDocException', 'rdtfnc_Capture_HandOverDocExp', '2')
END

-- Scn = 5900. --Handover Opt
DELETE rdt.RDTScn WHERE Scn = 5900 AND Lang_Code = 'SMP'
EXECUTE rdt.rdtAddScn 5900, 'SMP' 
   ,@cLine01 = N'数据记录模块'
   ,@cLine02 = '%20d01' --wms-17807
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine13 = 'OPT: %2i11'
   ,@cLine14 = '%e'
   ,@nFunc = 1853

-- Scn = 5901 --DocumentNo
DELETE rdt.RDTScn WHERE Scn = 5901 AND Lang_Code = 'SMP'
EXECUTE rdt.rdtAddScn 5901, 'SMP'
   ,@cLine01 = '%20d01'
   ,@cLine02 = N'交接单号:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%20i03'
   ,@cLine06 = N'异常包裹号:'
   ,@cLine07 = '%20i04'
   ,@cLine08 = ''
   ,@cLine09 = N'计数: %5d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1853

-- Scn = 5902 --exit
DELETE rdt.RDTScn WHERE Scn = 5902 AND Lang_Code = 'SMP'
EXECUTE rdt.rdtAddScn 5902, 'SMP'
   ,@cLine01 = '%20d01'
   ,@cLine02 = N'交接单号:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = N'计数:'
   ,@cLine07 = '%10d04'
   ,@cLine08 = ''
   ,@cLine09 = N'是否关闭此交接单号？'
   ,@cLine10 = N'1.是  2.否'
   ,@cLine11 = 'OPT: %1i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1853
   
-- Scn = 5903 --SKU  --wms-17807
DELETE rdt.RDTScn WHERE Scn = 5903 AND Lang_Code = 'SMP'
EXECUTE rdt.rdtAddScn 5903, 'SMP'
   ,@cLine01 = '%20d01'
   ,@cLine02 = ''
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20i03'
   ,@cLine07 = '%20d04' --PreSKU
   ,@cLine08 = '%20d05' --skuDescr1
   ,@cLine09 = '%20d06' --skuDescr1
   ,@cLine10 = 'DocumentNo:'
   ,@cLine11 = '%20d07'
   ,@cLine12 = N'计数:'
   ,@cLine13 = '%5d08'
   ,@cLine14 = '%e'
   ,@nFunc = 1853
      
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5900 and 5909
SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1853 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'
