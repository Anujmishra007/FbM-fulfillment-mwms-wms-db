--rdt_PackByTrackNo_ValidateTrackNo
 execute rdt.rdtdropmsg 103701 , 103750

execute rdt.rdtAddMsg 103701, 10, '03701^Track# > 1 ORD',   'us_english', 840
execute rdt.rdtAddMsg 103702, 10, '03702^Inv ShipperKey',   'us_english', 840
execute rdt.rdtAddMsg 103703, 10, '03703^Inv TrackNo',      'us_english', 840



