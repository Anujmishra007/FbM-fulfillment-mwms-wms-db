--rdt_841ExtUpdSP04
--execute rdt.rdtdropmsg 108151 - 108200
GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 108151, 10, '08151^ToteCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 108152, 10, '08152^UpdWCSFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 108153, 10, '08153^UpdWCSDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 108154, 10, '08154^DelEcommLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108155, 10, '08155^SKuNotIntote',     'us_english',@nFunc
execute rdt.rdtAddMsg 108156, 10, '08156^SKUNotInOrder',    'us_english',@nFunc
execute rdt.rdtAddMsg 108157, 10, '08157^QtyExceeded',      'us_english',@nFunc
execute rdt.rdtAddMsg 108158, 10, '08158^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 108159, 10, '08159^InsPickHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 108160, 10, '08160^UpdPickDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 108161, 10, '08161^CreatePHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 108162, 10, '08162^UpdPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 108163, 10, '08163^OVER PACKED',      'us_english',@nFunc
execute rdt.rdtAddMsg 108164, 10, '08164^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 108165, 10, '08165^InsPInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 108166, 10, '08166^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 108167, 10, '08167^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 108168, 10, '08168^UpdOrderFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 108169, 10, '08169^InsTrackLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108170, 10, '08170^GenLblSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 108171, 10, '08171^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 108172, 10, '08172^GenTrackNoSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 108173, 10, '08173^NoTrackNoGenerated',  'us_english',@nFunc
execute rdt.rdtAddMsg 108174, 10, '08174^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108175, 10, '08175^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108176, 10, '08176^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108177, 10, '08177^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108178, 10, '08178^UpdOrdFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108179, 10, '08179^UpdPackDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108180, 10, '08180^UpdPackDetFail',  'us_english',@nFunc

-- WMS-15010
execute rdt.rdtAddMsg 108181, 10, '08181^GetRightFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 108182, 10, '08182^AutoMBOLPack',  'us_english',@nFunc


