
--UWP-32214 Merge Code
exec rdt.rdtdropmsg 235801 , 235850

execute rdt.rdtAddMsg 235801, 10, '235801InvalidBatchNo',    'us_english', 838, 0, '235801 Invalid BatchNo'
execute rdt.rdtAddMsg 235802, 10, '235802 NotPicked',        'us_english', 838
execute rdt.rdtAddMsg 235803, 10, '235803 ShortPick',        'us_english', 838

select * from rdt.rdtmsg (nolock) where message_id between 235801 AND 235850