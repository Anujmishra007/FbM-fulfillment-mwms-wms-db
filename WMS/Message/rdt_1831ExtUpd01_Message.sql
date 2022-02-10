--rdt_1831ExtUpd01
exec rdt.rdtDropMsg 124501 , 124550

execute rdt.rdtAddMsg 124501, 10, '24501^DeleteLog Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124502, 10, '24502^InsertLog Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124503, 10, '24503^Updatelog Fail',   'us_english', 1831

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 124501 AND 124550