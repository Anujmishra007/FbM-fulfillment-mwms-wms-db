--rdt_1653ExtValid03
execute rdt.rdtDropMsg 193651 , 193700

execute rdt.rdtAddMsg 193651, 10, '193651 Setup CODELKUP',   'us_english', 1653
execute rdt.rdtAddMsg 193652, 10, '193652 Order Not Pack',   'us_english', 1653
execute rdt.rdtAddMsg 193653, 10, '193653 Pallet Closed',    'us_english', 1653
execute rdt.rdtAddMsg 193654, 10, '193654 Pallet Closed',    'us_english', 1653
execute rdt.rdtAddMsg 193655, 10, '193655 Over Plt Limit',   'us_english', 1653
execute rdt.rdtAddMsg 193656, 10, '193656 PltMix OrdType',   'us_english', 1653

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 193651 AND 193700