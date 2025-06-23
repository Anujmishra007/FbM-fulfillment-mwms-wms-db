--rdt_PckCnfVLT_Message
--FCR-778
exec rdt.rdtdropmsg 226051 , 226100

-- 226051 - 226068 migrate from rdt_EurpoWMS_Message.sql
execute rdt.rdtAddMsg 226051, 10, '226051InsPHdrFail',        'us_english', 838
execute rdt.rdtAddMsg 226052, 10, '226052GenLabelNoFail',     'us_english', 838
execute rdt.rdtAddMsg 226053, 10, '226053GenLabelNoFail',     'us_english', 838
execute rdt.rdtAddMsg 226054, 10, '226054InsPackDtlFail',     'us_english', 838
execute rdt.rdtAddMsg 226055, 10, '226055UpdPackDtlFail',     'us_english', 838
execute rdt.rdtAddMsg 226056, 10, '226056INSPackInfFail',     'us_english', 838
execute rdt.rdtAddMsg 226057, 10, '226057UPDPackInfFail',     'us_english', 838
execute rdt.rdtAddMsg 226058, 10, '226058UPD UCC Fail',       'us_english', 838
execute rdt.rdtAddMsg 226059, 10, '226059SN QTYNotTally',     'us_english', 838
execute rdt.rdtAddMsg 226060, 10, '226060INSPackSNOFail',     'us_english', 838
execute rdt.rdtAddMsg 226061, 10, '226061MultiSKULimit',      'us_english', 838
execute rdt.rdtAddMsg 226062, 10, '226062DEL TmpSN Fail',     'us_english', 838

execute rdt.rdtAddMsg 226063, 10, '226063Offset error',       'us_english', 838
execute rdt.rdtAddMsg 226064, 10, '226064Offset error',       'us_english', 838
execute rdt.rdtAddMsg 226065, 10, '226065INS RDSNo Fail',     'us_english', 838
execute rdt.rdtAddMsg 226066, 10, '226066SNO ady scan',       'us_english', 838
execute rdt.rdtAddMsg 226067, 10, '226067INS PDInfoFail',     'us_english', 838
execute rdt.rdtAddMsg 226068, 10, '226068UPD PDInfoFail',     'us_english', 838

execute rdt.rdtAddMsg 226069, 10, '226069INS PALLETFail',     'us_english', 838
execute rdt.rdtAddMsg 226070, 10, '226070UPD PALLETFail',     'us_english', 838

execute rdt.rdtAddMsg 226071, 10, '226071GetKey Fail',         'us_english', 838
execute rdt.rdtAddMsg 226072, 10, '226072INS PKDtl Fail',      'us_english', 838
execute rdt.rdtAddMsg 226073, 10, '226073INS RefKeyFail',      'us_english', 838
execute rdt.rdtAddMsg 226074, 10, '226074UPD PKDtl Fail',      'us_english', 838
execute rdt.rdtAddMsg 226075, 10, '226075GetKey Fail',         'us_english', 838
execute rdt.rdtAddMsg 226076, 10, '226076UPD PKDtl Fail',      'us_english', 838


select * from rdt.rdtmsg (nolock) where message_id between 226051 AND 226100

 