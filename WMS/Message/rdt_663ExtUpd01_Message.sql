-- rdt_663ExtUpd01
--235601 - 235650

execute rdt.rdtDropMsg 235601, 235650

execute rdt.rdtAddMsg 235601, 10, '235601UpdKitFail', 'us_english', 663, 0, '235601 Update Kit fail'
execute rdt.rdtAddMsg 235602, 10, '235602UpdKitFail', 'us_english', 663, 0, '235602 Update Kit fail'
execute rdt.rdtAddMsg 235603, 10, '235603UpdKitFail', 'us_english', 663, 0, '235603 Update Kit fail'

select * from rdt.rdtMsg (nolock)  where message_id between 235601 and 235650