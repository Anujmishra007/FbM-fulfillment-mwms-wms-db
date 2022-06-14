
-- isp1580LblNoDecode08
execute rdt.rdtDropMsg 162201 , 162250

execute rdt.rdtAddMsg 162201 , 10, '162201DuplicateUCCNo', 'us_english', 1580
execute rdt.rdtAddMsg 162202 , 10, '162202InvalidSKU', 'us_english', 1580
execute rdt.rdtAddMsg 162203 , 10, '162203BATCHNOTINASN', 'us_english', 1580
execute rdt.rdtAddMsg 162204 , 10, '162204NeedLongbarcod', 'us_english', 1580

select * from rdt.rdtmsg (nolock) where message_id between 162201 and 162250
