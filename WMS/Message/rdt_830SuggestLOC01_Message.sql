--rdt_830SuggestLOC01
exec rdt.rdtDropMsg 124201 , 124250

execute rdt.rdtAddMsg 124201, 10, '24201^No Suggest Loc',   'us_english', 830

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 124201 AND 124250



