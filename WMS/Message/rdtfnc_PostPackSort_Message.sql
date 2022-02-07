-- rdtfnc_PostPackSort
rdt.rdtDropMsg 144301 , 144350

execute rdt.rdtAddMsg 144301, 10, '44301^Value req',        'us_english', 1837
execute rdt.rdtAddMsg 144302, 10, '44302^Invalid Ctn',      'us_english', 1837
execute rdt.rdtAddMsg 144303, 10, '44303^No PPS LOC',       'us_english', 1837
execute rdt.rdtAddMsg 144304, 10, '44304^Assign Loc Err',   'us_english', 1837
execute rdt.rdtAddMsg 144305, 10, '44305^Value req',        'us_english', 1837
execute rdt.rdtAddMsg 144306, 10, '44306^Invalid Format',   'us_english', 1837
execute rdt.rdtAddMsg 144307, 10, '44307^ID In Use',        'us_english', 1837
execute rdt.rdtAddMsg 144308, 10, '44308^ID In Use',        'us_english', 1837
execute rdt.rdtAddMsg 144309, 10, '44309^OptionRequired',   'us_english', 1837
execute rdt.rdtAddMsg 144310, 10, '44310^Invalid Option',   'us_english', 1837
execute rdt.rdtAddMsg 144311, 10, '44311^Invalid Pallet',   'us_english', 1837
execute rdt.rdtAddMsg 144312, 10, '44312^Only Either 1',    'us_english', 1837
execute rdt.rdtAddMsg 144313, 10, '44313^Assign Loc Err',   'us_english', 1837
execute rdt.rdtAddMsg 144314, 10, '44314^Loc In Use',       'us_english', 1837
execute rdt.rdtAddMsg 144315, 10, '44315^Unlock Loc Err',   'us_english', 1837

--WMW12735
execute rdt.rdtAddMsg 144316, 10, '44316^CaseNotPickCfm',   'us_english', 1837
execute rdt.rdtAddMsg 144317, 10, '44317^CaseNotPickCfm',   'us_english', 1837

--wms-17386
execute rdt.rdtAddMsg 144318, 10, '44318^Unlock Loc Err',   'us_english', 1837

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 144301 AND 144350