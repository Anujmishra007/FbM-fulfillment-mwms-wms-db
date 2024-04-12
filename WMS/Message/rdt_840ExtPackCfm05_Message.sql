--rdt_840ExtPackCfm05
execute rdt.rdtdropmsg 212451 , 212500

execute rdt.rdtAddMsg 212451, 10, '212451 ConfPackFail ',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 212451 AND 212500