--rdt_841ExtUpdSP02
--execute rdt.rdtdropmsg 136801 - 136850
GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 136801, 10, '36801^ToteCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 136802, 10, '36802^UpdWCSFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 136803, 10, '36803^UpdWCSDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 136804, 10, '36804^DelEcommLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136805, 10, '36805^SKuNotIntote',     'us_english',@nFunc
execute rdt.rdtAddMsg 136806, 10, '36806^SKUNotInOrder',    'us_english',@nFunc
execute rdt.rdtAddMsg 136807, 10, '36807^QtyExceeded',      'us_english',@nFunc
execute rdt.rdtAddMsg 136808, 10, '36808^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 136809, 10, '36809^InsPickHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 136810, 10, '36810^UpdPickDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 136811, 10, '36811^CreatePHdrFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 136812, 10, '36812^UpdPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 136813, 10, '36813^OVER PACKED',      'us_english',@nFunc
execute rdt.rdtAddMsg 136814, 10, '36814^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 136815, 10, '36815^InsPInfoFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 136816, 10, '36816^UpdEcommFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 136817, 10, '36817^InsPackDetFail',   'us_english',@nFunc
execute rdt.rdtAddMsg 136818, 10, '36818^UpdOrderFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 136819, 10, '36819^InsTrackLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136820, 10, '36820^GenLblSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 136821, 10, '36821^NoLabelNoGen',  'us_english',@nFunc
execute rdt.rdtAddMsg 136822, 10, '36822^GenTrackNoSPNotFound',  'us_english',@nFunc
execute rdt.rdtAddMsg 136823, 10, '36823^NoTrackNoGenerated',  'us_english',@nFunc
execute rdt.rdtAddMsg 136824, 10, '36824^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136825, 10, '36825^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136826, 10, '36826^UpdOrderFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136827, 10, '36827^InsCtnShpmentDetFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136828, 10, '36828^UpdOrdFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136829, 10, '36829^GetDetKeyFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136830, 10, '36830^InstPKHdrFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136831, 10, '36831^ScanInFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136832, 10, '36832^UpdPickInfoFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136833, 10, '36833^UpdPackDetFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136834, 10, '36834^UpdPickDetailFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136835, 10, '36835^UpdPickDetailFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136836, 10, '36836^UpdPickInfoFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136837, 10, '36837^UpdOrdFail ',  'us_english',@nFunc
execute rdt.rdtAddMsg 136838, 10, '36838^UpdPackHdrFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136839, 10, '36839^UpdOrdFail',  'us_english',@nFunc

-- WMS-15010
execute rdt.rdtAddMsg 136840, 10, '36840^GetRightFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 136841, 10, '36841^AutoMBOLPack',  'us_english',@nFunc