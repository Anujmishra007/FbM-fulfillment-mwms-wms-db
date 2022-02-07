--rdt_840GetOrders05
exec rdt.rdtDropMsg 168901 , 168950

execute rdt.rdtAddMsg 168901, 10, '168901 No Orders    ',   'us_english', 840
execute rdt.rdtAddMsg 168902, 10, '168902 NeedSortation',   'us_english', 840
execute rdt.rdtAddMsg 168903, 10, '168903 NeedSortation',   'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 168901 AND 168950


