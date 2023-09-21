--rdt_607ExtVal06
exec rdt.rdtDropMsg 204251 , 204300	

execute rdt.rdtAddMsg 204251, 10, '204251 SortMethodReq', 'us_english', 607
execute rdt.rdtAddMsg 204252, 10, '204252 Over Receive ', 'us_english', 607

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 204251 AND 204300


