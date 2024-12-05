--rdtfnc_Outbound_PalletTempCapture_Message

execute rdt.rdtdropmsg 230151, 230200

execute rdt.rdtAddMsg 230151  ,10   ,'230151^MBOL is needed'      ,'us_english'  ,1870 ,0 ,'230151 - MBOL is needed'
execute rdt.rdtAddMsg 230152  ,10   ,'230152^MBOL not exist'      ,'us_english'  ,1870 ,0 ,'230152 - MBOL does not exist'
execute rdt.rdtAddMsg 230153  ,10   ,'230153^MBOL Shipped'        ,'us_english'  ,1870 ,0 ,'230153 - MBOL Shipped'
execute rdt.rdtAddMsg 230154  ,10   ,'230154^Diff Facility'       ,'us_english'  ,1870 ,0 ,'230154 - MBOL belongs to a different facility'
execute rdt.rdtAddMsg 230155  ,10   ,'230155^ID is needed'        ,'us_english'  ,1870 ,0 ,'230155 - ID/DROPID is needed'
execute rdt.rdtAddMsg 230156  ,10   ,'230156^Invalid ID'          ,'us_english'  ,1870 ,0 ,'230156 - Invalid ID'
execute rdt.rdtAddMsg 230157  ,10   ,'230157^ID not in MBOL'      ,'us_english'  ,1870 ,0 ,'230157 - ID does not belong to MBOL'
execute rdt.rdtAddMsg 230158  ,10   ,'230158^CodeLKUP Miss'       ,'us_english'  ,1870 ,0 ,'230158 - Code List entry is missing for %CODE%'
execute rdt.rdtAddMsg 230159  ,10   ,'230159^CodeLKUP Miss'       ,'us_english'  ,1870 ,0 ,'230159 - Item class code %CODE% needs to be maintained properly'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 230151 AND 230200

