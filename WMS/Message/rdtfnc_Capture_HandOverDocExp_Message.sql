-- rdtfnc_Capture_HandOverDocExp
rdt.rdtDropMsg 167851, 167900

execute rdt.rdtAddMsg 167851, 10, '167851^Need Option  ', 'us_english', 1853
execute rdt.rdtAddMsg 167852, 10, '167852^Invalid Opt  ', 'us_english', 1853
execute rdt.rdtAddMsg 167853, 10, '167853^GetKey Fail  ', 'us_english', 1853
execute rdt.rdtAddMsg 167854, 10, '167854^Need ToLoc   ', 'us_english', 1853
execute rdt.rdtAddMsg 167855, 10, '167855^Need DocNo   ', 'us_english', 1853
execute rdt.rdtAddMsg 167856, 10, '167856^DocNo Exists ', 'us_english', 1853
execute rdt.rdtAddMsg 167857, 10, '167857^Ins Fail     ', 'us_english', 1853
execute rdt.rdtAddMsg 167858, 10, '167858^Need Option  ', 'us_english', 1853
execute rdt.rdtAddMsg 167859, 10, '167859^Invalid Opt  ', 'us_english', 1853
execute rdt.rdtAddMsg 167860, 10, '167860^Upd Fail     ', 'us_english', 1853
execute rdt.rdtAddMsg 167861, 10, '167861^Invalid Loc  ', 'us_english', 1853
execute rdt.rdtAddMsg 167862, 10, '167862^Invalid DocNo', 'us_english', 1853

--wms-17807
execute rdt.rdtAddMsg 167863, 10, '167863^Need Loc     ', 'us_english', 1853
execute rdt.rdtAddMsg 167864, 10, '167864^Invalid Loc  ', 'us_english', 1853
execute rdt.rdtAddMsg 167865, 10, '167865^Need SKU     ', 'us_english', 1853
execute rdt.rdtAddMsg 167866, 10, '167866^Invalid SKU  ', 'us_english', 1853
execute rdt.rdtAddMsg 167867, 10, '167867MultiSKUBarCod', 'us_english', 1853
execute rdt.rdtAddMsg 167868, 10, '167868^GetKey Fail  ', 'us_english', 1853
execute rdt.rdtAddMsg 167869, 10, '167869^Ins Fail     ', 'us_english', 1853
execute rdt.rdtAddMsg 167870, 10, '167870^Invalid Loc  ', 'us_english', 1853
execute rdt.rdtAddMsg 167871, 10, '167871^Invalid SKU  ', 'us_english', 1853



SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 167851 and 167900



