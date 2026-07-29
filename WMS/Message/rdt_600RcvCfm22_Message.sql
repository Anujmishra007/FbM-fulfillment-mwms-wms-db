-- rdt_600RcvCfm22
-- FCR-14406: Michelin VN - DOT to FRESH/OLD with Configurable Cutoff Date
exec rdt.rdtDropMsg 275901, 275950

execute rdt.rdtAddMsg 275901, 10, '275901CutoffNotFound', 'us_english', 600
execute rdt.rdtAddMsg 275902, 10, '275902InvalidFormat ', 'us_english', 600
execute rdt.rdtAddMsg 275903, 10, '275903InvalidDate   ', 'us_english', 600

SELECT TOP 100 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 275901 AND 275950
