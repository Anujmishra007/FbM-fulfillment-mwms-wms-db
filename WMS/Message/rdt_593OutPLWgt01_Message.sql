exec rdt.rdtDropMsg 218751,218800 

exec rdt.rdtAddMsg 218751,10,'218751^Need Weight','us_english',593
exec rdt.rdtAddMsg 218752,10,'218752^Need PalletQty','us_english',593
exec rdt.rdtAddMsg 218753,10,'218753^No MBOL','us_english',593
exec rdt.rdtAddMsg 218754,10,'218754^Mbol Not Exists','us_english',593
exec rdt.rdtAddMsg 218755,10,'218755^Mbol Shipped','us_english',593
exec rdt.rdtAddMsg 218756,10,'218756^Bad Pallet Qty','us_english',593

SELECT * FROM rdt.rdtmsg WHERE Message_ID BETWEEN 218751 AND 218800