--rdt_841ExtUpdSP01
--execute rdt.rdtdropmsg 90551 , 90600
GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 90551, 10, '90551^ToteCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 90552, 10, '90552^UpdWCSFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 90553, 10, '90553^UpdWCSDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 90554, 10, '90554^DelEcommLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 90555, 10, '90555^SKuNotIntote',     'us_english',@nFunc
execute rdt.rdtAddMsg 90556, 10, '90556^SKUNotInOrder',    'us_english',@nFunc
execute rdt.rdtAddMsg 90557, 10, '90557^QtyExceeded',      'us_english',@nFunc
execute rdt.rdtAddMsg 90558, 10, '90558^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 90559, 10, '90559^InsPickHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 90560, 10, '90560^UpdPickDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 90561, 10, '90561^CreatePHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 90562, 10, '90562^UpdPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 90563, 10, '90563^OVER PACKED',      'us_english',@nFunc
execute rdt.rdtAddMsg 90564, 10, '90564^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 90565, 10, '90565^InsPInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 90566, 10, '90566^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 90567, 10, '90567^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 90568, 10, '90568^UpdOrderFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 90569, 10, '90569^InsTrackLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 90570, 10, '90570^GenLblSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 90571, 10, '90571^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 90572, 10, '90572^GenTrackNoSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 90573, 10, '90573^NoTrackNoGenerated',  'us_english',@nFunc
execute rdt.rdtAddMsg 90574, 10, '90574^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 90575, 10, '90575^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 90576, 10, '90576^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 90577, 10, '90577^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 90578, 10, '90578^UpdOrdFail',  'us_english',@nFunc

-- WMS-15010
execute rdt.rdtAddMsg 90579, 10, '90579^GetRightFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 90580, 10, '90580^AutoMBOLPack',  'us_english',@nFunc


