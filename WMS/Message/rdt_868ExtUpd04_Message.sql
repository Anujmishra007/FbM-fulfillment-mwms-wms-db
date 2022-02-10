--rdt_868ExtUpd04
rdt.rdtDropMsg 152201 , 152250

execute rdt.rdtAddMsg 152201, 10, '52201^Need OrderKey',    'us_english', 868
execute rdt.rdtAddMsg 152202, 10, '52202^Pickslip req',     'us_english', 868
execute rdt.rdtAddMsg 152203, 10, '52203^Not PackCfm',      'us_english', 868
execute rdt.rdtAddMsg 152204, 10, '52204^No Lbl Printer',   'us_english', 868
execute rdt.rdtAddMsg 152205, 10, '52205^No WinPrinter',    'us_english', 868
execute rdt.rdtAddMsg 152206, 10, '52206^Setup FilePath',   'us_english', 868
execute rdt.rdtAddMsg 152207, 10, '52207^InsPHdrFail',      'us_english', 868

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 152201 AND 152250