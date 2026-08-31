-- 267951 - 268000 FCR-12622 (NYE018)
-- rdt_1628ExtValid11

execute rdt.rdtDropMsg 267951 , 268000

execute rdt.rdtAddMsg 267951, 10, '267951^LaneNotAssign', 'us_english', 1628
execute rdt.rdtAddMsg 267952, 10, '267952^LaneNotAssign', 'us_english', 1628
execute rdt.rdtAddMsg 267953, 10, '267953^NoOrderInWave', 'us_english', 1628


select * from rdt.rdtmsg (nolock) where message_id between 267951 AND 268000
