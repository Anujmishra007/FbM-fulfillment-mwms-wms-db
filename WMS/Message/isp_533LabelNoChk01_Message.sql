--isp_533LabelNoChk01
exec rdt.rdtDropMsg 136301 , 136350

execute rdt.rdtAddMsg 136301, 10, '36301^ToLblNotExists',    'us_english', 533
execute rdt.rdtAddMsg 136302, 10, '36302^CrossPickSlip',     'us_english', 533

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 136301 AND 136350