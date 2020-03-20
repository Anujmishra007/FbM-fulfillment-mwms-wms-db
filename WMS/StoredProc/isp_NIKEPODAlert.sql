IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_NIKEPODAlert]')
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 )
DROP PROCEDURE [dbo].[isp_NIKEPODAlert]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
SET ANSI_WARNINGS ON
GO

/****************************************************************************/        
/* Stored Procedure: isp_NIKEPODAlert                                       */        
/* Creation Date: 10-Jan-2013                                               */        
/* Copyright: LF LOGISTICS                                                  */        
/* Written by: Kunakorn                                                     */        
/*                                                                          */                           
/*                                                                          */        
/* Called By: SQL Scheduler                                                 */         
/*                                                                          */        
/* Parameters:                                                              */        
/*                                                                          */        
/* PVCS Version: 1.0                                                        */        
/*                                                                          */        
/* Version: 1.0                                                             */        
/*                                                                          */        
/* Data Modifications:                                                      */        
/* Date         Author   Ver  Purposes                                      */
/* 21May2013    TLTING01 1.1  GET TH Alert script for NIKE Regoinal         */        
/* 10Jun2013    KHLim    1.2  Rename POD Report to Picking Report (KH01)    */        
/*  4Sep2013    KHLim    1.3  SOS288870 DeliveryDate > UserDefine06 KH02    */
/* 30Dec2014    KHLim    1.4  SOS329719 UserDefine06 > DeliveryDate KH03    */
/* 09-Sep-2015  NJOW01   1.5  352330-add next two weeks                     */
/* 12-Nov-2019  kocy     1.6  move Total Line from the end of table         */
/*                            to be the first line under Header.            */  
/*                                                                          */
/*06-Dec-2019  kocy      1.7 Modifies data master based on script provided  */
/****************************************************************************/        
CREATE PROC [UTL].[isp_NIKEPODAlert]        
(  @cprofile_name Nvarchar(200) = NULL,
   @cTo     nvarchar(max),
   @cCc     nvarchar(max) = '',
   @cSubject  nvarchar(255) = 'Auto Report POD for Nike', 
   @cStorerkey nvarchar(15) = ''
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS ON
   SET ANSI_WARNINGS ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF        
            
   DECLARE @cBody       nvarchar(MAX),          
           @cEmail1     nvarchar(MAX),      
           @cEmail2     nvarchar(MAX),      
           @cRecip      nvarchar(MAX),      
           @cRecipCc    nvarchar(MAX),      
           @cOrderkey   nvarchar(30),      
           @cConsignee  nvarchar(50),
		     @ShowColoumn nvarchar(255),      
           @cCompany    nvarchar(Max),      
           @cBranch     nvarchar(MAX),    
           @dDelivery   datetime,
		     @ImgName		nvarchar(Max),
		     @ColorDate   nvarchar(150)


  SET @cBody = '';  

   --=================================================Open function Running Date=====================================     
  WITH nums (i)
  AS
  (
     SELECT i = 0
     UNION ALL
     SELECT i + 1 
     FROM nums 
     WHERE i < 100
  )
  SELECT * INTO #tempdatelist 
  FROM (SELECT  CONVERT(VARCHAR, dte, 103) AS Datelink, DATENAME(weekday, dte) AS DateText,CONVERT(VARCHAR, dte, 106) AS Dateshow
  FROM (SELECT dte = DATEADD(dd,nums.i,(DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0))))
  FROM nums) a
  WHERE dte < (DATEADD(WK,2,DATEADD(mm,1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0)))) ) gg;  --NJOW01
  --================================================close function Date==============================================
  
  --set @cSubject ='Auto Report POD for Nike Thailand'
  --set @cSubject ='Auto Report POD for Nike Malaysia'
  
  --================================================select DataMaster===============================================

   SELECT
   CONVERT (VARCHAR, o.Deliverydate,103) AS 'Deliverydate',  --KH02 KH03
   COUNT(DISTINCT o.Orderkey) AS 'ImportedOrder',
   SUM(od.Originalqty)  AS 'ImportedUnit',
   COUNT(DISTINCT CASE WHEN ( o.Status ='canc') THEN  CASE WHEN o.Status = 'canc' THEN o.Orderkey ELSE NULL END ELSE NULL END) AS 'CancelledOrder',
   SUM(CASE WHEN (o.Status ='canc')  THEN CASE WHEN o.status = 'canc' THEN od.Originalqty ELSE 0 END ELSE 0 END) AS 'CancelledUnit',
   COUNT( DISTINCT o.Orderkey) - COUNT(DISTINCT CASE WHEN (o.Sostatus ='canc')  THEN  CASE WHEN o.Sostatus = 'canc' THEN o.Orderkey ELSE NULL END ELSE NULL END) AS 'TotalOrder',
   SUM(od.Originalqty) - SUM(CASE WHEN ( o.status ='canc')  THEN CASE WHEN o.status = 'canc' THEN od.Originalqty ELSE 0 END ELSE 0 END) AS 'TotalOrderUint',
   COUNT(DISTINCT CASE WHEN (o.status < '5' )  THEN  CASE WHEN o.status <> 'canc' THEN o.Orderkey ELSE NULL END ELSE NULL END) AS 'PickingOrder',
   SUM(CASE WHEN (o.status < '5' )  THEN CASE WHEN o.Sostatus <>'canc' THEN od.Originalqty ELSE 0 END ELSE 0 END) AS 'PickingUnit',
   COUNT(DISTINCT CASE WHEN (o.status = '5' )  THEN o.Orderkey ELSE NULL END) AS 'PackOrder',
   SUM(CASE WHEN (o.status = '5' )  THEN  od.Qtypicked ELSE 0 END) AS 'PackUnit',
   COUNT( DISTINCT CASE WHEN (o.status = '9'  and o.Sostatus <> 'canc')  THEN o.Orderkey ELSE NULL END) AS 'GoodsIssueOrder',
   SUM(CASE WHEN (o.status = '9'  and o.Sostatus <> 'canc')  THEN  od.Shippedqty ELSE 0 END) AS 'GoodIssuedUnit',
   COUNT(DISTINCT CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.Sostatus >='5' and o.Sostatus <> 'canc'  THEN o.Orderkey ELSE NULL END) AS 'OrderShotPicked',
   SUM(CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.Sostatus >='5' and o.Sostatus <> 'canc' THEN od.openQTY ELSE 0 END) AS 'UnitShotPicked',
   COUNT(DISTINCT CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.Sostatus >='5' and o.Sostatus <> 'canc'  THEN od.sku ELSE NULL END) AS 'TotalShotSKU',
   CONVERT(DECIMAL(10,2),ROUND(CASE WHEN (SUM(CASE WHEN o.status >='5' THEN od.shippedqty + od.qtypicked ELSE 0 END)+SUM(CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.status >='5' THEN od.shippedqty + od.qtypicked ELSE 0 END))=0 THEN 0 ELSE 
   CAST((SUM(CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.Sostatus >='5' and o.Sostatus <> 'canc' THEN od.openQTY ELSE 0 END))as decimal)/(SUM(CASE WHEN o.status >='5' THEN od.shippedqty + od.qtypicked ELSE 0 END)+SUM(CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.status >='5' THEN od.shippedqty + od.qtypicked ELSE 0 END)) END * 100,2)) 'PersENDShortPick',
   CAST(100 as decimal) - CONVERT(DECIMAL(10,2),round(CASE WHEN (SUM(CASE WHEN o.status >='5' THEN od.shippedqty + od.qtypicked ELSE 0 END)+SUM(CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.status >='5' THEN od.shippedqty + od.qtypicked ELSE 0 END))=0 THEN 0 ELSE 
   CAST((SUM(CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked))  and o.Sostatus >='5' and o.Sostatus <> 'canc' THEN od.openQTY ELSE 0 END))as decimal)/(SUM(CASE WHEN o.status >='5' THEN od.shippedqty + od.qtypicked ELSE 0 END)+SUM(CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.status >='5' THEN od.shippedqty + od.qtypicked ELSE 0 END)) END * 100,2)) AS 'Picksuccess',
   (COUNT(DISTINCT CASE WHEN (o.Sostatus = '5'  and o.Sostatus ='canc')  THEN o.Orderkey ELSE NULL END) + (COUNT( DISTINCT CASE WHEN (o.Sostatus = '9'  and o.Sostatus <> 'canc')  THEN o.Orderkey ELSE NULL END))) -
   COUNT(DISTINCT CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.Sostatus >='5' and o.Sostatus <> 'canc' THEN o.Orderkey ELSE NULL END) AS 'Order100Persend',
   CASE WHEN (COUNT(DISTINCT CASE WHEN (o.Sostatus = '5'  and o.Sostatus ='canc')  THEN o.Orderkey ELSE NULL END) + (COUNT( DISTINCT CASE WHEN (o.Sostatus = '9'  and o.Sostatus <> 'canc')  THEN o.Orderkey ELSE NULL END)))=0 THEN 0 ELSE
   CONVERT(DECIMAL(10,2),round((CAST(((COUNT(DISTINCT CASE WHEN (o.Sostatus = '5'  and o.Sostatus ='canc')  THEN o.Orderkey ELSE NULL END) + (COUNT( DISTINCT CASE WHEN (o.Sostatus = '9'  and o.Sostatus <> 'canc')  THEN o.Orderkey ELSE NULL END))) -
   COUNT(DISTINCT CASE WHEN (od.Originalqty <> (od.shippedqty + od.qtypicked)) and o.Sostatus >='5' and o.Sostatus <> 'canc'  THEN o.Orderkey ELSE NULL END)) as decimal(10,2))/
   (COUNT(DISTINCT CASE WHEN (o.Sostatus = '5'  and o.Sostatus ='canc')  THEN o.Orderkey ELSE NULL END) + (COUNT( DISTINCT CASE WHEN (o.Sostatus = '9'  and o.Sostatus <> 'canc')  THEN o.Orderkey ELSE NULL END))))*100,2)) END  AS 'FillPersEND',
   COUNT(DISTINCT CASE WHEN p.Status <>'1' THEN p.orderkey ELSE NULL END) AS 'TotalDelivered',
   COUNT(DISTINCT CASE WHEN o.Status <> 'CANC' THEN CASE WHEN o.Status=9  and ((o.Deliverydate+ CASE WHEN R.Zipcodefrom ='BKK' THEN 1 ELSE 3 END) - (DATEDIFF(d,o.Deliverydate,o.Editdate+3)+1 -      --KH02 KH03
   (DATEDIFF(wk,o.Deliverydate,o.Editdate+3) + CASE WHEN DATEPART(dw,o.Deliverydate)=1 THEN 1 ELSE 0 END )-
   (DATEDIFF(wk,o.Deliverydate,o.Editdate+3) + CASE WHEN DATEPART(dw,o.Editdate+3)=7 THEN 1 ELSE 0 END ))) >=0 THEN o.orderkey ELSE NULL END ELSE NULL END) AS 'OntimeDelivered',                          --KH02 KH03
   CASE WHEN COUNT(DISTINCT CASE WHEN p.Status <>'1' THEN p.orderkey ELSE NULL END) = 0 THEN 0 ELSE ((COUNT(DISTINCT CASE WHEN o.Status <> 'CANC' THEN CASE WHEN o.Status=9  and ((o.Deliverydate+ CASE WHEN R.Zipcodefrom ='BKK' THEN 1 ELSE 3 END) - (DATEDIFF(d,o.Deliverydate,o.Editdate+3)+1     --KH02 KH03
   - (DATEDIFF(wk,o.Deliverydate,o.Editdate+3) + CASE WHEN DATEPART(dw,o.Deliverydate)=1 THEN 1 ELSE 0 END )
   - (DATEDIFF(wk,o.Deliverydate,o.Editdate+3) + CASE WHEN DATEPART(dw,o.Editdate+3)=7 THEN 1 ELSE 0 END ))) >=0 THEN o.orderkey ELSE NULL END ELSE NULL END))/(COUNT(DISTINCT CASE WHEN p.Status <>'1' THEN p.orderkey ELSE NULL END)))*100 END  AS 'PersENDOn_Time',
   COUNT(DISTINCT CASE WHEN P.Status <>'1' and P.Podreceiveddate is not null THEN p.orderkey ELSE NULL END) AS 'POD_Returned',
   COUNT(DISTINCT CASE WHEN P.Status <>'1' and (DATEDIFF(dd, P.Actualdeliverydate,P.Podreceiveddate))-(DATEDIFF(wk,P.Actualdeliverydate,P.Podreceiveddate)* 2)
   -(CASE WHEN DATENAME(dw,P.Actualdeliverydate) = 'Sunday' THEN 1 ELSE 0 END)-(CASE WHEN DATENAME(dw,P.Podreceiveddate)='Saturday' THEN 1 ELSE 0 END)
   <=(CASE WHEN R.Zipcodefrom ='BKK' THEN 3 ELSE 6 END)  THEN p.orderkey ELSE NULL END) AS 'POD_Hit',
   CASE WHEN COUNT(DISTINCT CASE WHEN p.Status <>'1' THEN p.orderkey ELSE NULL END)  = 0 THEN 0 ELSE CONVERT(DECIMAL(8,2),(CAST(COUNT(DISTINCT CASE WHEN P.Status <>'1' and (DATEDIFF(dd, P.Actualdeliverydate,P.Podreceiveddate))-(DATEDIFF(wk,P.Actualdeliverydate,P.Podreceiveddate)* 2)
   -(CASE WHEN DATENAME(dw,P.Actualdeliverydate) = 'Sunday' THEN 1 ELSE 0 END)-(CASE WHEN DATENAME(dw,P.Podreceiveddate)='Saturday' THEN 1 ELSE 0 END)
   <=(CASE WHEN R.Zipcodefrom ='BKK' THEN 3 ELSE 6 END)  THEN p.orderkey ELSE NULL END) as decimal(8,2))/COUNT(DISTINCT CASE WHEN p.Status <>'1' THEN p.orderkey ELSE NULL END) )*100) END AS 'HitPersend',
   COUNT(DISTINCT CASE WHEN p.Status <>'1' THEN p.orderkey ELSE NULL END)- COUNT(DISTINCT CASE WHEN P.Status <>'1' and P.Podreceiveddate is not null THEN p.orderkey ELSE NULL END) AS 'PODNotReturn'
   
   INTO #tempMaser
   FROM ODS.ORDERS o WITH (NOLOCK)  
   JOIN ODS.ORDERDETAIL od WITH (NOLOCK) ON o.storerkey =od.storerkey and o.orderkey = od.orderkey
   LEFT OUTER JOIN ODS.POD P  WITH (NOLOCK) ON o.orderkey = p.orderkey and o.mbolkey = p.mbolkey
   LEFT OUTER JOIN ODS.RouteMaster R WITH (NOLOCK) ON o.[Route] = r.[Route]
   where o.StorerKey=@cStorerkey
   and o.Deliverydate BETWEEN    --KH02 KH03

   --from VMHKGRPTDBPD1.TH_DATAMART.ODS.orders o (nolock)  join VMHKGRPTDBPD1.TH_DATAMART.ODS.orderdetail od (nolock) on o.storerkey =od.storerkey and o.orderkey = od.orderkey
   --left outer join VMHKGRPTDBPD1.TH_DATAMART.ODS.POD P (nolock) on o.orderkey = p.orderkey and o.mbolkey = p.mbolkey
   --left outer join VMHKGRPTDBPD1.TH_DATAMART.ODS.RouteMaster R (nolock) on o.route = r.route
   --where o.storerkey='NIKETH' and o.Deliverydate between 
   --DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0)) and DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP)+1,0))
   DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0)) and DATEADD(WK,2,DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP)+1,0))) --NJOW01  
   GROUP BY CONVERT(VARCHAR,o.Deliverydate,103)
   
   --===============================================close data master===================================================================================

   BEGIN
        
      SET @cBody = @cBody + '<style type="text/css">         
         ul    {  font-family: Arial; font-size: 11px; color: #686868;  }        
         p.a1  {  font-family: Arial; font-size: 11px; color: #686868;  }        
         p.a2  {  font-family: Arial; font-size: 11px; color: #686868; font-style:italic  }    
		 p.a3  {  font-family: Arial; font-size: 16px; color: black;  }        
         table {  font-family: Arial;  }        
         th    {  font-size: 11px;font-family: Tahoma }        
         td    {  font-size: 10px;  }        
         </style>'

      SET @cBody = @cBody + '<p class=a1>Dear All,</p>'        
      SET @cBody = @cBody + '<p class=a2>We would like to inform you on the Nike Picking Report,</p>'       --KH01
      SET @cBody = @cBody + '<p class=a2>kindly see detail below.</p>'        
        
        
      SET @cBody = @cBody +         
          N'<p class=a3><b>Nike Picking Report :'+ DATENAME(month,getdate()) +'  '+ DATENAME(YEAR,getdate()) + ' (+ Next 2 Week)' + ' &nbsp </b>' + --KH01 --NJOW01
--		  N'<img src="http://www.sqlteam.com/images2/SqlTeamHDR2.jpg" border="0" width="270" height="146" />' +
         N'</p><table border="1" cellspacing="0" cellpadding="1">' +        
         N'<tr><th bgcolor=#00BFFF align=center rowspan="2" colspan="2">Day</th><th bgcolor=#00BFFF align=center colspan="2">Imported</th><th bgcolor=#00BFFF align=center colspan="2">Cancelled</th><th bgcolor=#00BFFF align=center colspan="2">Total Orders</th><th bgcolor=#00BFFF align=center colspan="2">Picking</th><th bgcolor=#00BFFF align=center colspan="2">Packed</th><th bgcolor=#FAAC58 align=center colspan="2">Goods Issued</th><th bgcolor=#00BFFF align=center rowspan="2">Order Short Picked</th><th bgcolor=#00BFFF align=center rowspan="2">Units Short Picked</th><th bgcolor=#00BFFF align=center rowspan="2">Total SKU Short</th><th bgcolor=#00BFFF align=center rowspan="2">% Short Picked</th><th bgcolor=#00BFFF align=center rowspan="2">Pick Success %</th><th bgcolor=#00BFFF align=center colspan="2">Order</th><th bgcolor=#FE642E align=center colspan="3">Delivery</th><th bgcolor=#FE642E align=center colspan="3">POD</th><th bgcolor=#FE642E align=center rowspan="2">PODNotReturn</th></tr>'+
         N'<tr><th bgcolor=#00BFFF>Orders</th><th bgcolor=#00BFFF>Units</th><th bgcolor=#00BFFF>Orders</th><th bgcolor=#00BFFF>Units</th><th bgcolor=#00BFFF>Orders</th><th bgcolor=#00BFFF>Units</th><th bgcolor=#00BFFF>Orders</th><th bgcolor=#00BFFF>Units</th><th bgcolor=#00BFFF>Orders</th><th bgcolor=#00BFFF>Units</th><th bgcolor=#FAAC58>Orders</th><th bgcolor=#FAAC58>Units</th><th bgcolor=#00BFFF>100%</th><th bgcolor=#00BFFF>Fill %</th><th bgcolor=#FE642E>Total</th><th bgcolor=#FE642E>OnTime</th><th bgcolor=#FE642E>%OnTime</th><th bgcolor=#FE642E>TotalReturn</th><th bgcolor=#FE642E>Hit</th><th bgcolor=#FE642E>Hit%</th>'    
        
	   BEGIN --kocy (s)
         SET @cBody = @cBody + CAST ( ( 
       
	     SELECT
            td =  ISNULL(CAST('Total' AS nvarchar(99)),''), '',        
            'td/@align' = 'Left',        
            td = ISNULL(CAST('' AS nvarchar(99)),''), '',       
            'td/@align' = 'Left',           
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.ImportedOrder) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.ImportedUnit) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.CancelledOrder) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.CancelledUnit) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.TotalOrder) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.TotalOrderUint) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.PickingOrder) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.PickingUnit) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.PackOrder) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'center',
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.PackUnit) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.GoodsIssueOrder) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.GoodIssuedunit) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.OrderShotPicked) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.UnitShotPicked) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.TotalshotSKU) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(AVG(sm.PersENDShortPick) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
			   td = replace(convert(varchar,CAST(ISNULL(CAST(AVG(sm.Picksuccess) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(AVG(sm.Order100PersEND) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(AVG(sm.FillPersEND) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.TotalDelivered) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.OntimeDelivered) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(AVG(sm.PersENDOn_Time) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.POD_Returned) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.POD_Hit) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(AVG(sm.HitPersEND) AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'right', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(SUM(sm.PODNotReturn) AS nvarchar(99)),'')as money),1), '.00',''), ''       
        
			from #tempMaser sm 
                  FOR XML PATH('tr'), TYPE           
          ) AS NVARCHAR(MAX) )
	 END  --kocy (e)
    BEGIN
         SET @cBody = @cBody + CAST ( ( 
	       SELECT
			  'td/@align' = 'Left','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99'  ELSE '' END, 
            td =  ISNULL(CAST(d.Dateshow AS nvarchar(99)),''), '',        
            'td/@align' = 'Left','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END,        
            td = ISNULL(CAST(d.DateText AS nvarchar(99)),''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END,           
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.ImportedOrder AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.ImportedUnit AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.CancelledOrder AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.CancelledUnit AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.TotalOrder AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.TotalOrderUint AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.PickingOrder AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.PickingUnit AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.PackOrder AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.PackUnit AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'='#FFDEAD', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.GoodsIssueOrder AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'='#FFDEAD', 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.GoodIssuedunit AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.OrderShotPicked AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.UnitShotPicked AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.TotalshotSKU AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.PersENDShortPick AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
			   td = replace(convert(varchar,CAST(ISNULL(CAST(m.Picksuccess AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.Order100PersEND AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.FillPersEND AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.TotalDelivered AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.OntimeDelivered AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.PersENDOn_Time AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.POD_Returned AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.POD_Hit AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.HitPersEND AS nvarchar(99)),'')as money),1), '.00',''), '',       
            'td/@align' = 'Right','td/@bgcolor'=case d.DateText  when 'Sunday' THEN '#FFFF99' when 'Saturday'  THEN '#FFFF99' ELSE '' END, 
            td = replace(convert(varchar,CAST(ISNULL(CAST(m.PODNotReturn AS nvarchar(99)),'')as money),1), '.00',''), ''       
        
			  FROM #tempdatelist d left outer join #tempMaser m on d.Datelink = m.Deliverydate

            FOR XML PATH('tr'), TYPE           
          ) AS NVARCHAR(MAX) ) + N'</table>' ;

     END
               
     SET @cBody = @cBody + '<p class=a1><b>Best Regards,</b><br><b>Delivery Team<b/>'        


      IF @cEmail2 <> ''
      BEGIN
         SET @cRecip = @cEmail2 + ';' + @cTo
      END
      ELSE
      BEGIN
         SET @cRecip = @cTo
      END
      IF @cEmail1 <> ''
      BEGIN
         SET @cRecipCc = @cEmail1 + ';' + @cCc
      END
      ELSE
      BEGIN
         SET @cRecipCc = @cCc
      END

      EXEC msdb.dbo.sp_sEND_dbmail 
         @profile_name    = @cprofile_name,
         @recipients      = @cRecip,
         @copy_recipients = @cRecipCc,
         @subject         = @cSubject,
         @body            = @cBody,
         @body_format     = 'HTML' ;

  END

--   CLOSE GEN_Email
--   DEALLOCATE GEN_Email

 
END /* main procedure */
