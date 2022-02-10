--rdt_1764ExtUpd12
exec rdt.rdtDropMsg 154201 , 154250

execute rdt.rdtAddMsg 154201, 10, '54201^FoundExtraUCC',    'us_english', 1764
execute rdt.rdtAddMsg 154202, 10, '54202^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154203, 10, '54203^UpdTaskdetFail',   'us_english', 1764
execute rdt.rdtAddMsg 154204, 10, '54204^Need DropID',      'us_english', 1764
execute rdt.rdtAddMsg 154205, 10, '54205^UpdTaskdetFail',   'us_english', 1764
execute rdt.rdtAddMsg 154206, 10, '54206^Scan-in Fail',     'us_english', 1764
execute rdt.rdtAddMsg 154207, 10, '54207^Ins PKHdr Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154208, 10, '54208^GetLabelNoFail',   'us_english', 1764
execute rdt.rdtAddMsg 154209, 10, '54209^INS PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154210, 10, '54210^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154211, 10, '54211^WSITF Fail',       'us_english', 1764
execute rdt.rdtAddMsg 154212, 10, '54212^UPDTaskDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 154213, 10, '54213^UPD PKDtl Fail',   'us_english', 1764

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 154201 AND 154250


