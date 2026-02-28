
execute rdt.rdtdropmsg 258251, 258300

execute rdt.rdtAddMsg 258251, 10, '258251:CartonExist',  'us_english', 1641, 0,    '258251: Carton Exist'
execute rdt.rdtAddMsg 258252, 10, '258252:InsPLTFail',  'us_english', 1641, 0,     '258252: Ins PLT Fail'
execute rdt.rdtAddMsg 258253, 10, '258253:InsPLTDetFail',  'us_english', 1641, 0,  '258253: Ins PLT Det Fail'
execute rdt.rdtAddMsg 258254, 10, '258254:PLTKeyNotFound',  'us_english', 1641, 0, '258254: PLT Key Not Found'
execute rdt.rdtAddMsg 258255, 10, '258255:NoCtnScanned',  'us_english', 1641, 0,   '258255: No Ctn Scanned'
execute rdt.rdtAddMsg 258256, 10, '258256:UpdPickDFail',  'us_english', 1641, 0,   '258256: Upd PickD Fail'
execute rdt.rdtAddMsg 258257, 10, '258257:ClosePltFail',  'us_english', 1641, 0,   '258257: Close Plt Fail'
execute rdt.rdtAddMsg 258258, 10, '258258:UpdDROPIDFail',  'us_english', 1641, 0,  '258258: Upd DROPID Fail'
execute rdt.rdtAddMsg 258259, 10, '258259:UpdPltDtFail',  'us_english', 1641, 0,   '258259: Upd PltDt Fail'
execute rdt.rdtAddMsg 258260, 10, '258260:UpdPltFail',  'us_english', 1641, 0,     '258260: Upd Plt Fail'
execute rdt.rdtAddMsg 258261, 10, '258261:PltShipped',  'us_english', 1641, 0,     '258261: Plt Shipped'





SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 258251 AND 258300