-- FCR-12284 (NYE018)
-- isp_ShipLabel06_RP - 263701 - 263750

EXECUTE rdt.rdtDropMsg 263701, 263750

EXECUTE rdt.rdtAddMsg 263701, 10, '263701^Base64DecodeErr', 'us_english', 593, 0, '263701: Base64 decode error for shipping label'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263701 AND 263750
