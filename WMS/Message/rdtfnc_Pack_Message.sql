-- rdtfnc_Pack
execute rdt.rdtDropMsg 100201, 100250

execute rdt.rdtAddMsg 100201, 10, '100201PSNO required ', 'us_english', 838
execute rdt.rdtAddMsg 100202, 10, '100202Invalid Format', 'us_english', 838
execute rdt.rdtAddMsg 100203, 10, '100203Pack confirmed', 'us_english', 838
execute rdt.rdtAddMsg 100204, 10, '100204Need QTY      ', 'us_english', 838
execute rdt.rdtAddMsg 100205, 10, '100205Invalid Option', 'us_english', 838
execute rdt.rdtAddMsg 100206, 10, '100206Need SKU      ', 'us_english', 838
execute rdt.rdtAddMsg 100207, 10, '100207Invalid SKU   ', 'us_english', 838
execute rdt.rdtAddMsg 100208, 10, '100208MultiSKUBarcod', 'us_english', 838
execute rdt.rdtAddMsg 100209, 10, '100209Invalid QTY   ', 'us_english', 838
execute rdt.rdtAddMsg 100210, 10, '100210NeedCartonType', 'us_english', 838
execute rdt.rdtAddMsg 100211, 10, '100211Bad CTN TYPE  ', 'us_english', 838
execute rdt.rdtAddMsg 100212, 10, '100212Need Cube     ', 'us_english', 838
execute rdt.rdtAddMsg 100213, 10, '100213Invalid cube  ', 'us_english', 838
execute rdt.rdtAddMsg 100214, 10, '100214Need Weight   ', 'us_english', 838
execute rdt.rdtAddMsg 100215, 10, '100215Invalid weight', 'us_english', 838
execute rdt.rdtAddMsg 100216, 10, '100216INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 100217, 10, '100217UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 100218, 10, '100218OptionRequired', 'us_english', 838
execute rdt.rdtAddMsg 100219, 10, '100219Invalid Option', 'us_english', 838
execute rdt.rdtAddMsg 100220, 10, '100220OptionRequired', 'us_english', 838
execute rdt.rdtAddMsg 100221, 10, '100221Invalid Option', 'us_english', 838
execute rdt.rdtAddMsg 100222, 10, '100222OptionRequired', 'us_english', 838
execute rdt.rdtAddMsg 100223, 10, '100223Invalid Option', 'us_english', 838
execute rdt.rdtAddMsg 100224, 10, '100224No carton     ', 'us_english', 838
execute rdt.rdtAddMsg 100225, 10, '100225DEL PKInfoFail', 'us_english', 838
execute rdt.rdtAddMsg 100226, 10, '100226DEL PAKDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 100227, 10, '100227Scan-In Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 100228, 10, '100228Not Scan-In   ', 'us_english', 838
execute rdt.rdtAddMsg 100229, 10, '100229Cannot EditUCC', 'us_english', 838
execute rdt.rdtAddMsg 100230, 10, '100230UCC scanned   ', 'us_english', 838
execute rdt.rdtAddMsg 100231, 10, '100231DisabledOption', 'us_english', 838
execute rdt.rdtAddMsg 100232, 10, '100232Need PS/DropID', 'us_english', 838
execute rdt.rdtAddMsg 100233, 10, '100233Invalid Format', 'us_english', 838
execute rdt.rdtAddMsg 100234, 10, '100234Invalid DropID', 'us_english', 838
execute rdt.rdtAddMsg 100235, 10, '100235Need PickHdr  ', 'us_english', 838
execute rdt.rdtAddMsg 100236, 10, '100236UPD PKInf Fail', 'us_english', 838
execute rdt.rdtAddMsg 100237, 10, '100237Scan-In Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 100238, 10, '100238Invalid QTY   ', 'us_english', 838
execute rdt.rdtAddMsg 100239, 10, '100239Need RefNo    ', 'us_english', 838
execute rdt.rdtAddMsg 100240, 10, '100240Need Length   ', 'us_english', 838
execute rdt.rdtAddMsg 100241, 10, '100241Invalid Length', 'us_english', 838
execute rdt.rdtAddMsg 100242, 10, '100242Need Width    ', 'us_english', 838
execute rdt.rdtAddMsg 100243, 10, '100243Invalid Width ', 'us_english', 838
execute rdt.rdtAddMsg 100244, 10, '100244Need Height   ', 'us_english', 838
execute rdt.rdtAddMsg 100245, 10, '100245Invalid Height', 'us_english', 838
execute rdt.rdtAddMsg 100246, 10, '100246Invalid Format', 'us_english', 838
execute rdt.rdtAddMsg 100247, 10, '100247NeedFromDropID', 'us_english', 838
execute rdt.rdtAddMsg 100248, 10, '100248Invalid SN    ', 'us_english', 838, 0, '100248Invalid Serial No'
execute rdt.rdtAddMsg 100249, 10, '100249SN Not Packed ', 'us_english', 838, 0, '100249Serial number cannot Be packed'
execute rdt.rdtAddMsg 100250, 10, '100250Serial Confirm', 'us_english', 838



SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 100201 and 100250 AND lang_code = 'ENG'


--UWP-43907
execute rdt.rdtDropMsg 267001, 267050

execute rdt.rdtAddMsg 267001, 10, '267001Need ToDropID ', 'us_english', 838
execute rdt.rdtAddMsg 267002, 10, '267002Bad ToDropID  ', 'us_english', 838

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 267001 and 267050 AND lang_code = 'ENG'