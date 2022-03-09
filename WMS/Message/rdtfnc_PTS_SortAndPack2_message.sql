--rdtfnc_PTS_SortAndPack2
execute rdt.rdtdropmsg 180951 , 181000

execute rdt.rdtAddMsg 180951, 10, '180951DropIDReq', 'us_english','762'
execute rdt.rdtAddMsg 180952, 10, '180952NoTask', 'us_english','762'
execute rdt.rdtAddMsg 180953, 10, '180953NoTask', 'us_english','762'
execute rdt.rdtAddMsg 180954, 10, '180954InvalidDropID',  'us_english','762'
execute rdt.rdtAddMsg 180955, 10, '180955InsPTLLogFail',  'us_english','762'
execute rdt.rdtAddMsg 180956, 10, '180956NeedSKU', 'us_english','762'
execute rdt.rdtAddMsg 180957, 10, '180957InvalidSKU', 'us_english','762'
execute rdt.rdtAddMsg 180958, 10, '180958DifferentSKU', 'us_english','762'
execute rdt.rdtAddMsg 180959, 10, '180959InvalidQty', 'us_english','762'
execute rdt.rdtAddMsg 180960, 10, '180960InvalidQty',    'us_english','762'
execute rdt.rdtAddMsg 180961, 10, '180961FullShortNoQTY',   'us_english','762'
execute rdt.rdtAddMsg 180962, 10, '180962UpdPTSLogFail', 'us_english','762'
execute rdt.rdtAddMsg 180963, 10, '180963OverPack', 'us_english','762'
execute rdt.rdtAddMsg 180964, 10, '180964ToLabelNoReq', 'us_english','762'
execute rdt.rdtAddMsg 180965, 10, '180965InvalidFormat', 'us_english','762'
execute rdt.rdtAddMsg 180966, 10, '180966UpdPTSLogFail',  'us_english','762'
execute rdt.rdtAddMsg 180967, 10, '180967InvalidDropID',  'us_english','762'
execute rdt.rdtAddMsg 180968, 10, '180968DropIDExist',   'us_english','762'
execute rdt.rdtAddMsg 180969, 10, '180969UpdPTSLogFail', 'us_english','762'
execute rdt.rdtAddMsg 180970, 10, '180970MultiSKUBarCod', 'us_english','762'
execute rdt.rdtAddMsg 180971, 10, '180971OptionReq', 'us_english','762'
execute rdt.rdtAddMsg 180972, 10, '180972InvalidOption', 'us_english','762'
execute rdt.rdtAddMsg 180973, 10, '180973UpdPTSLogFail',  'us_english','762'
execute rdt.rdtAddMsg 180974, 10, '180974UpdPTSLogFail',  'us_english','762'
execute rdt.rdtAddMsg 180975, 10, '180975InsPTSLogFail', 'us_english','762'
execute rdt.rdtAddMsg 180976, 10, '180976NoTask',  'us_english','762'
execute rdt.rdtAddMsg 180977, 10, '180977NoTask',  'us_english','762'
execute rdt.rdtAddMsg 180978, 10, '180978SameBarCodeSKU',  'us_english','762'


--select * from rdt.rdtmsg (nolock) where message_id between 180951 and 181000