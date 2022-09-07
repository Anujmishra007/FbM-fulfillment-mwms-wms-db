--rdt_599ExtUpd02
EXEC rdt.rdtDropMsg 189851, 189900

execute rdt.rdtAddMsg 189851, 10, '189851Pallet ID req',   'us_english', 599
execute rdt.rdtAddMsg 189852, 10, '189852SKU req',   'us_english', 599
execute rdt.rdtAddMsg 189853, 10, '189853DelPreSortErr',   'us_english', 599
execute rdt.rdtAddMsg 189854, 10, '189854ReverseToIDEr    ',   'us_english', 599
execute rdt.rdtAddMsg 189855, 10, '189855ReverseToIDEr ',   'us_english', 599
execute rdt.rdtAddMsg 189856, 10, '189856ReverseToIDEr ',   'us_english', 599

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '178901' AND '178950'