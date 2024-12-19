--rdtfnc_Outbound_PalletTempCapture_Message
--FCR-1398
execute rdt.rdtdropmsg 230151, 230200

execute rdt.rdtAddMsg 230151  ,10   ,'230151^MBOL is needed'      ,'us_english'  ,1870 ,0 ,'230151 - MBOL is needed'
execute rdt.rdtAddMsg 230152  ,10   ,'230152^MBOL not exist'      ,'us_english'  ,1870 ,0 ,'230152 - MBOL does not exist'
execute rdt.rdtAddMsg 230153  ,10   ,'230153^MBOL Shipped'        ,'us_english'  ,1870 ,0 ,'230153 - MBOL Shipped'
execute rdt.rdtAddMsg 230154  ,10   ,'230154^Diff Facility'       ,'us_english'  ,1870 ,0 ,'230154 - MBOL belongs to a different facility'
execute rdt.rdtAddMsg 230155  ,10   ,'230155^ID is needed'        ,'us_english'  ,1870 ,0 ,'230155 - ID/DROPID is needed'
execute rdt.rdtAddMsg 230156  ,10   ,'230156^Invalid ID'          ,'us_english'  ,1870 ,0 ,'230156 - Invalid ID'
execute rdt.rdtAddMsg 230157  ,10   ,'230157^ID not in MBOL'      ,'us_english'  ,1870 ,0 ,'230157 - ID does not belong to MBOL'
execute rdt.rdtAddMsg 230158  ,10   ,'230158^CodeLKUP Miss'       ,'us_english'  ,1870 ,0 ,'230158 - Code List entry is missing'
execute rdt.rdtAddMsg 230159  ,10   ,'230159^ItemClsError'        ,'us_english'  ,1870 ,0 ,'230159 - Item class code needs to be maintained properly'
execute rdt.rdtAddMsg 230160  ,10   ,'230160^ItemClsError'        ,'us_english'  ,1870 ,0 ,'230160 - Item class code needs to be maintained properly: UDF01'
execute rdt.rdtAddMsg 230161  ,10   ,'230161^ItemClsError'        ,'us_english'  ,1870 ,0 ,'230161 - Item class code needs to be maintained properly: UDF02'
execute rdt.rdtAddMsg 230163  ,10   ,'230163^Temp is needed'      ,'us_english'  ,1870 ,0 ,'230163 - Temperature is needed'
execute rdt.rdtAddMsg 230164  ,10   ,'230164^Invalid Temp'        ,'us_english'  ,1870 ,0 ,'230164 - Invalid temperature'
execute rdt.rdtAddMsg 230165  ,10   ,'230165^Invalid Option'      ,'us_english'  ,1870 ,0 ,'230165 - Invalid Option'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 230151 AND 230200

