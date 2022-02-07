--rdt_860DropIDDecod02
exec rdt.rdtDropMsg 115901 , 115950

execute rdt.rdtAddMsg 115901, 10, '15901^DropID Req',    'us_english', 860
execute rdt.rdtAddMsg 115902, 10, '15902^CTN ID No',     'us_english', 860
execute rdt.rdtAddMsg 115903, 10, '15903^Read, Key In',  'us_english', 860

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 115901 AND 115950

