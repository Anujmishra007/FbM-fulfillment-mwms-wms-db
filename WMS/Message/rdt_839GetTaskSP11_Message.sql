
--rdt_839GetTaskSP11

exec rdt.rdtDropMsg 216101, 216150

execute rdt.rdtAddMsg 216101 ,10, '216101^No more task', 'us_english', 839

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 216101 AND 216150


