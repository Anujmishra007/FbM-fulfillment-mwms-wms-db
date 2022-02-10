--rdt_842ExtUpdSP06
--execute rdt.rdtdropmsg 132451 - 132500
GO
DECLARE @nFunc INT

SET @nFunc = 842

execute rdt.rdtAddMsg 132451, 10, '32451^NoRecToProcess',    'us_english',@nFunc
execute rdt.rdtAddMsg 132452, 10, '32452^SKuNotIntote',     'us_english',@nFunc
execute rdt.rdtAddMsg 132453, 10, '32453^QtyExceeded',      'us_english',@nFunc
execute rdt.rdtAddMsg 132454, 10, '32454^InsPickHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 132455, 10, '32455^UpdPickDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 132456, 10, '32456^CreatePHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 132457, 10, '32457^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 132458, 10, '32458^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132459, 10, '32459^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 132460, 10, '32460^UpdPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 132461, 10, '32461^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132462, 10, '32462^InsPInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132463, 10, '32463^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132464, 10, '32464^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132465, 10, '32465^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132466, 10, '32466^InvDropID',     'us_english',@nFunc
execute rdt.rdtAddMsg 132467, 10, '32467^InsPickInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132468, 10, '32468^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132469, 10, '32469^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132470, 10, '32470^InvalidOption',     'us_english',@nFunc
execute rdt.rdtAddMsg 132471, 10, '32471^PickNotDone',     'us_english',@nFunc
execute rdt.rdtAddMsg 132472, 10, '32472^UpdPackDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 132473, 10, '32473^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 132474, 10, '32474^PickNotComplete',  'us_english',@nFunc
execute rdt.rdtAddMsg 132475, 10, '32475^PickNotComplete',  'us_english',@nFunc
execute rdt.rdtAddMsg 132476, 10, '32476^UpdPickDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132477, 10, '32477^GetKeyFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132478, 10, '32478^InsPickDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132479, 10, '32479^InsPickDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132480, 10, '32480^InsEcommFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132481, 10, '32481^UpdDropIDFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132482, 10, '32482^UpdEcommFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132483, 10, '32483^NoPrinter842Ext',  'us_english',@nFunc
execute rdt.rdtAddMsg 132484, 10, '32484^TrackNoInUsed',  'us_english',@nFunc
execute rdt.rdtAddMsg 132485, 10, '32485^InsCartonTrackFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132486, 10, '32486^UpdPackDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 132487, 10, '32487^LabelPrinterReq',  'us_english',@nFunc
execute rdt.rdtAddMsg 132488, 10, '32488^PaperPrinterReq',  'us_english',@nFunc
execute rdt.rdtAddMsg 132489, 10, '32489^UpdCtnTrackFail',  'us_english',@nFunc

-- WMS-17965
execute rdt.rdtAddMsg 132490, 10, '32490^ShortPickFound',  'us_english',@nFunc