--rdt_955DropIDDecod01
exec rdt.rdtDropMsg 116451 , 116500

execute rdt.rdtAddMsg 116451, 10, '16451^DropID Req',    'us_english', 955
execute rdt.rdtAddMsg 116452, 10, '16452^CTN ID No',     'us_english', 955
execute rdt.rdtAddMsg 116453, 10, '16453^Read, Key In',  'us_english', 955

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 116451 AND 116500