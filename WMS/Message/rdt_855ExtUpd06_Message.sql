--rdt_855ExtUpd06
exec rdt.rdtDropMsg 161451 , 161500

execute rdt.rdtAddMsg 161451, 10, '61451^No Orders',        'us_english', 855
execute rdt.rdtAddMsg 161452, 10, '61452^Get Key Fail',     'us_english', 855
execute rdt.rdtAddMsg 161453, 10, '61453^InsPickHdrFail',   'us_english', 855
execute rdt.rdtAddMsg 161454, 10, '61454^InsPackHdrFail',   'us_english', 855
execute rdt.rdtAddMsg 161455, 10, '61455^InsPKInfoFail',    'us_english', 855
execute rdt.rdtAddMsg 161456, 10, '61456^InsPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 161457, 10, '61457^InsPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 161458, 10, '61458^UpdPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 161459, 10, '61459^InsDropIDFail',    'us_english', 855
execute rdt.rdtAddMsg 161460, 10, '61460^PackCfm Fail',     'us_english', 855
execute rdt.rdtAddMsg 161461, 10, '61461^Scan Out Fail',    'us_english', 855

select * from rdt.rdtmsg (nolock) where message_id between 161451 and 161500



