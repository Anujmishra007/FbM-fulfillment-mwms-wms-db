IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Packing_List_97_rdt]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_Packing_List_97_rdt]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO      
/************************************************************************/        
/* Stored Proc: isp_Packing_List_97_rdt                                 */        
/* Creation Date: 08-Mar-2021                                           */        
/* Copyright: LF Logistics                                              */        
/* Written by: mingle                                                   */        
/*                                                                      */        
/* Purpose: WMS-16433 [CN] GBMAX_ECOM_PackingList                       */        
/*                                                                      */        
/* Called By: r_dw_packing_list_97_rdt                                  */        
/*                                                                      */        
/* GitLab Version: 1.1                                                  */        
/*                                                                      */        
/* Version: 7.0                                                         */        
/*                                                                      */        
/* Data Modifications:                                                  */        
/*                                                                      */        
/* Updates:                                                             */        
/* Date         Author    Ver Purposes                                  */ 
/* 18-Jun-2021  Mingle    1.1 WMS-17272 modify logic(ML01)              */      
/************************************************************************/        
--EXEC isp_Packing_List_97_rdt 'P000136620'
CREATE PROC [dbo].[isp_Packing_List_97_rdt]     
            @c_Pickslipno    NVARCHAR(15)           
                 
AS        
BEGIN        
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF        
            
   SELECT Orders.Externorderkey,    
         Orders.Adddate,    
         Orders.C_contact1,    
         SKU.Descr,    
         SKU.BUSR6,    
         SKU.Size,    
         packdetail.SKU,     
         CAST(Orderdetail.Unitprice AS INT) AS Unitprice,    
         Packdetail.QTY AS qty,     --ML01   
         (SELECT CAST(CAST(sum(od.Unitprice*od.OriginalQty)AS INT)AS NVARCHAR(10))    FROM dbo.ORDERDETAIL (NOLOCK) od  WHERE od.OrderKey=orderdetail.OrderKey AND od.StorerKey=orderdetail.StorerKey ) as totalmara
         --(SELECT CASE WHEN oh.UserDefine03 LIKE '%co%' then CAST(CAST(sum(od.Unitprice)AS INT)AS NVARCHAR(10))  ELSE ' ' END  FROM dbo.ORDERDETAIL (NOLOCK) od JOIN dbo.ORDERS (NOLOCK) oh ON oh.OrderKey = od.OrderKey AND oh.StorerKey = od.StorerKey WHERE od.OrderKey=orderdetail.OrderKey AND od.StorerKey=orderdetail.StorerKey GROUP BY oh.UserDefine03) as totalco,
		   --(SELECT CASE WHEN oh.UserDefine03 LIKE '%mara%' then CAST(CAST(sum(od.Unitprice)AS INT)AS NVARCHAR(10))  ELSE ' ' END  FROM dbo.ORDERDETAIL (NOLOCK) od JOIN dbo.ORDERS (NOLOCK) oh ON oh.OrderKey = od.OrderKey AND oh.StorerKey = od.StorerKey WHERE od.OrderKey=orderdetail.OrderKey AND od.StorerKey=orderdetail.StorerKey GROUP BY oh.UserDefine03) as totalmara   
             
    FROM Packdetail (NOLOCK)    
         JOIN SKU (NOLOCK) ON packdetail.SKU = SKU.SKU    
         JOIN Packheader (NOLOCK) ON Packdetail.Pickslipno = Packheader.Pickslipno     
         JOIN Orders (NOLOCK) ON Packheader.orderkey = Orders.Orderkey     
         JOIN Orderdetail (NOLOCK) ON Orders.orderkey = Orderdetail.orderkey   
         JOIN Pickdetail (NOLOCK) ON Pickdetail.Orderkey = Orderdetail.Orderkey   
                                 and Pickdetail.OrderlineNumber = Orderdetail.OrderlineNumber   
                                 and Pickdetail.SKu = Orderdetail.SKU  
                                 and Pickdetail.CaseID = Packdetail.Labelno  
                                 and Pickdetail.Sku = PackDetail.SKU
                        
   WHERE Packdetail.Pickslipno = @c_Pickslipno    
    
  GROUP BY  CAST(Orderdetail.Unitprice AS INT),
            ORDERS.ExternOrderKey,
            ORDERS.AddDate,
            C_contact1,
            DESCR,
            BUSR6,
            Size,
            PackDetail.SKU,
            PackDetail.Qty,orderdetail.OrderKey,orderdetail.StorerKey
            --,orders.UserDefine03  
    
END 

GO
GRANT EXECUTE ON [dbo].[isp_Packing_List_97_rdt] TO nsql 
GO