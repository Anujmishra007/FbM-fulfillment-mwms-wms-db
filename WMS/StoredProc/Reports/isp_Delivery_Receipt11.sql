IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Delivery_Receipt11]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_Delivery_Receipt11]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO   

/*************************************************************************/    
/* Stored Procedure: isp_Delivery_Receipt11                              */    
/* Creation Date: 07-JAN-2022                                            */    
/* Copyright: LFL                                                        */    
/* Written by: CHONGCS                                                   */    
/*                                                                       */    
/* Purpose: WMS-18684 - PH_Young Living - CAS Delivery Receipt Report    */    
/*                                                                       */    
/* Called By: report dw = r_dw_Delivery_Receipt11                        */    
/*                                                                       */    
/* GitLab Version: 1.0                                                   */    
/*                                                                       */    
/* Version: 5.4                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date         Author     Ver. Purposes                                 */  
/* 06-JAN-2022  CSCHONG    1.0  Devops Scripts Combine                   */  
/* 04-FEB-2022  CSCHONG    1.1  WMS-18684 revised field logic (CS01)     */
/*************************************************************************/    
CREATE PROC [dbo].[isp_Delivery_Receipt11] (    
             @c_Orderkey      NVARCHAR(10)  
)    
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF   
   
   DECLARE @c_CODSKU           NVARCHAR(20) = 'COD'
         , @c_ExternOrderkey   NVARCHAR(50) = ''
         , @n_OrderInfo03      DECIMAL(30,2) = 0.00


   DECLARE   @c_moneysymbol      NVARCHAR(20) = N'₱'
           , @n_balance          DECIMAL(10,2) = 0.00
           , @n_TTLUnitPrice     DECIMAL(10,2)
           , @n_OIF03            DECIMAL(10,2) = 0.00
           , @c_OIF03            NVARCHAR(30) = ''
           , @c_Clkudf01         NVARCHAR(150) = ''
           , @c_Clkudf02         NVARCHAR(150) = ''
           , @c_Clkudf03         NVARCHAR(150) = ''
           , @c_Clkudf04         NVARCHAR(150) = ''
           , @c_Clkudf05         NVARCHAR(150) = ''
           , @c_Clknotes2        NVARCHAR(150) = ''
           , @c_storerkey        NVARCHAR(20) = ''   
           , @c_Reprint          NVARCHAR(1) = 'N'   
           , @c_xdockFlag        NVARCHAR(5) = ''  


DECLARE @c_OHUDF06      NVARCHAR(30)
       ,@c_PrevOHUDF06  NVARCHAR(30)
       ,@c_OHUDF02      NVARCHAR(30)
       ,@c_ODUDF02      NVARCHAR(30)
       ,@c_getclkudf01  NVARCHAR(20) 
       ,@c_sbusr5       NVARCHAR(30)
       ,@c_lott01       NVARCHAR(20)
       ,@c_Prvlott01    NVARCHAR(20)
       ,@c_sku          NVARCHAR(20)
       ,@c_getsku       NVARCHAR(150)  
       ,@n_odqty        INT
       ,@c_sdescr       NVARCHAR(250)
       ,@c_getorderkey  NVARCHAR(20)
       ,@c_getodqty     NVARCHAR(20)
       ,@c_getsdescr    NVARCHAR(250)
       ,@c_GetOHUDF06   NVARCHAR(30)
       ,@c_prefix       NVARCHAR(20)
       ,@c_CompSKU      NVARCHAR(200)
       ,@c_Combinesku   NVARCHAR(20) = ''
       ,@c_skipinsert   NVARCHAR(1) = 'N'
       ,@n_lineno       INT
   
   DECLARE @b_COD INT = 0
   
   --IF EXISTS (SELECT TOP 1 1 FROM ORDERDETAIL (NOLOCK)
   --           WHERE OrderKey = @c_Orderkey AND SKU = @c_CODSKU
   --           AND UserDefine02 = 'PN')
   --BEGIN
   --   SET @b_COD = 1 
   --END

    SET @c_prefix = '(OOS-To Follow)'

    SELECT @c_storerkey = OH.storerkey,@c_xdockFlag = oh.xdockFlag
    FROM ORDERS OH WITH (NOLOCK)
    WHERE OH.orderkey = @c_orderkey 


   IF @c_xdockFlag = 'Y'
   BEGIN
         SET @c_Reprint = 'Y'
   END
   
   CREATE TABLE #TMPBOMSKU
(    RowID              INT   IDENTITY(1,1)  PRIMARY KEY
  ,  StorerKey          NVARCHAR(20)   NOT NULL DEFAULT('')
  ,  Orderkey           NVARCHAR(20)   NOT NULL DEFAULT('')
  ,  SKU                NVARCHAR(20)  NOT NULL DEFAULT('')
  ,  CompSKU            NVARCHAR(200)  NOT NULL DEFAULT('')
  ,  Qty                NVARCHAR(20)   NULL
  ,  Sdescr             NVARCHAR(200) NULL
)

     SELECT @c_Clkudf01 = ISNULL(clk.UDF01,'')
           ,@c_Clkudf02 = ISNULL(clk.UDF02,'')
           ,@c_Clkudf03 = ISNULL(clk.UDF03,'')
           ,@c_Clkudf04 = ISNULL(clk.UDF04,'')
           ,@c_Clkudf05 = ISNULL(clk.UDF05,'')
           ,@c_Clknotes2 = ISNULL(clk.Notes2,'')
     FROM dbo.CODELKUP clk WITH (NOLOCK)
     WHERE clk.LISTNAME='YLDefVal' AND clk.Short = 'CR'
     AND Clk.Storerkey = @c_storerkey
   

    DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   
SELECT od.StorerKey AS storerkey,od.orderkey AS orderkey,od.UserDefine06 AS ODUDF06,od.sku AS sku,
       (Od.QtyAllocated + od.QtyPicked+od.ShippedQty) AS qty,s.DESCR AS sdescr,clk.udf01,s.busr5,od.Lottable01
      ,CAST(od.externlineno AS INT),od.UserDefine02
from orderdetail od (nolock) 
JOIN SKU S WITH (NOLOCK) ON S.StorerKey = od.StorerKey AND S.sku = od.sku
LEFT JOIN CODELKUP CLK WITH (NOLOCK) ON CLK.listname = 'YLLineType' AND CLK.code = od.UserDefine02
WHERE od.storerkey='yleo' and od.orderkey=@c_orderkey
AND (ISNULL(clk.udf01,'') = 'Y' OR ISNULL(s.busr5,'') = 'Y')
--AND od.Lottable01 = (SELECT TOP 1 odet.sku FROM orderdetail odet (nolock) WHERE odet.UserDefine06 = 'KIT' AND odet.storerkey='yleo' and odet.orderkey='0016883700' )
--AND od.UserDefine06 = 'KIT' 
--AND od.Lottable01='546337'
ORDER by CAST(od.externlineno AS INT)
   
   OPEN CUR_LOOP
      
   FETCH NEXT FROM CUR_LOOP INTO @c_storerkey,@c_getorderkey,@c_OHUDF06,@c_sku,@n_odqty,@c_sdescr,@c_getclkudf01,@c_sbusr5,@c_lott01,@n_lineno,@c_ODUDF02
   
   WHILE @@FETCH_STATUS <> -1
   BEGIN

   SET @c_getodqty = '0' 
   SET @c_CompSKU = ''
   SET @c_getsku = @c_sku
   SET @c_getsdescr = @c_sdescr
   SET @c_skipinsert = 'N'
   --SET @c_Combinesku = ''

   IF @n_odqty = 0
   BEGIN
      IF @c_ODUDF02 IN ('N','PN')
     BEGIN
          SET @c_getodqty = CAST(@n_odqty AS NVARCHAR(10)) 
     END
     ELSE
     BEGIN
      SET @c_getodqty = CAST(@n_odqty AS NVARCHAR(10)) + SPACE(1) + @c_prefix
     END
  END
  ELSE
  BEGIN
    SET @c_getodqty = CAST(@n_odqty AS NVARCHAR(10))
  END

     IF @c_ODUDF02 = 'K' AND @n_odqty >=0 
     BEGIN
        SET @c_getodqty = ''
     END

--   SELECT @c_PrevOHUDF06 '@c_PrevOHUDF06',@c_sku '@c_sku', @c_lott01 '@c_lott01'

  IF  UPPER(@c_OHUDF06) = 'KIT' AND @c_sku = @c_lott01
  BEGIN
         --IF @c_sku = @c_lott01
         --BEGIN
            SET @c_Combinesku = @c_sku
         --END       
  END
     --SELECT @c_PrevOHUDF06 '@c_PrevOHUDF06',@n_lineno 'lineno'

    IF @c_PrevOHUDF06 = 'KIT'
    BEGIN
        
       IF @c_Prvlott01 = @c_lott01 AND @c_Combinesku = @c_lott01
       BEGIN

       SET @c_getodqty = 'NS'
       SET @c_getsku = ''
       SET @c_getsdescr = ''
       SET @c_CompSKU = @c_OHUDF06 + SPACE(2)  + CAST(@n_odqty AS  NVARCHAR(5)) + SPACE(2) + @c_sku + SPACE(2) + @c_sdescr

                  INSERT INTO #TMPBOMSKU
                (
                    StorerKey,
                    Orderkey,
                    SKU,
                    CompSKU,
                    Qty,
                    Sdescr
                )
                VALUES
                (   @c_storerkey, @c_getorderkey,@c_getsku,@c_CompSKU,@c_getodqty,@c_getsdescr)
              
             SET @c_skipinsert = 'Y'
       END
    END
    ELSE
    BEGIN
      -- SELECT @c_Combinesku '@c_Combinesku',@c_lott01 '@c_lott01',@c_Prvlott01 '@c_Prvlott01'
       IF @c_Prvlott01 = @c_lott01 AND  ISNULL(@c_Combinesku,'') <> '' AND @c_Combinesku = @c_lott01
       BEGIN

       SET @c_getodqty = 'NS'
       SET @c_getsku = ''
       SET @c_getsdescr = ''
       SET @c_CompSKU = @c_OHUDF06 + SPACE(2)  + CAST(@n_odqty AS  NVARCHAR(5)) + SPACE(2) + @c_sku + SPACE(2) + @c_sdescr

        INSERT INTO #TMPBOMSKU
                (
                    StorerKey,
                    Orderkey,
                    SKU,
                    CompSKU,
                    Qty,
                    Sdescr
                )
                VALUES
                (   @c_storerkey, @c_getorderkey,@c_getsku,@c_CompSKU,@c_getodqty,@c_getsdescr)
              
             SET @c_skipinsert = 'Y'

       END
    END
   
  IF @c_skipinsert ='N'
  BEGIN
    INSERT INTO #TMPBOMSKU
    (
        StorerKey,
        Orderkey,
        SKU,
        CompSKU,
        Qty,
        Sdescr
    )
    VALUES
    (   @c_storerkey, @c_getorderkey,@c_getsku,@c_CompSKU,@c_getodqty,@c_getsdescr)
  END

    SET @c_PrevOHUDF06 =@c_OHUDF06
    SET @c_Prvlott01 = @c_lott01
    

   FETCH NEXT FROM CUR_LOOP INTO @c_storerkey,@c_getorderkey,@c_OHUDF06,@c_sku,@n_odqty,@c_sdescr,@c_getclkudf01,@c_sbusr5,@c_lott01,@n_lineno,@c_ODUDF02
   END
   CLOSE CUR_LOOP
   DEALLOCATE CUR_LOOP

   
   SELECT            OH.ConsigneeKey
                   , LTRIM(RTRIM(ISNULL(OH.C_Address1,''))) + SPACE(1) + LTRIM(RTRIM(ISNULL(OH.C_Address2,''))) + SPACE(1) + LTRIM(RTRIM(ISNULL(OH.C_Address3,''))) + SPACE(1) + 
                      LTRIM(RTRIM(ISNULL(OH.C_Address4,''))) + SPACE(1) + LTRIM(RTRIM(ISNULL(OH.C_City,''))) + SPACE(1) + LTRIM(RTRIM(ISNULL(OH.C_State,''))) + SPACE(1) +
                      LTRIM(RTRIM(ISNULL(OH.C_Zip,''))) AS C_Addresses
                   , OH.C_VAT  
                   , OH.InvoiceNo
                   , OH.ExternOrderKey
                   , CASE WHEN Bs.CompSKU <> '' THEN ' -' +  Bs.CompSKU ELSE '' END AS compsku
                   , BS.SKU AS sku 
                   , BS.Sdescr AS sdescr  
                   ,RptHeaer = 'DELIVERY RECEIPT' 
                   ,RptCompany = 'YOUNG LIVING PHILIPPINES LLC'
                   ,RptConsignee = 'YOUNG LIVING PHILIPPINES LLC - PHILIPPINES BRANCH'
                   ,RptCompanyAddL1 = 'Unit G07, G08 & G09, 12th Floor,'
                   ,RptCompanyAddL2 = 'Twenty-Five Seven McKinley Building, '
                   ,RptCompanyAddL3 = '25th Street corner 7th Avenue, Bonifacio Global City, '
                   ,RptCompanyAddL4 = 'Fort Bonifacio, Taguig City'                                   --CS01
                   ,RptCompanyRegCode = 'VAT REG TIN: 009-915-795-000'
                   ,RptBusinessname = 'Other WholeSaling'   
                   , 'No.' + SPACE(2) + OH.DeliveryNote AS OHDELNote
                   , OrdDate = RIGHT('00' + CAST(DAY(OH.OrderDate) AS NVARCHAR(2)),2) +'-' +LEFT(DATENAME(MONTH,OH.OrderDate),3) + '-' + CAST(YEAR(OH.OrderDate) AS NVARCHAR(5))                  
                   , BS.qty AS qty 
                   , '' AS Balance
                   , 'Accreditation No.'  + SPACE(1) + @c_Clkudf01 AS Remarks1
                   , 'Date of Accreditation:' + SPACE(1) + @c_Clkudf02 AS Remarks2
                   , 'Acknowledgement Certificate No.:' + SPACE(1) + @c_Clkudf03 AS Remarks3          --CS01
                   , 'Date Issued: ' + SPACE(1) + @c_Clkudf04 AS Remarks4
                   , 'Valid Until: ' + SPACE(1) + @c_Clkudf05 AS Remarks4a
                   , 'Approved Series No.:' + SPACE(1) + @c_Clknotes2 AS Remarks5
                   , 'THIS DOCUMENT IS NOT VALID FOR CLAIM OF INPUT TAX' AS RptFooter1
                   , 'THIS INVOICE/RECEIPT SHALL BE VALID FOR FIVE (5) YEARS FROM THE DATE OF THE '  AS RptFooter2
                   , 'ACKNOWLEDGEMENT CERTIFICATE.'  AS Rptfooter2a
                   , CASE WHEN @c_Reprint = 'Y' THEN '** REPRINT **'  ELSE '' END AS Reprint 
                   , OH.C_contact1 AS c_contact1 
   FROM ORDERS OH (NOLOCK)
   --JOIN ORDERDETAIL OD (NOLOCK) ON OH.OrderKey = OD.OrderKey
   LEFT JOIN ORDERINFO OIF (NOLOCK) ON OIF.OrderKey = OH.OrderKey
   JOIN #TMPBOMSKU BS ON BS.Storerkey=OH.StorerKey AND BS.Orderkey=OH.OrderKey
   WHERE OH.OrderKey = @c_Orderkey
   ORDER BY  BS.Orderkey, BS.RowID
   
IF @c_Reprint = 'N'
BEGIN
    UPDATE [dbo].[ORDERS] WITH (ROWLOCK)        
            SET [xdockFlag] = 'Y',        
                TrafficCop = NULL,        
                EditDate = GETDATE(),        
                EditWho = SUSER_SNAME()        
            WHERE [OrderKey] = @c_OrderKey              
 
END
  
   IF OBJECT_ID('tempdb..#TMPBOMSKU') IS NOT NULL
      DROP TABLE #TMPBOMSKU

END  
GO
GRANT EXECUTE ON isp_Delivery_Receipt11 TO NSQL
GO