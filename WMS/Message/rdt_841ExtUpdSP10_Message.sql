--rdt_841ExtUpdSP02
--execute rdt.rdtdropmsg 93351 , 93400
GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 93351, 10, '93351^ToteCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 93352, 10, '93352^UpdWCSFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 93353, 10, '93353^UpdWCSDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 93354, 10, '93354^DelEcommLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93355, 10, '93355^SKuNotIntote',     'us_english',@nFunc
execute rdt.rdtAddMsg 93356, 10, '93356^SKUNotInOrder',    'us_english',@nFunc
execute rdt.rdtAddMsg 93357, 10, '93357^QtyExceeded',      'us_english',@nFunc
execute rdt.rdtAddMsg 93358, 10, '93358^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 93359, 10, '93359^InsPickHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 93360, 10, '93360^UpdPickDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 93361, 10, '93361^CreatePHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 93362, 10, '93362^UpdPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 93363, 10, '93363^OVER PACKED',      'us_english',@nFunc
execute rdt.rdtAddMsg 93364, 10, '93364^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 93365, 10, '93365^InsPInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 93366, 10, '93366^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 93367, 10, '93367^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 93368, 10, '93368^UpdOrderFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 93369, 10, '93369^InsTrackLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93370, 10, '93370^GenLblSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 93371, 10, '93371^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 93372, 10, '93372^GenTrackNoSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 93373, 10, '93373^NoTrackNoGenerated',  'us_english',@nFunc
execute rdt.rdtAddMsg 93374, 10, '93374^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93375, 10, '93375^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93376, 10, '93376^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93377, 10, '93377^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93378, 10, '93378^UpdOrdFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93379, 10, '93379^GetDetKeyFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 93380, 10, '93380^InstPKHdrFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 93381, 10, '93381^ScanInFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 93382, 10, '93382^UpdPickInfoFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 93383, 10, '93383^UpdPackDetFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 93384, 10, '93384^UpdPickDetailFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 93385, 10, '93385^UpdPickDetailFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 93386, 10, '93386^UpdPickInfoFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 93387, 10, '93387^UpdOrdFail ',  'us_english',@nFunc

--WMS9881
execute rdt.rdtAddMsg 93388, 10, '93388^UpdPackDetFail ',  'us_english',@nFunc

-- WMS-15010
execute rdt.rdtAddMsg 93389, 10, '93389^GetRightFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93390, 10, '93390^AutoMBOLPack',  'us_english',@nFunc
execute rdt.rdtAddMsg 93391, 10, '93391^GetRightFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 93392, 10, '93392^AutoMBOLPack',  'us_english',@nFunc

