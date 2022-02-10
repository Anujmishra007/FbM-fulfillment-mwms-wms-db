--rdt_841ExtUpdSP15
execute rdt.rdtDropMsg 161751 , 161800	

execute rdt.rdtAddMsg 161751, 10, '61751^ToteCompleted',          'us_english',841
execute rdt.rdtAddMsg 161752, 10, '61752^UpdWCSFail',             'us_english',841
execute rdt.rdtAddMsg 161753, 10, '61753^UpdWCSDetFail',          'us_english',841
execute rdt.rdtAddMsg 161754, 10, '61754^DelEcommLogFail',        'us_english',841
execute rdt.rdtAddMsg 161755, 10, '61755^SKuNotIntote',           'us_english',841
execute rdt.rdtAddMsg 161756, 10, '61756^SKUNotInOrder',          'us_english',841
execute rdt.rdtAddMsg 161757, 10, '61757^QtyExceeded',            'us_english',841
execute rdt.rdtAddMsg 161758, 10, '61758^UpdEcommFail',           'us_english',841
execute rdt.rdtAddMsg 161759, 10, '61759^InsPickHdrFail',         'us_english',841
execute rdt.rdtAddMsg 161760, 10, '61760^UpdPickDetFail',         'us_english',841
execute rdt.rdtAddMsg 161761, 10, '61761^CreatePHdrFail',         'us_english',841
execute rdt.rdtAddMsg 161762, 10, '61762^UpdPackDetFail',         'us_english',841
execute rdt.rdtAddMsg 161763, 10, '61763^OVER PACKED',            'us_english',841
execute rdt.rdtAddMsg 161764, 10, '61764^InsPackDetFail',         'us_english',841
execute rdt.rdtAddMsg 161765, 10, '61765^InsPInfoFail',           'us_english',841
execute rdt.rdtAddMsg 161766, 10, '61766^UpdEcommFail',           'us_english',841
execute rdt.rdtAddMsg 161767, 10, '61767^InsPackDetFail',         'us_english',841
execute rdt.rdtAddMsg 161768, 10, '61768^UpdOrderFail',           'us_english',841
execute rdt.rdtAddMsg 161769, 10, '61769^InsTrackLogFail',        'us_english',841
execute rdt.rdtAddMsg 161770, 10, '61770^GenLblSPNotFound',       'us_english',841
execute rdt.rdtAddMsg 161771, 10, '61771^NoLabelNoGen',           'us_english',841
execute rdt.rdtAddMsg 161772, 10, '61772^GenTrackNoSPNotFound',   'us_english',841
execute rdt.rdtAddMsg 161773, 10, '61773^NoTrackNoGenerated',     'us_english',841
execute rdt.rdtAddMsg 161774, 10, '61774^InsCtnShpmentDetFail',   'us_english',841
execute rdt.rdtAddMsg 161775, 10, '61775^UpdOrderFail',           'us_english',841
execute rdt.rdtAddMsg 161776, 10, '61776^UpdOrderFail',           'us_english',841
execute rdt.rdtAddMsg 161777, 10, '61777^InsCtnShpmentDetFail',   'us_english',841
execute rdt.rdtAddMsg 161778, 10, '61778^UpdOrdFail',             'us_english',841
execute rdt.rdtAddMsg 161779, 10, '61779^GetDetKeyFail ',         'us_english',841
execute rdt.rdtAddMsg 161780, 10, '61780^InstPKHdrFail ',         'us_english',841
execute rdt.rdtAddMsg 161781, 10, '61781^ScanInFail ',            'us_english',841
execute rdt.rdtAddMsg 161782, 10, '61782^UpdPickInfoFail ',       'us_english',841
execute rdt.rdtAddMsg 161783, 10, '61783^UpdPackDetFail ',        'us_english',841
execute rdt.rdtAddMsg 161784, 10, '61784^UpdPickDetailFail ',     'us_english',841
execute rdt.rdtAddMsg 161785, 10, '61785^UpdPickDetailFail ',     'us_english',841
execute rdt.rdtAddMsg 161786, 10, '61786^UpdPickInfoFail ',       'us_english',841
execute rdt.rdtAddMsg 161787, 10, '61787^UpdOrdFail ',            'us_english',841
execute rdt.rdtAddMsg 161788, 10, '61788^UpdPackHdrFail',         'us_english',841
execute rdt.rdtAddMsg 161789, 10, '61789^UpdOrdFail',             'us_english',841

execute rdt.rdtAddMsg 161790, 10, '61790^GET LABEL Fail',         'us_english',841

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 161751 AND 161800	