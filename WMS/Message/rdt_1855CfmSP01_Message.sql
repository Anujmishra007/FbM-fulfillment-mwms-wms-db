--rdt_1855CfmSP01
--UWP-31257
execute rdt.rdtdropmsg 234701, 234750

execute rdt.rdtAddMsg 234701, 10, '234701Pick Not Found',   'us_english', 840
execute rdt.rdtAddMsg 234702, 10, '234702No Pickslip',      'us_english', 840
execute rdt.rdtAddMsg 234703, 10, '234703UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234704, 10, '234704UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234705, 10, '234705UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234706, 10, '234706UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234707, 10, '234707nspg_GetKey',      'us_english', 840
execute rdt.rdtAddMsg 234708, 10, '234708INS PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234709, 10, '234709INS RefKeyFail',   'us_english', 840
execute rdt.rdtAddMsg 234710, 10, '234710UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234711, 10, '234711UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234712, 10, '234712UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234713, 10, '234713UPD Task Fail',   'us_english', 840
execute rdt.rdtAddMsg 234714, 10, '234714UPD Task Fail',    'us_english', 840
execute rdt.rdtAddMsg 234715, 10, '234714UPD Task Fail',    'us_english', 840
execute rdt.rdtAddMsg 234716, 10, '234716UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234717, 10, '234717UPD Task Fail',    'us_english', 840
execute rdt.rdtAddMsg 234718, 10, '234718UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234719, 10, '234719UPD PKDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 234720, 10, '234720UPD PKDtl Fail',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 234701 AND 234750