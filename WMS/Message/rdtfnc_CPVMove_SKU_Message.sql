-- rdtfnc_CPVMove_SKU
execute rdt.rdtDropMsg 133501 , 133550	

execute rdt.rdtAddMsg 133501, 10, '133501 LOC needed',     'us_english'
execute rdt.rdtAddMsg 133502, 10, '133502 Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 133503, 10, '133503 Diff facility',  'us_english'
execute rdt.rdtAddMsg 133504, 10, '133504 LOC have UCC',   'us_english'
execute rdt.rdtAddMsg 133505, 10, '133505 Invalid ID',     'us_english'
execute rdt.rdtAddMsg 133506, 10, '133506 SKU needed',     'us_english'
execute rdt.rdtAddMsg 133507, 10, '133507 Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 133508, 10, '133508 No QTY to move', 'us_english'
execute rdt.rdtAddMsg 133509, 10, '133509 Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 133510, 10, '133510 Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 133511, 10, '133511 QTY needed',     'us_english'
execute rdt.rdtAddMsg 133512, 10, '133512 QTYAVL NotEnuf', 'us_english'
execute rdt.rdtAddMsg 133513, 10, '133513 ToLOC needed',   'us_english'
execute rdt.rdtAddMsg 133514, 10, '133514 Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 133515, 10, '133515 Diff facility',  'us_english'
execute rdt.rdtAddMsg 133516, 10, '133516^Same FromToLOC', 'us_english'
execute rdt.rdtAddMsg 133517, 10, '133517^Same FromToID',  'us_english'
execute rdt.rdtAddMsg 133518, 10, '133518^Invalid Format', 'us_english'
execute rdt.rdtAddMsg 133519, 10, '133519^Invalid Format', 'us_english'
execute rdt.rdtAddMsg 133520, 10, '133520^Invalid Format', 'us_english'
execute rdt.rdtAddMsg 133521, 10, '133521^Invalid LOT#',   'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 133501 AND 133550
