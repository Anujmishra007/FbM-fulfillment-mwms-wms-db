
--rdt_825ExtUpdJCB

execute rdt.rdtDropMsg 218093, 218097


EXECUTE rdt.rdtAddMsg 218093, 10, 'Pallet not exists'    , 'us_english', 825
EXECUTE rdt.rdtAddMsg 218094, 10, 'Dims NOT >=20 <=400'  , 'us_english', 825
EXECUTE rdt.rdtAddMsg 218095, 10, '>1 SKU got no weight' , 'us_english', 825
EXECUTE rdt.rdtAddMsg 218096, 10, 'Weight is < 20 KG'    , 'us_english', 825
EXECUTE rdt.rdtAddMsg 218097, 10, 'SKU calc weight <= 0' , 'us_english', 825

