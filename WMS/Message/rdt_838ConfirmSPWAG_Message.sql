--FCR-15060
exec rdt.rdtdropmsg 275751 , 275800

execute rdt.rdtAddMsg 275751, 10, '275751InsPHdrFail',        'us_english', 838
execute rdt.rdtAddMsg 275752, 10, '275752GenLabelNoFail',     'us_english', 838
execute rdt.rdtAddMsg 275753, 10, '275753GenLabelNoFail',     'us_english', 838
execute rdt.rdtAddMsg 275754, 10, '275754InsPackDtlFail',     'us_english', 838
execute rdt.rdtAddMsg 275755, 10, '275755UpdPackDtlFail',     'us_english', 838
execute rdt.rdtAddMsg 275756, 10, '275756INSPackInfFail',     'us_english', 838
execute rdt.rdtAddMsg 275757, 10, '275757UPDPackInfFail',     'us_english', 838
execute rdt.rdtAddMsg 275758, 10, '275758UPD UCC Fail',       'us_english', 838
execute rdt.rdtAddMsg 275759, 10, '275759SN QTYNotTally',     'us_english', 838
execute rdt.rdtAddMsg 275760, 10, '275760INSPackSNOFail',     'us_english', 838
execute rdt.rdtAddMsg 275761, 10, '275761SNO ady scan',       'us_english', 838
execute rdt.rdtAddMsg 275762, 10, '275762DEL TmpSN Fail',     'us_english', 838

execute rdt.rdtAddMsg 275763, 10, '275763Offset error',       'us_english', 838
execute rdt.rdtAddMsg 275764, 10, '275764Offset error',       'us_english', 838
execute rdt.rdtAddMsg 275765, 10, '275765INS RDSNo Fail',     'us_english', 838
execute rdt.rdtAddMsg 275766, 10, '275766SNO ady scan',       'us_english', 838
execute rdt.rdtAddMsg 275767, 10, '275767INS PDInfoFail',     'us_english', 838
execute rdt.rdtAddMsg 275768, 10, '275768UPD PDInfoFail',     'us_english', 838

execute rdt.rdtAddMsg 275769, 10, '275769INS PALLETFail',     'us_english', 838
execute rdt.rdtAddMsg 275770, 10, '275770UPD PALLETFail',     'us_english', 838

execute rdt.rdtAddMsg 275771, 10, '275771GetKey Fail',         'us_english', 838
execute rdt.rdtAddMsg 275772, 10, '275772INS PKDtl Fail',      'us_english', 838
execute rdt.rdtAddMsg 275773, 10, '275773INS RefKeyFail',      'us_english', 838
execute rdt.rdtAddMsg 275774, 10, '275774UPD PKDtl Fail',      'us_english', 838
execute rdt.rdtAddMsg 275775, 10, '275775GetKey Fail',         'us_english', 838
execute rdt.rdtAddMsg 275776, 10, '275776UPD PKDtl Fail',      'us_english', 838

execute rdt.rdtAddMsg 275777, 10, '275777UpdPackHdrFail',      'us_english', 838


select * from rdt.rdtmsg (nolock) where message_id between 275751 AND 275800