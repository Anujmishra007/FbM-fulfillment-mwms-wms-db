--rdt_599ExtUpd01
EXEC rdt.rdtDropMsg 178901, 178950

execute rdt.rdtAddMsg 178901, 10, '178901 Pallet ID req',   'us_english', 882
execute rdt.rdtAddMsg 178902, 10, '178902 DelPreSortErr',   'us_english', 882
execute rdt.rdtAddMsg 178903, 10, '178903 ReverseUCCErr',   'us_english', 882

-- WMS-19126
execute rdt.rdtAddMsg 178904, 10, '178904 SKU req      ',   'us_english', 882
execute rdt.rdtAddMsg 178905, 10, '178905 ReverseToIDEr',   'us_english', 882

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '178901' AND '178950'