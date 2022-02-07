--rdt_1653ExtValid01
execute rdt.rdtDropMsg 156401, 156450

execute rdt.rdtAddMsg 156401, 10, '56401^Setup CODELKUP',   'us_english', 1653
execute rdt.rdtAddMsg 156402, 10, '56402^Order Not Pack',   'us_english', 1653
execute rdt.rdtAddMsg 156403, 10, '56403^Pallet Closed',    'us_english', 1653
execute rdt.rdtAddMsg 156404, 10, '56404^Pallet Closed',    'us_english', 1653
execute rdt.rdtAddMsg 156405, 10, '56405^Over Plt Limit',   'us_english', 1653
execute rdt.rdtAddMsg 156406, 10, '56406^PltMix OrdType',   'us_english', 1653

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 156401 AND 156450