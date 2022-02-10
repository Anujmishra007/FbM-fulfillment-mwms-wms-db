--rdt_1765ExtValidSP04
execute rdt.rdtDropMsg 157251, 157300

execute rdt.rdtAddMsg 157251, 10, '57251^Qty Not Match' ,     'us_english', 1765

-- WMS-15603
execute rdt.rdtAddMsg 157252, 10, '57252^Cannot Mix Sku',     'us_english', 1765
execute rdt.rdtAddMsg 157253, 10, '57253^Invalid To Loc',     'us_english', 1765

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 157251 AND 157300
