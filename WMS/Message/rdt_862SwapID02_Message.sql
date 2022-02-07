--rdt_862SwapID02
exec rdt.rdtDropMsg 122551 , 122600

execute rdt.rdtAddMsg 122551, 10, '22551^Wrong ID',      'us_english', 862
execute rdt.rdtAddMsg 122552, 10, '22552^Need ID',       'us_english', 862
execute rdt.rdtAddMsg 122553, 10, '22553^Invalid ID',    'us_english', 862
execute rdt.rdtAddMsg 122554, 10, '22554^ID Multi Rec',  'us_english', 862
execute rdt.rdtAddMsg 122555, 10, '22555^LOC Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122556, 10, '22556^SKU Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122557, 10, '22557^QTY Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122558, 10, '22558^ID Picked',     'us_english', 862
execute rdt.rdtAddMsg 122559, 10, '22559^L01 Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122560, 10, '22560^L05 Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122561, 10, '22561^L06 Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122562, 10, '22562^L07 Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122563, 10, '22563^L08 Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122564, 10, '22564^L12 Not Match', 'us_english', 862
execute rdt.rdtAddMsg 122565, 10, '22565^TaskOffsetErr', 'us_english', 862
execute rdt.rdtAddMsg 122566, 10, '22566^NothingSwapped','us_english', 862

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 122551 AND 122600
