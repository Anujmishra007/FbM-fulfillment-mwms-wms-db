-- rdtShipPLabel
exec rdt.rdtDropMsg 85251, 85300

execute rdt.rdtAddMsg 85251, 10, '85251^Need OrderKey ', 'us_english', 593
execute rdt.rdtAddMsg 85252, 10, '85252^Bad OrderKey  ', 'us_english', 593
execute rdt.rdtAddMsg 85253, 10, '85253^Order shipped ', 'us_english', 593
execute rdt.rdtAddMsg 85254, 10, '85254^Order cancel  ', 'us_english', 593
execute rdt.rdtAddMsg 85255, 10, '85255^BadOrderStatus', 'us_english', 593
execute rdt.rdtAddMsg 85256, 10, '85256^Order SOStatus', 'us_english', 593
execute rdt.rdtAddMsg 85257, 10, '85257^OrdNotLoadPlan', 'us_english', 593
execute rdt.rdtAddMsg 85258, 10, '85258^LabelPrnterReq', 'us_english', 593

--(ChewKP01)
execute rdt.rdtAddMsg 85259, 10, '85259^InputReq', 'us_english', 593
execute rdt.rdtAddMsg 85260, 10, '85260^InvalidOrder', 'us_english', 593
execute rdt.rdtAddMsg 85261, 10, '85261^InvalidTrackNo', 'us_english', 593

-- (ChewKP02) 
execute rdt.rdtAddMsg 85262, 10, '85262^SKUReq', 'us_english', 593
execute rdt.rdtAddMsg 85263, 10, '85263^InvalidSKU', 'us_english', 593
execute rdt.rdtAddMsg 85264, 10, '85264^MultiSKUBarCod', 'us_english', 593
execute rdt.rdtAddMsg 85265, 10, '85265^InvalidSKU', 'us_english', 593

-- (james01)
execute rdt.rdtAddMsg 85266, 10, '85266^INVALID UDF01',   'us_english', 593