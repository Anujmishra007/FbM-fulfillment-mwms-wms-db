--rdt_573ExtValidSP02
rdt.rdtDropMsg 141201 , 141250

execute rdt.rdtAddMsg 141201, 10, '41201^UCC Mix SKU',   'us_english', 573
execute rdt.rdtAddMsg 141202, 10, '41202^Need Cubic',    'us_english', 573
execute rdt.rdtAddMsg 141203, 10, '41203^Mix PO',        'us_english', 573
execute rdt.rdtAddMsg 141204, 10, '41204^Mix PO',        'us_english', 573

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141201 AND 141250