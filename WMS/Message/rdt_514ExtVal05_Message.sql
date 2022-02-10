--rdt_514ExtVal05
exec rdt.rdtDropMsg 136751 , 136800

execute rdt.rdtAddMsg 136751 ,10, '36751^No Modulized',   'us_english', 514
execute rdt.rdtAddMsg 136752 ,10, '36752^Need From ID',   'us_english', 514
execute rdt.rdtAddMsg 136753 ,10, '36753^Need To ID',     'us_english', 514
execute rdt.rdtAddMsg 136754 ,10, '36754^FromIDPackCfm',  'us_english', 514
execute rdt.rdtAddMsg 136755 ,10, '36755^ToID PackCfm',   'us_english', 514
execute rdt.rdtAddMsg 136756 ,10, '36756^Diff Ship To',   'us_english', 514

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 136751 AND 136800
