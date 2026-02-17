
execute rdt.rdtdropmsg 242151, 242200

execute rdt.rdtAddMsg 242151, 10, '242151LocNotPickFace',  'us_english', 511, 0, '242151: Location not in Pickface Zone'
execute rdt.rdtAddMsg 242152, 10, '242152UnassignedZone',  'us_english', 511, 0, '242152: Location not in assigned Zone'





SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 242151 AND 242200
