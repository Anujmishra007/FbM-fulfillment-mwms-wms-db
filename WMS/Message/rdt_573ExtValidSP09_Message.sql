--rdt_573ExtValidSP09
exec rdt.rdtDropMsg 208601 , 208650

execute rdt.rdtAddMsg 208601, 10, '208601 UCC Diff PO# ',     'us_english', 573


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 208601 AND 208650

