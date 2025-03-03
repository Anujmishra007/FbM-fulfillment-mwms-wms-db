--rdt_838ExtScn04_Message
--FCR-778
exec rdt.rdtdropmsg 223301 , 223350

execute rdt.rdtAddMsg 223301, 10, '223301IncorrectPalletType', 'us_english', 838, 0, N'Incorrect Pallet Type'
execute rdt.rdtAddMsg 223302, 10, '223302OverHeightLimit', 'us_english', 838, 0, N'Over Height Limit'
execute rdt.rdtAddMsg 223303, 10, '223303OverWeightLimit', 'us_english', 838, 0, N'Over Weight Limit'
execute rdt.rdtAddMsg 223304, 10, '223304OverPalletCube', 'us_english', 838, 0, N'Over Pallet Cube'
execute rdt.rdtAddMsg 223305, 10, '223305S/Nscan', 'us_english', 838, 0, N'S/N scan'
execute rdt.rdtAddMsg 223306, 10, '223306VASonly', 'us_english', 838, 0, N'VAS only'
execute rdt.rdtAddMsg 223307, 10, '223307INS PALLETFail',     'us_english', 838

select * from rdt.rdtmsg (nolock) where message_id between 223301 AND 223350

