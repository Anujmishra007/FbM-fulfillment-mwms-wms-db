-- rdt_1813AutoGenID01_Message


exec rdt.rdtDropMsg 225001, 225050

execute rdt.rdtAddMsg 225001 ,10, '225001^INVALID LENGTH'    , 'us_english',1813
execute rdt.rdtAddMsg 225002 ,10, '225002^INVALID FMT'                  , 'us_english',1813
execute rdt.rdtAddMsg 225003 ,10, '225003^MINSEQ WRONG'            , 'us_english',1813
execute rdt.rdtAddMsg 225004 ,10, '225004^REACH LIMIT'          , 'us_english',1813
execute rdt.rdtAddMsg 225005 ,10, '225005^NO CODELKUP'          , 'us_english',1813


