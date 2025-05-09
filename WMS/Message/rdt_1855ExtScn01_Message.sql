--FCR-652
EXECUTE rdt.rdtdropmsg 220751 , 220800

EXECUTE rdt.rdtAddMsg 220751, 10, '220751NeedPSNO',         'us_english', 1855, 0,'220751: PickSlip No Is Required'
EXECUTE rdt.rdtAddMsg 220752, 10, '220752InvalidPSNO',      'us_english', 1855,0, '220752: No Wave Found Under PSNO'
EXECUTE rdt.rdtAddMsg 220753, 10, '220753PKZoneNoTask',     'us_english', 1855,0, '220753: No Open Task Found in PKZone & Wave'
EXECUTE rdt.rdtAddMsg 220754, 10, '220754ReachCartLmt',     'us_english', 1855,0, '220754: Exceed Cart Limitation'
EXECUTE rdt.rdtAddMsg 220755, 10, '220755InvCase',          'us_english', 1855,0, '220755: Invalid Case ID'
EXECUTE rdt.rdtAddMsg 220756, 10, '220756GetGroupKeyFail',  'us_english', 1855,0, '220756: Get GroupKey failure'
EXECUTE rdt.rdtAddMsg 220757, 10, '220757NotUnderWave',     'us_english', 1855,0, '220757: Carton ID not under PSNO''s Wave'
EXECUTE rdt.rdtAddMsg 220758, 10, '220758NoTaskUnderPSNO',  'us_english', 1855,0, '220758: No open task under Wave'
EXECUTE rdt.rdtAddMsg 220759, 10, '220759CartonAssigned',   'us_english', 1855,0, '220759: Carton assigned'
EXECUTE rdt.rdtAddMsg 220760, 10, '220760CartonPicked',     'us_english', 1855,0, '220760: Carton already picked'
EXECUTE rdt.rdtAddMsg 220761, 10, '220761CartInUse',        'us_english', 1855,0, '220761: Cart In Use'
EXECUTE rdt.rdtAddMsg 220762, 10, '220762InvalidPSNO',      'us_english', 1855,0, '220762: PSNO not found'

--FCR-1755
EXECUTE rdt.rdtAddMsg 220763, 10, '220763PKZoneNoTask',     'us_english', 1855
EXECUTE rdt.rdtAddMsg 220764, 10, '220764NeedCartID',       'us_english', 1855
EXECUTE rdt.rdtAddMsg 220765, 10, '220765InvalidCartID',    'us_english', 1855
EXECUTE rdt.rdtAddMsg 220766, 10, '220766CartInUse',        'us_english', 1855
EXECUTE rdt.rdtAddMsg 220767, 10, '220767CartInUse',        'us_english', 1855
EXECUTE rdt.rdtAddMsg 220768, 10, '220768NeedMethod',       'us_english', 1855
EXECUTE rdt.rdtAddMsg 220769, 10, '220769InvalidMethod',    'us_english', 1855
EXECUTE rdt.rdtAddMsg 220770, 10, '220770InvalidMethod',    'us_english', 1855
EXECUTE rdt.rdtAddMsg 220771, 10, '220771GenGrpKeyFail',    'us_english', 1855
EXECUTE rdt.rdtAddMsg 220772, 10, '220772NeedToteID',       'us_english', 1855
EXECUTE rdt.rdtAddMsg 220773, 10, '220773NeedToteID',       'us_english', 1855
EXECUTE rdt.rdtAddMsg 220774, 10, '220774DuplicateScan',    'us_english', 1855
EXECUTE rdt.rdtAddMsg 220775, 10, '220775DiffCart',         'us_english', 1855, 0, '220775 Tote assigned to a different cart'
EXECUTE rdt.rdtAddMsg 220776, 10, '220776ReachCartLmt',     'us_english', 1855, 0, '220776 Exceed Cart Limitation'
EXECUTE rdt.rdtAddMsg 220777, 10, '220777PickNotComplete',  'us_english', 1855

EXECUTE rdt.rdtAddMsg 220779, 10, '220779CartID Invalid Format',    'us_english', 1855, 0, '220779 CartID Invalid Format'
EXECUTE rdt.rdtAddMsg 220780, 10, '220780ToteID Invalid Format',    'us_english', 1855, 0, '220780 ToteID Invalid Format'
EXECUTE rdt.rdtAddMsg 220781, 10, '220781Tote Not Release', 'us_english', 1855
select * from rdt.rdtmsg (nolock) where message_id between 220751 AND 220800
