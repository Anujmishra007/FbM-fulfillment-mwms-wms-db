
--rdt_600RcvCfm10
execute rdt.rdtdropmsg 168301  , 168350

execute rdt.rdtAddMsg 168301, 10, '168301UpdRDFail',   'us_english',600
execute rdt.rdtAddMsg 168302, 10, '168302Overreceive',   'us_english',600
