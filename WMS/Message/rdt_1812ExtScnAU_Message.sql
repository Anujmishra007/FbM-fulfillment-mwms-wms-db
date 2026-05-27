-- 267601 - 267650
execute rdt.rdtDropMsg 267601 , 267650

execute rdt.rdtAddMsg 267601, 10, '267601 Invalid option',    'us_english', 1812
execute rdt.rdtAddMsg 267602, 10, '267602 Invalid option',    'us_english', 1812
execute rdt.rdtAddMsg 267603, 10, '267603 LabelNo needed',    'us_english', 1812
execute rdt.rdtAddMsg 267604, 10, '267604 LabelNo Used',      'us_english', 1812
execute rdt.rdtAddMsg 267605, 10, '267605 Invalid LabelNo',   'us_english', 1812
execute rdt.rdtAddMsg 267606, 10, '267606 Need Height',       'us_english', 1812
execute rdt.rdtAddMsg 267607, 10, '267607 Invalid Height',    'us_english', 1812
execute rdt.rdtAddMsg 267608, 10, '267608 Need Lane',         'us_english', 1812
execute rdt.rdtAddMsg 267609, 10, '267609 Mix Shipper',       'us_english', 1812
execute rdt.rdtAddMsg 267610, 10, '267610 Mix Shipper',       'us_english', 1812
execute rdt.rdtAddMsg 267611, 10, '267611 Lane Mix Wave',     'us_english', 1812
execute rdt.rdtAddMsg 267612, 10, '267612 Diff Lane',         'us_english', 1812 
execute rdt.rdtAddMsg 267613, 10, '267613 No Split Lane',     'us_english', 1812
execute rdt.rdtAddMsg 267614, 10, '267614 Upd TaskDetail Fail',    'us_english', 1812

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 267601 AND 267650
