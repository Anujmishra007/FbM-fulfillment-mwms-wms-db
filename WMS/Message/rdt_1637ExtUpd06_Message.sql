--rdt_1637ExtUpd06
execute rdt.rdtdropmsg 156701 , 156750

execute rdt.rdtAddMsg 156701, 10, '56701^ValidateMBOLEr',   'us_english', 1637
execute rdt.rdtAddMsg 156702, 10, '56702^MBOL Ship Fail',   'us_english', 1637
execute rdt.rdtAddMsg 156703, 10, '56703^Close Plt Fail',   'us_english', 1637
execute rdt.rdtAddMsg 156704, 10, '56704^Setup FilePath',   'us_english', 1637

select * from rdt.rdtmsg (nolock) where message_id between 156701 AND 156750
