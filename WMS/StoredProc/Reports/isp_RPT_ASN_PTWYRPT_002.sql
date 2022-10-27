SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/              
/* Stored Procedure: isp_RPT_ASN_PTWYRPT_002                            */              
/* Creation Date: 14-Oct-2022                                           */          
/* Copyright: LF Logistics                                              */          
/* Written by: WZPang                                                   */          
/*                                                                      */          
/* Purpose: WMS-20938 - MY - KFMY Putaway Advice Reformat		        */            
/*                                                                      */              
/* Called By: RPT_ASN_PTWYRPT_002                                       */              
/*                                                                      */              
/* PVCS Version: 1.1                                                    */              
/*                                                                      */              
/* Version: 7.0                                                         */              
/*                                                                      */              
/* Data Modifications:                                                  */              
/*                                                                      */              
/* Updates:                                                             */              
/* Date         Author   Ver  Purposes                                  */
/************************************************************************/              
CREATE OR ALTER PROC [dbo].[isp_RPT_ASN_PTWYRPT_002] (      
      @c_ReceiptKey		NVARCHAR(10)
)              
 AS              
 BEGIN              
   SET NOCOUNT ON              
   SET ANSI_NULLS ON              
   SET QUOTED_IDENTIFIER OFF              
   SET CONCAT_NULL_YIELDS_NULL OFF              
   SET ANSI_WARNINGS ON        
                
      
   DECLARE @c_storerkey NVARCHAR(15),  
            @c_udf01 NVARCHAR(60),  
            @c_udf02 NVARCHAR(60),  
            @c_udf03 NVARCHAR(60),  
            @c_TableName NVARCHAR(100),  
            @c_ColName NVARCHAR(100),  
            @c_ColType NVARCHAR(100),  
            @c_ISCombineSKU NCHAR(1),  
            @cSQL NVARCHAR(Max),  
            @c_FromWhere NVARCHAR(2000),                
            @c_InsertSelect NVARCHAR(2000)                          
                            
    CREATE TABLE #TEMP_SKU (Storerkey NVARCHAR(15) NULL, SKU NVARCHAR(20) NULL, DESCR NVARCHAR(60) NULL,   
                            Packkey NVARCHAR(10) NULL, BUSR6 NVARCHAR(18) NULL, IVAS NVARCHAR(30) NULL,                               
                            RetailSku NVARCHAR(20) NULL, ManufacturerSku NVARCHAR(20) NULL, ShelfLife INT NULL,   
                            COMBINESKU NVARCHAR(100) NULL)  
          
    DECLARE CUR_RECSTORER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
       SELECT DISTINCT RECEIPT.Storerkey  
       FROM RECEIPT (NOLOCK)  
       WHERE ( RECEIPT.ReceiptKey = @c_ReceiptKey ) 
     
    OPEN CUR_RECSTORER  
  
    FETCH NEXT FROM CUR_RECSTORER INTO @c_Storerkey  
      
    WHILE @@FETCH_STATUS <> -1  
    BEGIN  
      SELECT @c_udf01 = '', @c_udf02 = '', @c_udf03 = '', @c_ISCombineSKU = 'N', @c_InsertSelect = '', @c_FromWhere = ''  
  
       SELECT @c_udf01 = ISNULL(CL.UDF01,''),  
              @c_udf02 = ISNULL(CL.UDF02,''),  
              @c_udf03 = ISNULL(CL.UDF03,'')  
       FROM CODELKUP CL (NOLOCK)  
       WHERE Listname = 'COMBINESKU'  
       AND Code = 'CONCATENATESKU'  
       AND Storerkey = @c_Storerkey  
         
       IF @@ROWCOUNT > 0  
       BEGIN  
          SET @c_ISCombineSKU = 'Y'  
          SET @c_InsertSelect = ' INSERT INTO #TEMP_SKU SELECT DISTINCT SKU.Storerkey, SKU.Sku, SKU.Descr, SKU.Packkey, SKU.Busr6, SKU.IVAS, SKU.RetailSku, SKU.ManufacturerSku, SKU.ShelfLife '  
          SET @c_FromWhere = ' FROM SKU (NOLOCK) '  
                           + ' JOIN RECEIPTDETAIL RD (NOLOCK) ON SKU.Storerkey = RD.Storerkey AND SKU.Sku = RD.Sku '  
                           + ' JOIN RECEIPT R (NOLOCK) ON RD.Receiptkey = R.Receiptkey '  
                           + ' WHERE R.Receiptkey = RTRIM(@c_Receiptkey) ' 
                           + ' AND R.Storerkey = RTRIM(@c_storerkey) '  
         
           
          SET @c_ColName = @c_udf01  
          SET @c_TableName = 'SKU'  
          IF CharIndex('.', @c_udf01) > 0  
          BEGIN  
             SET @c_TableName = LEFT(@c_udf01, CharIndex('.', @c_udf01) - 1)  
             SET @c_ColName   = SUBSTRING(@c_udf01, CharIndex('.', @c_udf01) + 1, LEN(@c_udf01) - CharIndex('.', @c_udf01))  
          END  
            
          SET @c_ColType = ''  
          SELECT @c_ColType = DATA_TYPE   
          FROM   INFORMATION_SCHEMA.COLUMNS   
          WHERE  TABLE_NAME = @c_TableName  
          AND    COLUMN_NAME = @c_ColName  
            
          IF @c_ColType IN ('char', 'nvarchar', 'varchar') AND @c_TableName = 'SKU'  
             SELECT @c_InsertSelect = @c_InsertSelect + ',LTRIM(RTRIM(ISNULL('+ RTRIM(@c_udf01) + ',''''))) '                                      
          ELSE  
            SELECT @c_InsertSelect = @c_InsertSelect + ',''' + LTRIM(RTRIM(@c_udf01)) + ''' '                                  
         
            
          SET @c_ColName = @c_udf02  
          SET @c_TableName = 'SKU'  
          IF CharIndex('.', @c_udf02) > 0  
          BEGIN  
             SET @c_TableName = LEFT(@c_udf02, CharIndex('.', @c_udf02) - 1)  
             SET @c_ColName   = SUBSTRING(@c_udf02, CharIndex('.', @c_udf02) + 1, LEN(@c_udf02) - CharIndex('.', @c_udf02))  
          END  
            
          SET @c_ColType = ''  
          SELECT @c_ColType = DATA_TYPE   
          FROM   INFORMATION_SCHEMA.COLUMNS   
          WHERE  TABLE_NAME = @c_TableName  
          AND    COLUMN_NAME = @c_ColName  
            
          IF @c_ColType IN ('char', 'nvarchar', 'varchar') AND @c_TableName = 'SKU'  
             SELECT @c_InsertSelect = @c_InsertSelect + ' + LTRIM(RTRIM(ISNULL('+ RTRIM(@c_udf02) + ',''''))) '                                      
          ELSE  
             SELECT @c_InsertSelect = @c_InsertSelect + ' + ''' + LTRIM(RTRIM(@c_udf02)) + ''' '                                  
         
            
          SET @c_ColName = @c_udf03  
          SET @c_TableName = 'SKU'  
          IF CharIndex('.', @c_udf03) > 0  
          BEGIN  
             SET @c_TableName = LEFT(@c_udf03, CharIndex('.', @c_udf03) - 1)  
             SET @c_ColName   = SUBSTRING(@c_udf03, CharIndex('.', @c_udf03) + 1, LEN(@c_udf03) - CharIndex('.', @c_udf03))  
          END  
            
          SET @c_ColType = ''  
          SELECT @c_ColType = DATA_TYPE   
          FROM   INFORMATION_SCHEMA.COLUMNS   
          WHERE  TABLE_NAME = @c_TableName  
          AND    COLUMN_NAME = @c_ColName  
            
          IF @c_ColType IN ('char', 'nvarchar', 'varchar') AND @c_TableName = 'SKU'  
             SELECT @c_InsertSelect = @c_InsertSelect + ' + LTRIM(RTRIM(ISNULL('+ RTRIM(@c_udf03) + ',''''))) '                                      
          ELSE  
             SELECT @c_InsertSelect = @c_InsertSelect + ' + ''' + LTRIM(RTRIM(@c_udf03)) + ''' '                                                
         
          SET @cSQL = @c_InsertSelect + @c_FromWhere  
          EXEC sp_executesql @cSQL, N'@c_storerkey nvarchar(15), @c_ReceiptKey nvarchar(10) ',   
               @c_storerkey, @c_ReceiptKey
		  
       END  
         
       IF @c_ISCombineSKU = 'N'  
       BEGIN  
          INSERT INTO #TEMP_SKU  
          SELECT DISTINCT SKU.Storerkey, SKU.Sku, SKU.Descr, SKU.Packkey, SKU.Busr6, SKU.IVAS, SKU.RetailSku, SKU.ManufacturerSku, SKU.ShelfLife, SKU.Sku  
          FROM SKU (NOLOCK)  
          JOIN RECEIPTDETAIL RD (NOLOCK) ON SKU.Storerkey = RD.Storerkey AND SKU.Sku = RD.Sku  
          JOIN RECEIPT R (NOLOCK) ON RD.Receiptkey = R.Receiptkey  
          WHERE R.Receiptkey = @c_ReceiptKey
          AND R.Storerkey = @c_storerkey  
       END       
     
       FETCH NEXT FROM CUR_RECSTORER INTO @c_Storerkey  
    END  
    CLOSE CUR_RECSTORER  
    DEALLOCATE CUR_RECSTORER   
      
    SELECT DISTINCT Storerkey, SKU, DESCR, Packkey, Busr6, IVAS, RetailSku, ManufacturerSku, ShelfLife, COMBINESKU   
    INTO #TEMP_SKU2  
    FROM #TEMP_SKU  
                  
    SELECT RECEIPT.ReceiptKey,     
           RECEIPT.ExternReceiptKey,   
           RECEIPTDETAIL.ReceiptLineNumber,     
           SKU.CombineSku AS ReceiptDetailSKU,   
           UPPER(RECEIPTDETAIL.Storerkey) AS Storerkey,   
           SKU.DESCR AS SKU_Descr,     
           RECEIPTDETAIL.ToId,     
           RECEIPTDETAIL.ToLoc,     
           RECEIPTDETAIL.QtyReceived,     
           RECEIPTDETAIL.UOM,     
           RECEIPTDETAIL.Lottable02,  
           RECEIPTDETAIL.Lottable04,     
           RECEIPTDETAIL.POKey,     
           RECEIPTDETAIL.PutawayLoc,
           RECEIPTDETAIL.BeforeReceivedQty,  
           RECEIPT.ReceiptDate,  
           STORER.Company,   
           (suser_sname()) user_name,   
           receipt.warehousereference,    
           PACK.CaseCnt,  
           PACK.InnerPack,  
           PACK.Qty,  
           PACK.Pallet,  
           PACK.[Cube],  
           PACK.GrossWgt,  
           PACK.NetWgt,  
           PACK.OtherUnit1,  
           PACK.OtherUnit2,  
           PACK.PackUom1,  
           PACK.PackUom2,  
           PACK.PackUom3,  
           PACK.PackUom4,  
           PACK.PackUom5,  
           PACK.PackUom6,  
           PACK.PackUom7,  
           PACK.PackUom8,  
           PACK.PackUom9,  
           RECEIPT.Facility,  
           Facility.Descr AS FACILITY_Descr,  
           RECEIPT.Signatory,  
           SKU.RetailSku,    
           SKU.MANUFACTURERSKU,       
           SKU.BUSR6,  
           SKU.IVAS,   
           Sku.ShelfLife,
		   LOC.PutAwayZone,
		   TASKDETAIL.ToLoc AS TaskDetailToLOC,
           CASE PACK.Casecnt WHEN 0 THEN 0  
              ELSE CAST(RECEIPTDETAIL.BeforeReceivedQty / PACK.Casecnt as int)         
           END ReceivedCase,  
           CASE PACK.InnerPack when 0 THEN 0  
        ELSE   
          CASE PACK.Casecnt WHEN 0 THEN (cast(RECEIPTDETAIL.BeforeReceivedQty as int) / cast(PACK.InnerPack as int))   
                ELSE ((cast(RECEIPTDETAIL.BeforeReceivedQty as int) % cast(PACK.Casecnt as int) ) / cast(PACK.InnerPack as int)) END  
           END ReceivedPack,  
           CASE PACK.InnerPack when 0 THEN   
              CASE PACK.Casecnt WHEN 0 THEN cast(RECEIPTDETAIL.BeforeReceivedQty as int)  
                ELSE (cast(RECEIPTDETAIL.BeforeReceivedQty as int) % cast(PACK.Casecnt as int)) END  
        ELSE   
          CASE PACK.Casecnt WHEN 0 THEN (cast(RECEIPTDETAIL.BeforeReceivedQty as int) % cast(PACK.InnerPack as int))   
                ELSE (cast(RECEIPTDETAIL.BeforeReceivedQty as int) % cast(PACK.Casecnt as int)) END 
           END ReceivedEA   
   FROM RECEIPT (NOLOCK)   
   JOIN RECEIPTDETAIL (NOLOCK) ON ( RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey )  
   JOIN #TEMP_SKU2 SKU (NOLOCK) ON ( SKU.StorerKey = RECEIPTDETAIL.StorerKey ) AND  ( SKU.Sku = RECEIPTDETAIL.Sku )   
   JOIN STORER (NOLOCK) ON ( RECEIPT.Storerkey = STORER.Storerkey )   
   JOIN PACK (NOLOCK) ON ( pack.packkey = sku.packkey )   
   JOIN FACILITY (NOLOCK) ON ( RECEIPT.Facility = FACILITY.Facility ) 
   LEFT JOIN LOC (NOLOCK) ON ( RECEIPTDETAIL.PutAwayLoc = LOC.LOC)
   LEFT JOIN TASKDETAIL (NOLOCK) ON ( TASKDETAIL.FromID = RECEIPTDETAIL.ToID AND TASKDETAIL.TaskType = 'ASTPA1')
   WHERE  RECEIPT.ReceiptKey = @c_ReceiptKey               
      
      
END -- procedure  
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_PTWYRPT_002]  TO NSQL
GO  
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_PTWYRPT_002] TO JReportRole 
GO