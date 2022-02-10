--rdt_1628ExtValid01
exec rdt.rdtDropMsg 117551 , 117600

execute rdt.rdtAddMsg 117551, 10, '17551^NoLabelPrinter',   'us_english', 1628
execute rdt.rdtAddMsg 117552, 10, '17552^NO LoadKey',       'us_english', 1628
execute rdt.rdtAddMsg 117553, 10, '17553^Invalid DropID',   'us_english', 1628
execute rdt.rdtAddMsg 117554, 10, '17554^DropID Closed',    'us_english', 1628
execute rdt.rdtAddMsg 117555, 10, '17555^Invalid DropID',   'us_english', 1628

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 117551 AND 117600



