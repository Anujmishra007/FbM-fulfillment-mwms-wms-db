--rdt_520ExtScn01
exec rdt.rdtDropMsg 217551 , 217600

execute rdt.rdtAddMsg 217551, 10, '217551^SKU Not at location',     'us_english', 520
execute rdt.rdtAddMsg 217552, 10, '217552^Need FROM LOC      ',     'us_english', 520
execute rdt.rdtAddMsg 217553, 10, '217553^InvalidFromLoc     ',     'us_english', 520
execute rdt.rdtAddMsg 217554, 10, '217554^Need SKU           ',     'us_english', 520

execute rdt.rdtAddMsg 217555, 10, '217555^Invalid SKU        ',     'us_english', 520
execute rdt.rdtAddMsg 217556, 10, '217556^NoQTYtoPutaway     ',     'us_english', 520
execute rdt.rdtAddMsg 217557, 10, '217557^No Rec Found       ',     'us_english', 520