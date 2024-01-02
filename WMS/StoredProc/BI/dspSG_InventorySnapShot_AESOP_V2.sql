/********************************************************************************************************/        
/* Updates:[SG] AESOP - JReport Report sp - AESOP Inventory SnapShot Report - 20230913					*/  
/*																										*/        
/* Date         Author                Ver.  Purposes													*/        
/* 14-Sep-2023  Sandi			1.0		Created															*/  
/* 26-Dec-2023	Sandi			2.0		Added New column to indicate Transfer Order and Minus Kit Orders*/ 
/********************************************************************************************************/        
CREATE OR ALTER PROC [BI].[dspSG_InventorySnapShot_AESOP_V2]  
   @PARAM_StorerKey NVARCHAR(15) = 'AESOP'  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET ANSI_NULLS OFF;  
 SET QUOTED_IDENTIFIER OFF;  
 SET CONCAT_NULL_YIELDS_NULL OFF;  
 DECLARE @Debug BIT = 0  
      , @LogId  INT  
      , @LinkSrv  NVARCHAR(128)  
      , @Schema  NVARCHAR(128) = ISNULL(OBJECT_SCHEMA_NAME(@@PROCID),'')  
      , @Proc   NVARCHAR(128) = ISNULL(OBJECT_NAME(@@PROCID),'')  
      , @Err         INT = 0  
      , @ErrMsg      NVARCHAR(250)  = ''  
      , @nRowCnt     INT = 0  
      , @cParamOut NVARCHAR(4000)= ''  
      , @cParamIn NVARCHAR(4000)= ''  
    
  EXEC BI.dspExecInit @ClientId = @PARAM_StorerKey  
  , @Proc = @Proc  
  , @ParamIn = @cParamIn  
  , @LogId = @LogId OUTPUT  
  , @Debug = @Debug OUTPUT  
  , @Schema = @Schema;  
 DECLARE @Stmt NVARCHAR(MAX) = '' -- for storing dynamic SQL Statement     
/* Sandi 2023-09-13 START*/  
   BEGIN TRY  
      IF OBJECT_ID('tempdb..#TEMP_UNCLOSEASN_QTY','u') IS NOT NULL  DROP TABLE #TEMP_UNCLOSEASN_QTY ;    
          CREATE TABLE #TEMP_UNCLOSEASN_QTY         
          ( Sku         NVARCHAR(40) NULL,        
			lottable03 NVARCHAR (36) NULL,  
			Lottable01 NVARCHAR (36) NULL,  
			QTY         INT  NULL    
           )                  
      INSERT INTO #TEMP_UNCLOSEASN_QTY(Sku, lottable03, Lottable01, QTY)       
      SELECT  RD.Sku,     
        RD.Lottable03,  
        RD.Lottable01,  
        isnull(Sum(RD.QtyReceived),0)      
      From BI.V_Receipt R (NOLOCK)    
      JOIN BI.V_ReceiptDetail RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey AND R.StorerKey = RD.StorerKey    
      WHERE R.ASNStatus <> '9'     
      AND R.ASNStatus <> 'CANC'      
      AND R.Storerkey = @PARAM_StorerKey    
      AND RD.QtyReceived > 0    
      GROUP by RD.Sku,RD.Lottable03,RD.Lottable01  
	  ----- To minus
	  IF OBJECT_ID ('tempdb..#TEMP_UNCLOSEKIT_QTY','u') IS NOT NULL DROP TABLE #TEMP_UNCLOSEKIT_QTY;
	  CREATE TABLE #TEMP_UNCLOSEKIT_QTY
	  (	SKU			NVARCHAR(40) NULL,
		Lottable03	NVARCHAR (36) NULL,
		Lottable01	NVARCHAR (36) NULL,
		Qty			INT NULL
	  )
	  INSERT INTO #TEMP_UNCLOSEKIT_QTY(Sku, lottable03, Lottable01, QTY)  
		SELECT  KD.SKU, KD.Lottable03, KD.Lottable01, ISNULL(SUM(KD.ExpectedQty),0)
                  FROM BI.V_KIT K (NOLOCK)  
                  JOIN BI.V_KITDETAIL KD (NOLOCK) ON K.Kitkey = KD.Kitkey  
                  AND K.Status <> '9'   
                  AND KD.Type = 'F'  
                  AND K.Storerkey = @PARAM_StorerKey 
		GROUP by KD.Sku,KD.Lottable03,KD.Lottable01  
      ------Inventory SnapShot ----------  
      SELECT INVSS.INVENTORYDATE,  
        INVSS.SKUSUBCAT,  
        INVSS.SKU,  
        INVSS.SKUDESCR,  
        INVSS.EAN,  
        INVSS.BATCHNO,  
        INVSS.PRODUCTIONDATE,  
        INVSS.RECEIPTDATE,  
        CASE   
        WHEN INVSS.BatchTrackSKU = 'Y' AND INVSS.PRODUCTIONDATE != CAST ('9999-12-31' As Date) THEN DATEADD (YEAR,3,INVSS.PRODUCTIONDATE)  
        WHEN INVSS.BatchTrackSKU = 'N' THEN DATEADD (YEAR,3,INVSS.RECEIPTDATE)   
        END AS EXPIRYDATE,  
        INVSS.QTYAllocated,  
        INVSS.QtyPicked,  
        CASE  
        WHEN INVSS.BatchTrackSKU = 'Y' AND INVSS.PRODUCTIONDATE != CAST ('9999-12-31' As Date) THEN DATEDIFF(DAY, INVSS.PRODUCTIONDATE, CAST( GETDATE() AS DATE ))  
        WHEN INVSS.BatchTrackSKU = 'N' THEN DATEDIFF(DAY, INVSS.RECEIPTDATE, CAST( GETDATE() AS DATE ))  
        END AS AGINGDAY,  
        INVSS.STOCKSTATUS,  
        ONHAND_QTY = INVSS.ONHANDQTY - ---- minus Non-CLosed ASN  
          (SELECT isNUll (Sum(TMP.Qty),0)  
          FROM #TEMP_UNCLOSEASN_QTY TMP  
          WHERE TMP.sku = INVSS.SKU  
          AND TMP.Lottable01 = INVSS.BATCHNO  
          AND TMP.lottable03 = INVSS.STOCKSTATUS) - ------ minus Non-Closed Kit Order
		  (SELECT isNull (Sum(TMP.Qty),0)
		  FROM #TEMP_UNCLOSEKIT_QTY TMP
		  WHERE TMP.sku = INVSS.SKU
		  AND TMP.Lottable01 = INVSS.BATCHNO
		  AND TMP.Lottable03 = INVSS.STOCKSTATUS
		  ),  
        Available_QTY = (INVSS.ONHANDQTY-INVSS.QTYAllocated-INVSS.QtyPicked)  
            - ----Minus Non-Closed ASN  
           (SELECT isNUll (Sum(TMP.Qty),0)  
			FROM #TEMP_UNCLOSEASN_QTY TMP  
			WHERE TMP.sku = INVSS.SKU  
			AND TMP.Lottable01 = INVSS.BATCHNO  
			AND TMP.lottable03 = INVSS.STOCKSTATUS)  - ----- Minus Non-Closed Kit Order
		   (SELECT isNull (Sum(TMP.Qty),0)
			FROM #TEMP_UNCLOSEKIT_QTY TMP
			WHERE TMP.sku = INVSS.SKU
			AND TMP.Lottable01 = INVSS.BATCHNO
			AND TMP.Lottable03 = INVSS.STOCKSTATUS
		   ),
		   INVSS.AwaitingTransfer,
		   INVSS.QtyAwaitingToTransfer
      FROM   
      (  
		Select CAST( GETDATE() AS DATE ) AS INVENTORYDATE,   
		/*CASE WHEN SKU.CLASS = '5' THEN 'RETAIL'  
		WHEN SKU.CLASS = '1' THEN 'AMENITY'  
		WHEN SKU.CLASS = '13' THEN 'PRODUCT PACKAGING'  
		WHEN SKU.CLASS = '2' THEN 'KIT ITEM ONLY'  
		WHEN SKU.CLASS = '3' THEN 'NON SALE'  
		WHEN SKU.CLASS = '4' THEN 'PREMIUM SAMPLE'  
		WHEN SKU.CLASS = '6' THEN 'SAMPLE'  
		WHEN SKU.CLASS = '7' THEN 'TESTER'  
		END AS SUBCAT,*/  
		CDLKUP.Description AS SKUSUBCAT,  
		SKU.SUSR1 AS BatchTrackSKU,  
		LLI.SKU AS SKU,   
		SKU.DESCR AS SKUDESCR,   
		SKU.MANUFACTURERSKU AS EAN,   
		LA.LOTTABLE01 AS BATCHNO,  
		CASE   
		WHEN SKU.SUSR1 = 'Y' AND LA.LOTTABLE01 = 'NA' AND Cast(dbo.fnc_GetNumFromString(LA.LOTTABLE01,'AESOP') as date) = CAST ('1900-01-01' As Date) THEN CAST ('' AS DATE)  
		WHEN SKU.SUSR1 = 'Y' AND LLI.SKU = 'AHM01' THEN CAST ('9999-12-31' As Date)   
		WHEN SKU.SUSR1 = 'Y' AND LA.LOTTABLE01 like 'QUO%' AND (Cast(dbo.fnc_GetNumFromString(LA.LOTTABLE01,'AESOP') as date) = CAST (DATEADD(DAY, -819, GETDATE()) AS DATE)) THEN CAST ('9999-12-31' As Date)   
		WHEN SKU.SUSR1 = 'Y' AND CDLKUP.Description = 'Visual Merchandising' THEN CAST ('9999-12-31' As Date)   
		WHEN SKU.SUSR1 = 'Y' AND LA.LOTTABLE01 != 'NA' THEN Cast(dbo.fnc_GetNumFromString(LA.LOTTABLE01,'AESOP') as date)  
		WHEN SKU.SUSR1 = 'N' AND Cast(dbo.fnc_GetNumFromString(LA.LOTTABLE01,'AESOP') as date) = '1900-01-01' THEN  CAST ('' AS DATE)  
		END AS PRODUCTIONDATE,  
		LA.LOTTABLE05 AS RECEIPTDATE,  
		Sum (LLI.QTY) AS ONHANDQTY,  
		Sum (LLI.qtyallocated) AS QTYAllocated,  
		Sum (LLI.QtyPicked) As QtyPicked,  
		LA.LOTTABLE03 AS STOCKSTATUS ,
		CASE WHEN LLI.SKU = TRANS.TOSKU THEN 'Y'
		ELSE ''
		END AS AwaitingTransfer,
		CASE WHEN LLI.SKU = TRANS.TOSKU THEN TRANS.TOQty
		ELSE ''
		END AS QtyAwaitingToTransfer
		From BI.V_LOTxLOCXID LLI  
		JOIN BI.V_SKU SKU ON SKU.SKU = LLI.SKU AND SKU.StorerKey = LLI.StorerKey  
		JOIN BI.V_LOTATTRIBUTE LA ON LA.LOT = LLI.LOT  
		JOIN BI.V_LOC LOC on LOC.LOC = LLI.LOC  
		JOIN BI.V_CODELKUP CDLKUP on CDLKUP.Code2 = SKU.CLASS and SKU.Storerkey = CDLKUP.Storerkey 
		LEFT JOIN (Select TD.TOSKU, TD.FromLot, TD.ToLottable03, TD.Lottable05, TD.lottable01, TD.TOQty, IT.sourcekey, IT.Lot--sum(TD.TOQty)
		From BI.V_TRANSFER TH
		JOIN BI.V_TRANSFERDETAIL TD ON TH.Transferkey = TD.Transferkey
		JOIN	(Select distinct Sourcekey, sku, lot, storerkey, toloc, lottable03, lottable05, qty
				from BI.V_ITRN where storerkey = 'AESOP' 
				and TranType = 'DP') IT ON IT.sku = TD.Fromsku and IT.Qty = TD.TOQty 
				Where TD.FromStorerkey = 'AESOP'
				--AND TD.Transferkey = '0000342869'
				AND (IT.Sourcekey like Concat (TD.Transferkey, '%') AND IT.Sourcekey like Concat ('%',TD.TransferLineNumber))
				AND TH.CustomerRefNo <> 'MOVED' and TH.Type = 'EDI'
				GROUP BY TD.FROMLOT, TD.ToSKU, TD.ToLottable03, TD.Lottable05, TD.Lottable01, TD.TOQty, IT.sourcekey, IT.Lot
		) TRANS ON TRANS.Lot = LA.Lot AND LLI.SKU = TRANS.ToSku
      WHERE LLI.storerkey = 'AESOP'   
      AND CDLKUP.Listname = 'CUSTPARAM' and CDLKUP.Code = 'PRODSUBCAT'  
      GROUP BY   
      /*CASE WHEN SKU.CLASS = '5' THEN 'RETAIL'  
      WHEN SKU.CLASS = '1' THEN 'AMENITY'  
      WHEN SKU.CLASS = '13' THEN 'PRODUCT PACKAGING'  
      WHEN SKU.CLASS = '2' THEN 'KIT ITEM ONLY'  
      WHEN SKU.CLASS = '3' THEN 'NON SALE'  
      WHEN SKU.CLASS = '4' THEN 'PREMIUM SAMPLE'  
      WHEN SKU.CLASS = '6' THEN 'SAMPLE'  
      WHEN SKU.CLASS = '7' THEN 'TESTER'  
      END,*/  
      CDLKUP.Description,  
      LLI.SKU,   
      SKU.DESCR,  
      SKU.MANUFACTURERSKU,  
      SKU.SUSR1,  
      LA.LOTTABLE01,  
      LA.LOTTABLE05,  
      LA.LOTTABLE03,
	  TRANS.TOSKU,
	  TRANS.TOQty 
      )INVSS  
         SELECT @nRowCnt = @@ROWCOUNT;  
   END TRY  
   BEGIN CATCH  
      SELECT @Err = ERROR_NUMBER(), @ErrMsg = ERROR_MESSAGE();  
   END CATCH  
   IF @Err > 0  
   BEGIN  
      SET @nRowCnt = 0  
   END  
   SET @cParamOut = CONCAT('{ "Stmt": "', LEFT(@Stmt,3985)+CASE WHEN LEN(@Stmt)>3985 THEN '…' ELSE '' END, '" }');  
   UPDATE dbo.ExecutionLog SET TimeEnd = GETDATE(), RowCnt = @nRowCnt, ParamOut = @cParamOut  
   , ErrNo = @Err  
   , ErrMsg = @ErrMsg  
   WHERE LogId = @LogId;  
   IF @Err > 0  
   BEGIN  
      SET @Err = @Err + 50000; --   Because error_number in THROW syntax must be >= 50000  
      THROW @Err, @ErrMsg, 1;  -- THROW [ { error_number }, { exception_message }, { state } ]  
   END  
END  
GO

GRANT EXEC ON BI.dspSG_InventorySnapShot_AESOP_V2 TO JReportRole
GO

/*
   EXEC AS LOGIN = 'JReportUserSG'
   SELECT SUSER_SNAME()
   EXEC BI.dspSG_InventorySnapShot_AESOP_V2
   REVERT;

   SELECT TOP 99 * 
   FROM dbo.ExecutionLog WITH (NOLOCK)
   WHERE sp ='dspSG_InventorySnapShot_AESOP_V2' 
   ORDER BY 1 DESC
*/
