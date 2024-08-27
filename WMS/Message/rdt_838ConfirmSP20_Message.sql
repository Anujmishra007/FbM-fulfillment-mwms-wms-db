
--FCR-392
exec rdt.rdtdropmsg 218401 , 218450

execute rdt.rdtAddMsg 218401, 10, '218401GentPKDFail', 'us_english', 838
execute rdt.rdtAddMsg 218402, 10, '218402GetPKDFail', 'us_english', 838
execute rdt.rdtAddMsg 218403, 10, '218403GetPKDKeyFail', 'us_english', 838
execute rdt.rdtAddMsg 218404, 10, '218404InsNewPKDFail', 'us_english', 838
execute rdt.rdtAddMsg 218405, 10, '218405DupPackInfo', 'us_english', 838
execute rdt.rdtAddMsg 218406, 10, '218406InsExtPkdFail', 'us_english', 838
execute rdt.rdtAddMsg 218407, 10, '218407UpdPKDFail', 'us_english', 838
execute rdt.rdtAddMsg 218408, 10, '218408GenPKDKeyFail', 'us_english', 838
execute rdt.rdtAddMsg 218409, 10, '218409InsPKDFail', 'us_english', 838
execute rdt.rdtAddMsg 218410, 10, '218410UpdPKDFail', 'us_english', 838
execute rdt.rdtAddMsg 218411, 10, '218411UpdtPKDFail', 'us_english', 838
execute rdt.rdtAddMsg 218412, 10, '218412DeltPKDFail', 'us_english', 838
execute rdt.rdtAddMsg 218413, 10, '218413NothingToPack', 'us_english', 838
execute rdt.rdtAddMsg 218414, 10, '218414ExceedUnpackQty', 'us_english', 838
execute rdt.rdtAddMsg 218415, 10, '218415NoCartType', 'us_english', 838, 0, '218415 No CartonType In PSNO'

select * from rdt.rdtmsg (nolock) where message_id between 218401 AND 218450