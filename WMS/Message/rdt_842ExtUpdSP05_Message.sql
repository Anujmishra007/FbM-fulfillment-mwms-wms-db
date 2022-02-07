--rdt_842ExtUpdSP05
exec rdt.rdtDropMsg 132351 , 132400

execute rdt.rdtAddMsg 132351 ,10, '32351^InvDropID',        'us_english',842
execute rdt.rdtAddMsg 132352 ,10, '32352^UpdEcommFail',     'us_english',842
execute rdt.rdtAddMsg 132353 ,10, '32353^PickNotComplete',  'us_english',842
execute rdt.rdtAddMsg 132354 ,10, '32354^NoRecToProcess',   'us_english',842
execute rdt.rdtAddMsg 132355 ,10, '32355^SKuNotIntote',     'us_english',842
execute rdt.rdtAddMsg 132356 ,10, '32356^QtyExceeded',      'us_english',842
execute rdt.rdtAddMsg 132357 ,10, '32357^InsPickHdrFail',   'us_english',842
execute rdt.rdtAddMsg 132358 ,10, '32358^UpdPickDetFail',   'us_english',842
execute rdt.rdtAddMsg 132359 ,10, '32359^InsPickInfoFail',  'us_english',842
execute rdt.rdtAddMsg 132360 ,10, '32360^CreatePHdrFail',   'us_english',842
execute rdt.rdtAddMsg 132361 ,10, '32361^NoLabelNoGen',     'us_english',842
execute rdt.rdtAddMsg 132362 ,10, '32362^NoLabelNoGen',     'us_english',842
execute rdt.rdtAddMsg 132363 ,10, '32363^UpdEcommFail',     'us_english',842
execute rdt.rdtAddMsg 132364 ,10, '32364^InsPackDetFail',   'us_english',842
execute rdt.rdtAddMsg 132365 ,10, '32365^UpdPackDetFail',   'us_english',842
execute rdt.rdtAddMsg 132366 ,10, '32366^UpdPickDetFull',   'us_english',842
execute rdt.rdtAddMsg 132367 ,10, '32367^UpdOrderFail',     'us_english',842
execute rdt.rdtAddMsg 132368 ,10, '32368^UpdOrderFail',     'us_english',842
execute rdt.rdtAddMsg 132369 ,10, '32369^UpdOrdFail',       'us_english',842
execute rdt.rdtAddMsg 132370 ,10, '32370^UpdPackDetFail',   'us_english',842
execute rdt.rdtAddMsg 132371 ,10, '32371^UpdEcommFail',     'us_english',842
execute rdt.rdtAddMsg 132372 ,10, '32372^UpdDroIDFail',     'us_english',842
execute rdt.rdtAddMsg 132373 ,10, '32373^UpdEcommFail',     'us_english',842
execute rdt.rdtAddMsg 132374 ,10, '32374^InvalidOption',    'us_english',842
execute rdt.rdtAddMsg 132375 ,10, '32375^PickNotDone',      'us_english',842
execute rdt.rdtAddMsg 132376 ,10, '32376^PickNotComplete',  'us_english',842
execute rdt.rdtAddMsg 132377 ,10, '32377^NoRecToProcess',   'us_english',842
execute rdt.rdtAddMsg 132378 ,10, '32378^UpdCtnTrackErr',   'us_english',842

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 132351 AND 132400
