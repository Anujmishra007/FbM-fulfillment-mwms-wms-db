--rdt_841ExtUpdSP12
exec rdt.rdtDropMsg 152751 , 152800

execute rdt.rdtAddMsg 152751, 10, '52751^SKuNotIntote',     'us_english', 841
execute rdt.rdtAddMsg 152752, 10, '52752^SKUNotInOrder',    'us_english', 841
execute rdt.rdtAddMsg 152753, 10, '52753^QtyExceeded',      'us_english', 841
execute rdt.rdtAddMsg 152754, 10, '52754^UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 152755, 10, '52755^GetDetKeyFail',    'us_english', 841
execute rdt.rdtAddMsg 152756, 10, '52756^InstPKHdrFail',    'us_english', 841
execute rdt.rdtAddMsg 152757, 10, '52757^ScanInFail',       'us_english', 841
execute rdt.rdtAddMsg 152758, 10, '52758^InsPickHdrFail',   'us_english', 841
execute rdt.rdtAddMsg 152759, 10, '52759^UpdPickDetFail',   'us_english', 841
execute rdt.rdtAddMsg 152760, 10, '52760^CreatePHdrFail',   'us_english', 841
execute rdt.rdtAddMsg 152761, 10, '52761^ToteCompleted',    'us_english', 841
execute rdt.rdtAddMsg 152762, 10, '52762^NoLabelNoGen',     'us_english', 841
execute rdt.rdtAddMsg 152763, 10, '52763^NoTrackNoGen',     'us_english', 841
execute rdt.rdtAddMsg 152764, 10, '52764^InsCtnShpDtErr',   'us_english', 841
execute rdt.rdtAddMsg 152765, 10, '52765^UpdOrderFail',     'us_english', 841
execute rdt.rdtAddMsg 152766, 10, '52766^UpdPickDetFail',   'us_english', 841
execute rdt.rdtAddMsg 152767, 10, '52767^UpdPackDetFail',   'us_english', 841
execute rdt.rdtAddMsg 152768, 10, '52768^Over Packed',      'us_english', 841
execute rdt.rdtAddMsg 152769, 10, '52769^InsPackDetFail',   'us_english', 841
execute rdt.rdtAddMsg 152770, 10, '52770^UpdPackDetFail',   'us_english', 841
execute rdt.rdtAddMsg 152771, 10, '52771^InsPInfoFail',     'us_english', 841
execute rdt.rdtAddMsg 152772, 10, '52772^UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 152773, 10, '52773^UpdPickInfFail',   'us_english', 841
execute rdt.rdtAddMsg 152774, 10, '52774^UpdPickDtlFail',   'us_english', 841
execute rdt.rdtAddMsg 152775, 10, '52775^UpdPickDtlFail',   'us_english', 841
execute rdt.rdtAddMsg 152776, 10, '52776^No Lbl Printer',   'us_english', 841
execute rdt.rdtAddMsg 152777, 10, '52777^No WinPrinter',    'us_english', 841
execute rdt.rdtAddMsg 152778, 10, '52778^Setup FilePath',   'us_english', 841
execute rdt.rdtAddMsg 152779, 10, '52779^UpdOrdFail',       'us_english', 841
execute rdt.rdtAddMsg 152780, 10, '52780^PackCfm Fail',     'us_english', 841
execute rdt.rdtAddMsg 152781, 10, '52781^UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 152782, 10, '52782^UpdOrderFail',     'us_english', 841
execute rdt.rdtAddMsg 152783, 10, '52783^InsTrackLogErr',   'us_english', 841
execute rdt.rdtAddMsg 152784, 10, '52784^InsCtnShpDtErr',   'us_english', 841
execute rdt.rdtAddMsg 152785, 10, '52785^UpdPickInfFail',   'us_english', 841
execute rdt.rdtAddMsg 152786, 10, '52786^UpdPickDetFail',   'us_english', 841
execute rdt.rdtAddMsg 152787, 10, '52787^UpdPackDetFail',   'us_english', 841
execute rdt.rdtAddMsg 152788, 10, '52788^UpdOrdFail',       'us_english', 841
execute rdt.rdtAddMsg 152789, 10, '52789^PackCfm Fail',     'us_english', 841


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 152751 AND 152800

