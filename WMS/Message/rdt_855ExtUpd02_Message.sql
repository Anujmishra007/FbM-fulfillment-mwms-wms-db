--rdt_855ExtUpd02
exec rdt.rdtDropMsg 116501 , 116550

execute rdt.rdtAddMsg 116501, 10, '16501^No Orders',        'us_english', 855
execute rdt.rdtAddMsg 116502, 10, '16502^Get Key Fail',     'us_english', 855
execute rdt.rdtAddMsg 116503, 10, '16503^InsPickHdrFail',   'us_english', 855
execute rdt.rdtAddMsg 116504, 10, '16504^InsPackHdrFail',   'us_english', 855
execute rdt.rdtAddMsg 116505, 10, '16505^InsPKInfoFail',    'us_english', 855
execute rdt.rdtAddMsg 116506, 10, '16506^InsPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 116507, 10, '16507^InsPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 116508, 10, '16508^UpdPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 116509, 10, '16509^InsDropIDFail',    'us_english', 855
execute rdt.rdtAddMsg 116510, 10, '16510^PackCfm Fail',     'us_english', 855
execute rdt.rdtAddMsg 116511, 10, '16511^Scan Out Fail',    'us_english', 855

select * from rdt.rdtmsg (nolock) where message_id between 116501 and 116550



