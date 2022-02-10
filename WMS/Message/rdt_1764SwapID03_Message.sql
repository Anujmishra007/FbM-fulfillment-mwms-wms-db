-- rdt_1764SwapID03
execute rdt.rdtDropMsg 120201 , 120250

execute rdt.rdtAddMsg 120201, 10, '20201^Need ID',          'us_english', 1764
execute rdt.rdtAddMsg 120202, 10, '20202^BadTaskDtlKey',    'us_english', 1764
execute rdt.rdtAddMsg 120203, 10, '20203^Invalid ID',       'us_english', 1764
execute rdt.rdtAddMsg 120204, 10, '20204^ID multi rec',     'us_english', 1764
execute rdt.rdtAddMsg 120205, 10, '20205^LOC not match',    'us_english', 1764
execute rdt.rdtAddMsg 120206, 10, '20206^SKU not match',    'us_english', 1764
execute rdt.rdtAddMsg 120207, 10, '20207^QTY not match',    'us_english', 1764
execute rdt.rdtAddMsg 120208, 10, '20208^L01 not match',    'us_english', 1764
execute rdt.rdtAddMsg 120209, 10, '20209^L02 not match',    'us_english', 1764
execute rdt.rdtAddMsg 120210, 10, '20210^L04 not match',    'us_english', 1764
execute rdt.rdtAddMsg 120211, 10, '20211^ID task taken',    'us_english', 1764
execute rdt.rdtAddMsg 120212, 10, '20212^Swap FP only',     'us_english', 1764
execute rdt.rdtAddMsg 120213, 10, '20213^ID locked',        'us_english', 1764
execute rdt.rdtAddMsg 120214, 10, '20214^UPD Task Fail',    'us_english', 1764
execute rdt.rdtAddMsg 120215, 10, '20215^UPD Task Fail',    'us_english', 1764
execute rdt.rdtAddMsg 120216, 10, '20216^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 120217, 10, '20217^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 120218, 10, '20218^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 120219, 10, '20219^TaskOffsetErr',    'us_english', 1764
execute rdt.rdtAddMsg 120220, 10, '20220^TaskOffsetErr',    'us_english', 1764
execute rdt.rdtAddMsg 120221, 10, '20221^TaskOffsetErr',    'us_english', 1764
execute rdt.rdtAddMsg 120222, 10, '20222^UPD LLI Fail',     'us_english', 1764
execute rdt.rdtAddMsg 120223, 10, '20223^UPD LLI Fail',     'us_english', 1764

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 120201 AND 120250
