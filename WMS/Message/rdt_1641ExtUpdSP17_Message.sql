
execute rdt.rdtdropmsg 257521, 257540

execute rdt.rdtAddMsg 257521, 10, '257521:CartonExist',  'us_english', 1641, 0, '257521: Carton Exist'
execute rdt.rdtAddMsg 257522, 10, '257522:InsPLTFail',  'us_english', 1641, 0, '257522: Ins PLT Fail'
execute rdt.rdtAddMsg 257523, 10, '257523:InsPLTDetFail',  'us_english', 1641, 0, '257523: Ins PLT Det Fail'
execute rdt.rdtAddMsg 257524, 10, '257524:PLTKeyNotFound',  'us_english', 1641, 0, '257524: PLT Key Not Found'
execute rdt.rdtAddMsg 257525, 10, '257525:NoCtnScanned',  'us_english', 1641, 0, '257525: No Ctn Scanned'
execute rdt.rdtAddMsg 257526, 10, '257526:UpdPickDFail',  'us_english', 1641, 0, '257526: Upd PickD Fail'
execute rdt.rdtAddMsg 257527, 10, '257527:ClosePltFail',  'us_english', 1641, 0, '257527: Close Plt Fail'
execute rdt.rdtAddMsg 257528, 10, '257528:UpdDROPIDFail',  'us_english', 1641, 0, '257528: Upd DROPID Fail'
execute rdt.rdtAddMsg 257529, 10, '257529:UpdPltDtFail',  'us_english', 1641, 0, '257529: Upd PltDt Fail'
execute rdt.rdtAddMsg 257530, 10, '257530:UpdPltFail',  'us_english', 1641, 0, '257530: Upd Plt Fail'
execute rdt.rdtAddMsg 257531, 10, '257531:PltShipped',  'us_english', 1641, 0, '257531: Plt Shipped'





SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 257521 AND 257540