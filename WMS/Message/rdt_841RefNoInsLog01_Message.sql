-- rdt_841RefNoInsLog01
execute rdt.rdtdropmsg 168601, 168650

execute rdt.rdtAddMsg 168601, 10, '168601NoRecToProcess', 'us_english', 841

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 168601 AND 168650




