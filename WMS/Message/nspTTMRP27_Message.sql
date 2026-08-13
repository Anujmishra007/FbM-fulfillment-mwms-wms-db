-- nspTTMRP27
-- 277801 - 277850


EXECUTE rdt.rdtdropmsg 277801, 277850

EXECUTE rdt.rdtAddMsg 277801, 10, '277801^UpdTaskDetFail', 'us_english', 1764, 0, '277801: Update task detail failed (assign)'
EXECUTE rdt.rdtAddMsg 277802, 10, '277802^UpdTaskDetFail', 'us_english', 1764, 0, '277802: Update task detail failed (sibling)'
EXECUTE rdt.rdtAddMsg 277803, 10, '277803^UpdTaskDetFail', 'us_english', 1764, 0, '277803: Update task detail failed (RefTaskKey)'
EXECUTE rdt.rdtAddMsg 277804, 10, '277804^LckTaskDetFail', 'us_english', 1764, 0, '277804: Failed to lock tasks with same GroupKey'

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 277801 AND 277850
