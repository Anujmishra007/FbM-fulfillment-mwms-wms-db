
--FCR-652

exec rdt.rdtdropmsg 220751 , 220800

execute rdt.rdtAddMsg 220751, 10, '220751NeedPSNO', 'us_english', 1855, 0,'220751: PickSlip No Is Required'
execute rdt.rdtAddMsg 220752, 10, '220752InvalidPSNO', 'us_english', 1855,0, '220752: No Wave Found Under PSNO'
execute rdt.rdtAddMsg 220753, 10, '220753PKZoneNoTask', 'us_english', 1855,0, '220753: No Open Task Found in PKZone & PSNO'
execute rdt.rdtAddMsg 220754, 10, '220754ReachCartLmt', 'us_english', 1855,0, '220754: Exceed Cart Limitation'
execute rdt.rdtAddMsg 220755, 10, '220755InvCase', 'us_english', 1855,0, '220755: Invalid Case ID'
execute rdt.rdtAddMsg 220756, 10, '220756GetGroupKeyFail', 'us_english', 1855,0, '220756: Get GroupKey failure'
execute rdt.rdtAddMsg 220757, 10, '220757NotUnderPSNO', 'us_english', 1855,0, '220757: Carton ID not under PSNO'
execute rdt.rdtAddMsg 220758, 10, '220758NoTaskUnderPSNO', 'us_english', 1855,0, '220758: No open task under PSNO'
execute rdt.rdtAddMsg 220759, 10, '220759CartonAssigned', 'us_english', 1855,0, '220759: Carton assigned'
execute rdt.rdtAddMsg 220760, 10, '220760CartonPicked', 'us_english', 1855,0, '220760: Carton already picked'
execute rdt.rdtAddMsg 220761, 10, '220761CartInUse', 'us_english', 1855,0, '220761: Cart In Use'

select * from rdt.rdtmsg (nolock) where message_id between 220751 AND 220800