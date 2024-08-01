
--FCR-652

exec rdt.rdtdropmsg 220751 , 220800

execute rdt.rdtAddMsg 220751, 10, '220751NeedPSNO', 'us_english', 1855, '220751: PickSlip No Is Required'
execute rdt.rdtAddMsg 220752, 10, '220752InvalidPSNO', 'us_english', 1855, '220752: No Wave Found Under PSNO'
execute rdt.rdtAddMsg 220752, 10, '220753PKZoneNoTask', 'us_english', 1855, '220753: No Task Found in PKZone & Wave'

select * from rdt.rdtmsg (nolock) where message_id between 220751 AND 220800