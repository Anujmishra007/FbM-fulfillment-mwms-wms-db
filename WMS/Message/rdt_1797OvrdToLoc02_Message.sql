--rdt_1797OvrdToLoc02
execute rdt.rdtDropMsg 263651, 263700

execute rdt.rdtAddMsg 263651, 10, '263651^BadRoomNumber', 'us_english', 1797, 4, '263651^BadRoomNumber'
execute rdt.rdtAddMsg 263652, 10, '263652^BadLocCategory', 'us_english', 1797, 4 ,'263652^BadLocCategory'
execute rdt.rdtAddMsg 263653, 10, '263653^LOC NOT EMPTY', 'us_english', 1797, 4, '263653^LOC NOT EMPTY'
execute rdt.rdtAddMsg 263654, 10, '263654^Loose pallet not allowed', 'us_english', 1797, 4, '263654^Loose pallet not allowed'
execute rdt.rdtAddMsg 263655, 10, '263655^Over max pallet capacity', 'us_english', 1797, 4, '263655^Over max pallet capacity'
execute rdt.rdtAddMsg 263656, 10, '263656^SKU + Batch mismatch', 'us_english', 1797, 4, '263656^SKU + Batch mismatch'

execute rdt.rdtAddMsg 263657, 10, '263657^DiffFacility',       'us_english', 1797, 4, '263657 Different Facility'
execute rdt.rdtAddMsg 263658, 10, '263658^DiffSectionKey',     'us_english', 1797, 4, '263658 Different SectionKey(storerkey)'
execute rdt.rdtAddMsg 263659, 10, '263659^InvLoc',             'us_english', 1797, 4, '263659 Invalid Location'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263651 AND 263700