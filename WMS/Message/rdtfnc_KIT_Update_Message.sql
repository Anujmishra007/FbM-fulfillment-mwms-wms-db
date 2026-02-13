
--rdtfnc_KIT_Update
--258801 - 258850

exec rdt.rdtdropmsg 258801 , 258850

execute rdt.rdtAddMsg 258801, 10, '258801^KITRequired',     'us_english', 1877, 0, '258801: KITKey is required'
execute rdt.rdtAddMsg 258802, 10, '258802^InvalidKIT',      'us_english', 1877, 0, '258802: Invalid KIT'
execute rdt.rdtAddMsg 258803, 10, '258803^DiffStorer',      'us_english', 1877, 0, '258803: Different Storer'
execute rdt.rdtAddMsg 258804, 10, '258804^KitDtlMissing',   'us_english', 1877, 0, '258804: KIT Detail Not Found'
execute rdt.rdtAddMsg 258805, 10, '258805^KITClosed',       'us_english', 1877, 0, '258805: KIT is finalized'
execute rdt.rdtAddMsg 258806, 10, '258806^IDRequired',      'us_english', 1877, 0, '258806: ID is required'
execute rdt.rdtAddMsg 258807, 10, '258807^InvalidID',       'us_english', 1877, 0, '258807: Pallet Not Found'
execute rdt.rdtAddMsg 258808, 10, '258808^SKURequired',     'us_english', 1877, 0, '258808: SKU is required'
execute rdt.rdtAddMsg 258809, 10, '258809^InvalidSKU',      'us_english', 1877, 0, '258809: Invalid SKU'
execute rdt.rdtAddMsg 258810, 10, '258810^SKUNotInID',      'us_english', 1877, 0, '258810: SKU Not In ID'
execute rdt.rdtAddMsg 258811, 10, '258811^DiffFacility',    'us_english', 1877, 0, '258811: DiffFacility'
execute rdt.rdtAddMsg 258812, 10, '258812^InvalidPAZone',   'us_english', 1877, 0, '258812: Not In Qualified PAZone'
execute rdt.rdtAddMsg 258813, 10, '258813^InvalidID',       'us_english', 1877, 0, '258813: Pallet Not Found'
execute rdt.rdtAddMsg 258814, 10, '258814^KITDtlClosed',    'us_english', 1877, 0, '258814: KIT Detail is finalized'
execute rdt.rdtAddMsg 258815, 10, '258815^QtyRequired',     'us_english', 1877, 0, '258815: Qty is required'
execute rdt.rdtAddMsg 258816, 10, '258816^InvalidQty',      'us_english', 1877, 0, '258816: Invalid Qty'
execute rdt.rdtAddMsg 258817, 10, '258817^KITDtlClosed',    'us_english', 1877, 0, '258817: KIT Detail is finalized'
execute rdt.rdtAddMsg 258818, 10, '258818^ExceedLeftQty',   'us_english', 1877, 0, '258818: Input Qty exceed left qty'

select * from rdt.rdtmsg (nolock) where message_id between 258801 AND 258850