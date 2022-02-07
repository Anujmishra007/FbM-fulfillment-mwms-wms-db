--rdt_841ExtUpdSP07
--execute rdt.rdtdropmsg 133651,133700
GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 133651, 10, '33651^ToteCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 133652, 10, '33652^UpdWCSFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 133653, 10, '33653^UpdWCSDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 133654, 10, '33654^DelEcommLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 133655, 10, '33655^SKuNotIntote',     'us_english',@nFunc
execute rdt.rdtAddMsg 133656, 10, '33656^SKUNotInOrder',    'us_english',@nFunc
execute rdt.rdtAddMsg 133657, 10, '33657^QtyExceeded',      'us_english',@nFunc
execute rdt.rdtAddMsg 133658, 10, '33658^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 133659, 10, '33659^InsPickHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 133660, 10, '33660^UpdPickDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 133661, 10, '33661^CreatePHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 133662, 10, '33662^UpdPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 133663, 10, '33663^OVER PACKED',      'us_english',@nFunc
execute rdt.rdtAddMsg 133664, 10, '33664^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 133665, 10, '33665^InsPInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 133666, 10, '33666^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 133667, 10, '33667^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 133668, 10, '33668^UpdOrderFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 133669, 10, '33669^InsTrackLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 133670, 10, '33670^GenLblSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 133671, 10, '33671^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 133672, 10, '33672^GenTrackNoSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 133673, 10, '33673^NoTrackNoGenerated',  'us_english',@nFunc
execute rdt.rdtAddMsg 133674, 10, '33674^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 133675, 10, '33675^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 133676, 10, '33676^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 133677, 10, '33677^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 133678, 10, '33678^UpdOrdFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 133679, 10, '33679^GetDetKeyFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 133680, 10, '33680^InstPKHdrFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 133681, 10, '33681^ScanInFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 133682, 10, '33682^UpdPickInfoFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 133683, 10, '33683^UpdPackDetFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 133684, 10, '33684^UpdPickDetailFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 133685, 10, '33685^UpdPickDetailFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 133686, 10, '33686^UpdPickInfoFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 133687, 10, '33687^UpdOrdFail ',  'us_english',@nFunc

-- WMS-10648
execute rdt.rdtAddMsg 133688, 10, '33688^ORD PENDCANC  ',  'us_english',@nFunc

-- WMS-15010
execute rdt.rdtAddMsg 133689, 10, '33689^GetRightFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 133690, 10, '33690^AutoMBOLPack',  'us_english',@nFunc