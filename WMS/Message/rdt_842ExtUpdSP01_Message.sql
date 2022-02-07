--rdt_842ExtUpdSP01
--execute rdt.rdtdropmsg 101501 - 101550
GO
DECLARE @nFunc INT

SET @nFunc = 842

execute rdt.rdtAddMsg 101501, 10, '01501^NoRecToProcess',    'us_english',@nFunc
execute rdt.rdtAddMsg 101502, 10, '01502^SKuNotIntote',     'us_english',@nFunc
execute rdt.rdtAddMsg 101503, 10, '01503^QtyExceeded',      'us_english',@nFunc
execute rdt.rdtAddMsg 101504, 10, '01504^InsPickHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 101505, 10, '01505^UpdPickDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 101506, 10, '01506^CreatePHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 101507, 10, '01507^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 101508, 10, '01508^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101509, 10, '01509^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 101510, 10, '01510^UpdPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 101511, 10, '01511^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101512, 10, '01512^InsPInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101513, 10, '01513^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101514, 10, '01514^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101515, 10, '01515^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101516, 10, '01516^InvDropID',     'us_english',@nFunc
execute rdt.rdtAddMsg 101517, 10, '01517^InsPickInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101518, 10, '01518^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101519, 10, '01519^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101520, 10, '01520^InvalidOption',     'us_english',@nFunc
execute rdt.rdtAddMsg 101521, 10, '01521^PickNotDone',     'us_english',@nFunc
execute rdt.rdtAddMsg 101522, 10, '01522^UpdPackDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 101523, 10, '01523^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 101524, 10, '01524^PickNotComplete',  'us_english',@nFunc
execute rdt.rdtAddMsg 101525, 10, '01525^PickNotComplete',  'us_english',@nFunc
execute rdt.rdtAddMsg 101526, 10, '01526^UpdPickDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101527, 10, '01527^GetKeyFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101528, 10, '01528^InsPickDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101529, 10, '01529^InsPickDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101530, 10, '01530^InsEcommFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101531, 10, '01531^UpdDropIDFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101532, 10, '01532^UpdEcommFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101533, 10, '01533^NoPrinter842Ext',  'us_english',@nFunc
execute rdt.rdtAddMsg 101534, 10, '01534^TrackNoInUsed',  'us_english',@nFunc
execute rdt.rdtAddMsg 101535, 10, '01535^InsCartonTrackFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101536, 10, '01536^UpdPackDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 101537, 10, '01537^LabelPrinterReq',  'us_english',@nFunc
execute rdt.rdtAddMsg 101538, 10, '01538^PaperPrinterReq',  'us_english',@nFunc