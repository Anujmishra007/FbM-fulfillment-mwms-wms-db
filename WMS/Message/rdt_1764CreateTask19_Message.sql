--rdt_1764CreateTask19
--FCR-12990

EXECUTE rdt.rdtdropmsg 270201, 270250

EXECUTE rdt.rdtAddMsg 270201, 10, '270201^NoMezzLOC',             'us_english', 1764, 0, '270201 No Mezzanine Loc'
EXECUTE rdt.rdtAddMsg 270202, 10, '270202^WrongFinalLoc',         'us_english', 1764, 0, '270202 Taskdetail''s final location is not Mezzanine'
EXECUTE rdt.rdtAddMsg 270203, 10, '270203^GenerateKeyFail',       'us_english', 1764, 0, '270203 Generate TaskDetailKey fail'
EXECUTE rdt.rdtAddMsg 270204, 10, '270204^InsTaskFail',           'us_english', 1764, 0, '270204 Insert TaskDetailKey fail'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 270201 AND 270250