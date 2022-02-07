

-- rdt_1842ExtValid01
execute rdt.rdtDropMsg 155851  , 155900

execute rdt.rdtAddMsg 155851, 10, '155851SKUNotInOrders', 'us_english', 638
execute rdt.rdtAddMsg 155852, 10, '155852OverReceive', 'us_english', 638



select * from rdt.rdtmsg (nolock) where message_id between '155251' and '155300'