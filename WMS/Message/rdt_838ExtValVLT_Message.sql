--rdt_838ExtValVLT_Message
--FCR-778
exec rdt.rdtdropmsg 223601 , 223650

-- 223601 - 223612 migrate from rdt_EurpoWMS_Message.sql
execute rdt.rdtAddMsg 223601, 10, '223601BothDropIDNeeded',    'us_english', 838, 0 , N'223601 Both DropID Needed'
execute rdt.rdtAddMsg 223602, 10, '223602 Invalid Format',     'us_english', 838
execute rdt.rdtAddMsg 223603, 10, '223603OtherOrderDropID',    'us_english', 838, 0 , N'223603 Other Order DropID'
execute rdt.rdtAddMsg 223604, 10, '223604ToDropIDISUsed',      'us_english', 838, 0 , N'223604 ToDropID is Used'
execute rdt.rdtAddMsg 223605, 10, '223605OrderNotStaged',      'us_english', 838, 0 , N'223605 Order Not Staged'
execute rdt.rdtAddMsg 223606, 10, '223606SingleSKULimit',      'us_english', 838, 0 , N'223606 Single SKU Limit'
execute rdt.rdtAddMsg 223607, 10, '223607 MultiSKULimit',      'us_english', 838, 0 , N'223607 Multi SKU Limit'
execute rdt.rdtAddMsg 223608, 10, '223608 Pack 1 EA',          'us_english', 838
execute rdt.rdtAddMsg 223609, 10, '223609 InvCon/DropID',      'us_english', 838
execute rdt.rdtAddMsg 223610, 10, '223610SingleSKULimit',      'us_english', 838, 0 , N'223610 Single SKU Limit'
execute rdt.rdtAddMsg 223611, 10, '223611 MultiSKULimit',      'us_english', 838, 0 , N'223611 Multi SKU Limit'
execute rdt.rdtAddMsg 223612, 10, '223612Exists,UseEdit',      'us_english', 838, 0 , N'223612 Exists, UseEdit'

execute rdt.rdtAddMsg 223613, 10, '223613CubeLimit',           'us_english', 838, 0 , N'223613 Cube limit exceeded. The quantity cannot be added'
execute rdt.rdtAddMsg 223614, 10, '223614WeightLimit',         'us_english', 838, 0 , N'223614 Weight limit exceeded. The quantity cannot be added'
execute rdt.rdtAddMsg 223615, 10, '223615CubeLimit',           'us_english', 838, 0 , N'223615 Cube limit exceeded. The quantity cannot be added'
execute rdt.rdtAddMsg 223616, 10, '223616WeightLimit',         'us_english', 838, 0 , N'223616 Weight limit exceeded. The quantity cannot be added'
execute rdt.rdtAddMsg 223617, 10, '223617ProductGroupLimit',   'us_english', 838, 0 , N'223617 Product Grouping limit exceeded'
execute rdt.rdtAddMsg 223618, 10, '223618MixedBrandsLimit',    'us_english', 838, 0 , N'223618 Mixed Brands limit exceeded'


select * from rdt.rdtmsg (nolock) where message_id between 223601 AND 223650

 