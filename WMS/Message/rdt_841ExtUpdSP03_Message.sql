--rdt_841ExtUpdSP03
--execute rdt.rdtdropmsg 94651 - 94700
GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 94651, 10, '94651^ToteCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 94652, 10, '94652^UpdWCSFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 94653, 10, '94653^UpdWCSDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 94654, 10, '94654^DelEcommLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 94655, 10, '94655^SKuNotIntote',     'us_english',@nFunc
execute rdt.rdtAddMsg 94656, 10, '94656^SKUNotInOrder',    'us_english',@nFunc
execute rdt.rdtAddMsg 94657, 10, '94657^QtyExceeded',      'us_english',@nFunc
execute rdt.rdtAddMsg 94658, 10, '94658^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 94659, 10, '94659^InsPickHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 94660, 10, '94660^UpdPickDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 94661, 10, '94661^CreatePHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 94662, 10, '94662^UpdPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 94663, 10, '94663^OVER PACKED',      'us_english',@nFunc
execute rdt.rdtAddMsg 94664, 10, '94664^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 94665, 10, '94665^InsPInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 94666, 10, '94666^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 94667, 10, '94667^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 94668, 10, '94668^UpdOrderFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 94669, 10, '94669^InsTrackLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 94670, 10, '94670^GenLblSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 94671, 10, '94671^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 94672, 10, '94672^GenTrackNoSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 94673, 10, '94673^NoTrackNoGenerated',  'us_english',@nFunc
execute rdt.rdtAddMsg 94674, 10, '94674^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 94675, 10, '94675^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 94676, 10, '94676^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 94677, 10, '94677^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 94678, 10, '94678^UpdOrdFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 94679, 10, '94679^WayBillNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 94680, 10, '94680^UpdOrdFail',  'us_english',@nFunc

-- WMS-15010
execute rdt.rdtAddMsg 94681, 10, '94681^GetRightFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 94682, 10, '9468^AutoMBOLPack',  'us_english',@nFunc


