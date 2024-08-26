IF NOT EXISTS (SELECT 1 FROM Codelkup c (NOLOCK) WHERE ListName = 'STORERCFG' AND
               Code = 'AutoASNToTransportOrder')
BEGIN
   INSERT INTO CODELKUP (ListName, Code, DESCRIPTION)
   VALUES ('STORERCFG', 'AutoASNToTransportOrder', 'Auto Create TMS_Shipment for booking when create ASN')
END

IF NOT EXISTS (SELECT 1 FROM Codelkup  (NOLOCK) WHERE ListName = 'StorerCfg'       --LFWM-4437 
               AND Code ='ASNPopulateOpenOrdPO')
BEGIN 
   INSERT INTO CODELKUP (LISTNAME, Code, Description)
   VALUES ( 'STORERCFG', 'ASNPopulateOpenOrdPO', 'Populate PODetail with open QtyOrdered at Populate PO Header Menu')
END

