--rdt_841ExtUpdSP13
execute rdt.rdtdropmsg 153401 , 153450

execute rdt.rdtAddMsg 153401, 10, '53401^ToteCompleted',    'us_english', 841
execute rdt.rdtAddMsg 153402, 10, '53402^UpdWCSFail',       'us_english', 841
execute rdt.rdtAddMsg 153403, 10, '53403^UpdWCSDetFail',    'us_english', 841
execute rdt.rdtAddMsg 153404, 10, '53404^DelEcommLogFail',  'us_english', 841
execute rdt.rdtAddMsg 153405, 10, '53405^SKuNotIntote',     'us_english', 841
execute rdt.rdtAddMsg 153406, 10, '53406^SKUNotInOrder',    'us_english', 841
execute rdt.rdtAddMsg 153407, 10, '53407^QtyExceeded',      'us_english', 841
execute rdt.rdtAddMsg 153408, 10, '53408^UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 153409, 10, '53409^InsPickHdrFail',   'us_english', 841
execute rdt.rdtAddMsg 153410, 10, '53410^UpdPickDetFail',   'us_english', 841
execute rdt.rdtAddMsg 153411, 10, '53411^CreatePHdrFail',   'us_english', 841
execute rdt.rdtAddMsg 153412, 10, '53412^UpdPackDetFail',   'us_english', 841
execute rdt.rdtAddMsg 153413, 10, '53413^OVER PACKED',      'us_english', 841
execute rdt.rdtAddMsg 153414, 10, '53414^InsPackDetFail',   'us_english', 841
execute rdt.rdtAddMsg 153415, 10, '53415^InsPInfoFail',     'us_english', 841
execute rdt.rdtAddMsg 153416, 10, '53416^UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 153417, 10, '53417^InsPackDetFail',   'us_english', 841
execute rdt.rdtAddMsg 153418, 10, '53418^UpdOrderFail',     'us_english', 841
execute rdt.rdtAddMsg 153419, 10, '53419^InsTrackLogErr',   'us_english', 841
execute rdt.rdtAddMsg 153420, 10, '53420^NeedGenLblSP',     'us_english', 841
execute rdt.rdtAddMsg 153421, 10, '53421^NoLabelNoGen',     'us_english', 841
execute rdt.rdtAddMsg 153422, 10, '53422^NeedTrackNoSP',    'us_english', 841
execute rdt.rdtAddMsg 153423, 10, '53423^GenTrackNoFail',   'us_english', 841
execute rdt.rdtAddMsg 153424, 10, '53424^InsCtnShpDtErr',   'us_english', 841
execute rdt.rdtAddMsg 153425, 10, '53425^UpdOrderFail',     'us_english', 841
execute rdt.rdtAddMsg 153426, 10, '53426^UpdOrderFail',     'us_english', 841
execute rdt.rdtAddMsg 153427, 10, '53427^InsCtnShpDtErr',   'us_english', 841
execute rdt.rdtAddMsg 153428, 10, '53428^UpdOrdFail',       'us_english', 841
execute rdt.rdtAddMsg 153429, 10, '53429^GetDetKeyFail ',   'us_english', 841
execute rdt.rdtAddMsg 153430, 10, '53430^InstPKHdrFail ',   'us_english', 841
execute rdt.rdtAddMsg 153431, 10, '53431^ScanInFail ',      'us_english', 841
execute rdt.rdtAddMsg 153432, 10, '53432^UpdPickInfoErr',   'us_english', 841
execute rdt.rdtAddMsg 153433, 10, '53433^UpdPackDetFail',   'us_english', 841
execute rdt.rdtAddMsg 153434, 10, '53434^UpdPickDtlFail',   'us_english', 841
execute rdt.rdtAddMsg 153435, 10, '53435^UpdPickDtlFail',   'us_english', 841
execute rdt.rdtAddMsg 153436, 10, '53436^UpdPickInfFail',   'us_english', 841
execute rdt.rdtAddMsg 153437, 10, '53437^UpdOrdFail',       'us_english', 841
execute rdt.rdtAddMsg 153438, 10, '53438^JITX Orders',      'us_english', 841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 153401 AND 153450