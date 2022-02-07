-- rdtfnc_PalletBuild_SerialNo
rdt.rdtDropMsg 133701 , 133750

execute rdt.rdtAddMsg 133701, 10, '33701^PKSlipNo req',     'us_english', 1644
execute rdt.rdtAddMsg 133702, 10, '33702^Invalid PKSlip',   'us_english', 1644
execute rdt.rdtAddMsg 133703, 10, '33703^Drop ID req',      'us_english', 1644
execute rdt.rdtAddMsg 133704, 10, '33704^Need UPC/SKU',     'us_english', 1644
execute rdt.rdtAddMsg 133705, 10, '33705^Need Case ID',     'us_english', 1644
execute rdt.rdtAddMsg 133706, 10, '33706^Need Serial No',   'us_english', 1644
execute rdt.rdtAddMsg 133707, 10, '33707^Invalid SKU',      'us_english', 1644
execute rdt.rdtAddMsg 133708, 10, '33708^MultiSKUBarcod',   'us_english', 1644
execute rdt.rdtAddMsg 133709, 10, '33709^Invalid Format',   'us_english', 1644
execute rdt.rdtAddMsg 133710, 10, '33710^Value Needed',     'us_english', 1644
execute rdt.rdtAddMsg 133711, 10, '33711^Invalid Option',   'us_english', 1644
execute rdt.rdtAddMsg 133712, 10, '33712^Value Needed',     'us_english', 1644
execute rdt.rdtAddMsg 133713, 10, '33713^Invalid Option',   'us_english', 1644
execute rdt.rdtAddMsg 133714, 10, '33714^Invalid Format',   'us_english', 1644


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 133701 AND 133750