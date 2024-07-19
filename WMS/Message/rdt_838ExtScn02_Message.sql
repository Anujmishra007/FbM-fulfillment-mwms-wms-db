
--FCR-392
exec rdt.rdtdropmsg 217751 , 217800

execute rdt.rdtAddMsg 217751, 10, '217751NeedCart', 'us_english', 838
execute rdt.rdtAddMsg 217752, 10, '217752CartNotExist', 'us_english', 838
execute rdt.rdtAddMsg 217753, 10, '217753InvalidCart', 'us_english', 838
execute rdt.rdtAddMsg 217754, 10, '217754MissPSNo', 'us_english', 838
execute rdt.rdtAddMsg 217755, 10, '217755ScanInFail', 'us_english', 838
execute rdt.rdtAddMsg 217756, 10, '217756ScanInFail', 'us_english', 838
execute rdt.rdtAddMsg 217757, 10, '217757NotScanIn', 'us_english', 838
execute rdt.rdtAddMsg 217758, 10, '217758CartNoIs0', 'us_english', 838
execute rdt.rdtAddMsg 217759, 10, '217759UpdPackHDFail', 'us_english', 838

select * from rdt.rdtmsg (nolock) where message_id between 217751 AND 217800