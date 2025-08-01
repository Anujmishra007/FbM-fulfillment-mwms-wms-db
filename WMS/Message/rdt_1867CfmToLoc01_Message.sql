--rdt_1867CfmToLoc01
exec rdt.rdtDropMsg 227201, 227250

execute rdt.rdtAddMsg 227201, 10, '227201^Confirm Fail', 'us_english', 1867
execute rdt.rdtAddMsg 227202, 10, '227202^Upd Pick confirm', 'us_english', 1867
execute rdt.rdtAddMsg 227203, 10, '227203^InsPHdrFail', 'us_english', 1867
execute rdt.rdtAddMsg 227204, 10, '227204^InsPackDtlFail', 'us_english', 1867
execute rdt.rdtAddMsg 227205, 10, '227205^InsPackDtlFail', 'us_english', 1867

execute rdt.rdtAddMsg 227206, 10, '227206^GetKey TransmitLogKey2 Fail.', 'us_english', 1867
execute rdt.rdtAddMsg 227207, 10, '227207^INSERT TRANSMITLOG2 Fail', 'us_english', 1867

--FCR-1872
execute rdt.rdtAddMsg 227208, 10, '227208^GetKeyFailed',    'us_english', 1867
execute rdt.rdtAddMsg 227209, 10, '227209^InsTaskFailed',   'us_english', 1867