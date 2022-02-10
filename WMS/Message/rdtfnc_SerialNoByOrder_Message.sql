-- rdtfnc_SerialNoReset
execute rdt.rdtDropMsg 75301, 75350

execute rdt.rdtAddMsg 75301, 10, '75301^Need ExtOrdKey', 'us_english'
execute rdt.rdtAddMsg 75302, 10, '75302^Bad ExtOrdKey',  'us_english'
execute rdt.rdtAddMsg 75303, 10, '75303^Invalid status', 'us_english'
execute rdt.rdtAddMsg 75304, 10, '75304^Need SerialNo',  'us_english'
execute rdt.rdtAddMsg 75305, 10, '75305^Same ExtOrdKey', 'us_english'
execute rdt.rdtAddMsg 75306, 10, '75306^SerialNo exist', 'us_english'
execute rdt.rdtAddMsg 75307, 10, '75307^GetKey Fail',    'us_english'
execute rdt.rdtAddMsg 75308, 10, '75308^InsSNOFail',     'us_english'
execute rdt.rdtAddMsg 75309, 10, '75309^SameExtOrd&SNO', 'us_english'

-- (ChewKP01)
execute rdt.rdtAddMsg 75310, 10, '75310^Atleast1InputReq', 'us_english'
execute rdt.rdtAddMsg 75311, 10, '75311^InvalidOrderKey', 'us_english'
execute rdt.rdtAddMsg 75312, 10, '75312^DecodeError', 'us_english'
