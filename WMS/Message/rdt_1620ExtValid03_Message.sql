--rdt_1620ExtValid03
exec rdt.rdtDropMsg 112551 , 112600

execute rdt.rdtAddMsg 112551, 10, '12551^Inv Picker UOM',   'us_english', 1620
execute rdt.rdtAddMsg 112552, 10, '12552^Cannot Mix UOM',   'us_english', 1620
execute rdt.rdtAddMsg 112553, 10, '12553^UOM NO Task',      'us_english', 1620
execute rdt.rdtAddMsg 112554, 10, '12554^UOM NO Task',      'us_english', 1620
execute rdt.rdtAddMsg 112555, 10, '12555^LabelPrnterReq',   'us_english', 1620
execute rdt.rdtAddMsg 112556, 10, '12556^Cannot Mix UOM',   'us_english', 1620
execute rdt.rdtAddMsg 112557, 10, '12557^Cannot Mix UOM',   'us_english', 1620
execute rdt.rdtAddMsg 112558, 10, '12558^Drop ID Req',      'us_english', 1620
execute rdt.rdtAddMsg 112559, 10, '12559^DropID Not Req',   'us_english', 1620

select * from rdt.rdtmsg (nolock) where message_id between 112551 AND 112600