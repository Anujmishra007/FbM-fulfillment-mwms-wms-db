IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_OrdersMerging]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_OrdersMerging]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*-------------------------------------------------------------------------------------------------------*/
/* Stored Procedure: isp_OrdersMerging                                                                   */      
/* Creation Date: 04-April-2017                                                                          */        
/* Copyright: LF LOGISTICS                                                                               */        
/* Written by: JayLim                                                                                    */        
/*                                                                                                       */        
/* Purpose: Auto Combine Order data when there are duplicate values base on codelkup columns             */        
/*                                                                                                       */        
/* Called By: BEJ - Orders Merge                             		                                       */         
/*                                                                                                       */        
/* Parameters:                                                                                           */        
/*                                                                                                       */        
/* PVCS Version: 1.0                                                                                     */        
/*                                                                                                       */        
/* Version: 5.4                                                                                          */        
/*                                                                                                       */        
/* Data Modifications:                                                                                   */        
/*                                                                                                       */        
/* Updates:                                                                                              */        
/* Date         Author    Ver. Purposes                                                                  */ 
/* 26-May-2017  JayLim    1.1  FBR_WMS-1495  FBR ver1.4  (jay01)                                         */
/* 05-Jun-2017  JayLim    1.2  FBR_WMS-1495  FBR ver1.5  (jay02)                                         */ 
/* 08-Jun-2017  JayLim    1.3  FBR_WMS-1495  FBR ver1.7  (jay03)                                         */    
/* 03-Aug-2017  TLTING    1.4  Script revised                                                            */
/* 07-Aug-2017  TLTING    1.5  Child orders.M_Company map to Orderdetail.Notes  Comb_order               */
/* 28-Jan-2019  TLTING_ext 1.6  enlarge externorderkey field length                                      */
/*-------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[isp_OrdersMerging]
(
@c_StorerKey NVARCHAR(15),
@b_debug INT = 0, --(1 for on, 0 for off, default 0)
@c_errmsg NVARCHAR(128) = '' OUTPUT 
)
AS
SET NOCOUNT ON    
SET ANSI_NULLS OFF    
SET QUOTED_IDENTIFIER OFF    
SET CONCAT_NULL_YIELDS_NULL OFF 
BEGIN

DECLARE @c_SValue       NVARCHAR(1)
       ,@n_continue     INT
       ,@n_columnsTotal INT
       ,@c_ExecSttmt    NVARCHAR(max)
       ,@c_ExecArgSttmt NVARCHAR(max)
       ,@c_AllColumns   NVARCHAR(4000)
       ,@c_WhereColumn  NVARCHAR(4000)
       ,@c_ColumnName   NVARCHAR(45)
       ,@c_OrderKey     NVARCHAR(10)
	   ,@c_ExternOrderKey NVARCHAR(50)  --tlting_ext
       ,@n_Row_No       INT
       ,@c_M_Company    NVARCHAR(45)
       ,@c_GetOrderKeys NVARCHAR(4000)
       ,@c_GetM_Company NVARCHAR(4000)
       ,@c_NewOrderkey  NVARCHAR(10)
       ,@b_success      INT
       ,@n_rowcount     INT
       ,@n_err          NVARCHAR(128)
       ,@n_lineNo       INT
       ,@c_OD_OrderKey       NVARCHAR(10)
       ,@c_OD_OrderLine      NVARCHAR(5)
       ,@c_OD_MCompany       NVARCHAR(4000)
       ,@c_OD_ExOrderKey     NVARCHAR(50)
       ,@c_CState       NVARCHAR(10) --(jay03)
       ,@c_STOP_short   NVARCHAR(2)
       ,@c_STOP_code    NVARCHAR(10)
       ,@c_STOP         NVARCHAR(10)
       ,@n_TotOpenQty   INT
       ,@n_TotInvoiceAmount  float
       ,@n_TotUserdefine01   BigINT
       ,@n_TotUserdefine05   BIGINT
       , @n_StartTCnt INT
	   ,@n_Notes2 NVARCHAR(4000)



/********** Initial parameter values **************/
SELECT @c_SValue        = NULL
SELECT @n_columnsTotal  = 0
SELECT @c_ExecSttmt     = ''
SELECT @c_ExecArgSttmt  = ''
SELECT @c_AllColumns    = ''
SELECT @c_WhereColumn   = ''
SELECT @n_continue = 1, @b_success = 0, @n_err = '' , @n_rowcount = 0
SET @n_StartTCnt = @@ROWCOUNT

IF ISNULL(OBJECT_ID('tempdb..#Temp_FinalOrders'), '') <> ''
BEGIN
   DROP TABLE #Temp_FinalOrders
END

CREATE TABLE #Temp_FinalOrders
(
   OrderKey       NVARCHAR(10)
  ,ExternOrderKey NVARCHAR(50)  --tlting_ext
  ,M_Company      NVARCHAR(200)
  ,Row_no         INT
  ,C_State        NVARCHAR(45) --(jay03)
)

DECLARE @temp_CodelkupTable TABLE
(
   Code NVARCHAR(30),
   Long NVARCHAR(45)
)

IF ISNULL(OBJECT_ID('tempdb..#temp_CodelkupStopList'), '') <> ''  --(jay03)
BEGIN
   DROP TABLE #temp_CodelkupStopList
END


CREATE TABLE #temp_CodelkupStopList  --(jay03)
(
   Code NVARCHAR(30),
   Short NVARCHAR(10)
)

IF ISNULL(OBJECT_ID('tempdb..#temp_OrderDetail'),'') <> ''
BEGIN
   DROP TABLE #temp_OrderDetail
END

CREATE TABLE #temp_OrderDetail 
(
   OrderKey             nvarchar(10) 
   ,OrderLineNumber     nvarchar(5) 
   ,ExternOrderKey      nvarchar(50)   --tlting_ext
   ,ExternLineNo        nvarchar(20) NULL
   ,StorerKey           nvarchar(15) 
   ,Sku                 nvarchar(20)
   ,ManufacturerSku     nvarchar(20)
   ,RetailSku           nvarchar(20)
   ,AltSku              nvarchar(20)
   ,OriginalQty         int
   ,OpenQty             int
   ,ShippedQty          int
   ,AdjustedQty         int 
   ,QtyPreAllocated     int
   ,QtyAllocated        int
   ,QtyPicked           int
   ,UOM                 nvarchar(10) 
   ,PackKey             nvarchar(10)
   ,PickCode            nvarchar(10) 
   ,CartonGroup         nvarchar(10)
   ,Lot                 nvarchar(10) 
   ,ID                  nvarchar(18) 
   ,Facility            nvarchar(5) 
   ,[Status]            nvarchar(10)
   ,UnitPrice           float NULL
   ,Tax01               float NULL
   ,Tax02               float NULL 
   ,ExtendedPrice       float NULL
   ,UpdateSource        nvarchar(10) 
   ,Lottable01          nvarchar(18) 
   ,Lottable02          nvarchar(18) 
   ,Lottable03          nvarchar(18) 
   ,Lottable04          datetime  NULL
   ,Lottable05          datetime  NULL
   ,AddDate             datetime 
   ,AddWho              nvarchar(18)
   ,FreeGoodQty         INT  NULL
   ,GrossWeight         FLOAT  NULL
   ,Capacity            float NULL
   ,QtyToProcess        int NULL
   ,MinShelfLife        INT NULL
   ,UserDefine01        nvarchar(18)  NULL
   ,UserDefine02        nvarchar(18)  NULL
   ,UserDefine03        nvarchar(18)  NULL
   ,UserDefine04        nvarchar(18)  NULL
   ,UserDefine05        nvarchar(18)  NULL
   ,UserDefine06        nvarchar(18)  NULL
   ,UserDefine07        nvarchar(18)  NULL 
   ,UserDefine08        nvarchar(18)  NULL 
   ,UserDefine09        NVARCHAR(18)  NULL 
   ,POkey               nvarchar(20)  NULL
   ,ExternPOKey         nvarchar(20)  NULL
   ,UserDefine10        nvarchar(18)  NULL
   ,EnteredQTY          INT NULL
   ,ConsoOrderKey       nvarchar(30)  NULL
   ,ExternConsoOrderKey nvarchar(30) NULL
   ,ConsoOrderLineNo    nvarchar(5)  NULL
   ,Lottable06          nvarchar(30) 
   ,Lottable07          nvarchar(30) 
   ,Lottable08          nvarchar(30) 
   ,Lottable09          nvarchar(30) 
   ,Lottable10          nvarchar(30) 
   ,Lottable11          nvarchar(30) 
   ,Lottable12          nvarchar(30) 
   ,Lottable13          datetime  NULL
   ,Lottable14          datetime  NULL
   ,Lottable15          datetime  NULL
   ,Notes               nvarchar(4000)  NULL
   ,Notes2              nvarchar(4000)  NULL
   ,ROW_NO              INT
)

/********* StorerConfig checking *********/

SELECT @c_SValue = SVALUE 
FROM StorerConfig WITH (NOLOCK)
WHERE ConfigKey = 'ORDCOMB' AND Storerkey = @c_StorerKey

IF (@c_SValue <> 1)
BEGIN
   SET @n_continue =  3
   SET @c_errmsg = N'FAIL MERGING. ConfigKey ''ORDCOMB'' for storerkey'''+@c_StorerKey
                   +''' is Turn OFF. Refer StorerConfig Table'
   IF (@b_debug = 1)
   BEGIN
      SELECT 'SVALUE = '+ @c_SValue
   END
END

/********* Acquiring Order table's Columns from Codelkup  *********/

IF (@n_continue = 1  OR @n_continue = 2)
BEGIN
   INSERT INTO @temp_CodelkupTable ([Code], [long]) 
   SELECT [Code],[Long] 
   FROM CODELKUP WITH (NOLOCK) --(jay02)
   WHERE Listname = 'ORDCOMB' AND Storerkey = @c_StorerKey AND Short = '1' --(jay02)
   ORDER BY [Code] ASC

   SELECT @n_columnsTotal = COUNT([Code]) FROM @temp_CodelkupTable

   INSERT INTO #temp_CodelkupStopList ([Code], [Short]) --(jay03)
   SELECT [Code],[Short] 
   FROM CODELKUP WITH (NOLOCK) 
   WHERE Listname = 'UAStList' AND Storerkey = @c_StorerKey  

   IF NOT EXISTS (SELECT 1 FROM @temp_CodelkupTable)
   BEGIN
      SET @n_continue = 3
      SET @c_errmsg = N'FAIL MERGING. No columns acquire from ''CODELKUP'' table. '
   END
END

--/********* Get Orders Table data  *********/
IF (@n_continue = 1  OR @n_continue = 2)
BEGIN

   SELECT @c_AllColumns = COALESCE(@c_AllColumns + ', ' , '' ) + CONVERT(NVARCHAR(25),RTRIM(LTRIM([Long])))
   FROM @temp_CodelkupTable
      
   SELECT @c_AllColumns = Stuff(@c_AllColumns,1,1,'')

   DECLARE CUR_READ_Temp_Column CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT [long] 
   FROM @temp_CodelkupTable
   ORDER BY [Code] ASC

   OPEN CUR_READ_Temp_Column
   FETCH NEXT FROM CUR_READ_Temp_Column INTO @c_ColumnName

   WHILE (@@FETCH_STATUS <> -1)
   BEGIN      
      IF @c_WhereColumn = ''
      BEGIN
         SET @c_WhereColumn = 'ISNULL(RTRIM(LTRIM(#Temp_Orders.'+@c_ColumnName+')),'''')=ISNULL(RTRIM(LTRIM(#Temp_CombOrders.'+@c_ColumnName+')),'''') '
      END
      ELSE
      BEGIN
         SET @c_WhereColumn = @c_WhereColumn +'AND ISNULL(RTRIM(LTRIM(#Temp_Orders.'+@c_ColumnName+')),'''')=ISNULL(RTRIM(LTRIM(#Temp_CombOrders.'+@c_ColumnName+')),'''') '
      END

      FETCH NEXT FROM CUR_READ_Temp_Column INTO @c_ColumnName
   END
   CLOSE CUR_READ_Temp_Column
   DEALLOCATE CUR_READ_Temp_Column
                                                            --(row_no = 0 for non-combinable orders)
   SET @c_ExecSttmt = N'SELECT OrderKey, '+@c_AllColumns+',ExternOrderKey, M_Company, [Row_No] = 0 ' 
                      +'INTO #Temp_Orders '
                      +'FROM ORDERS (NOLOCK) '
                      +'WHERE StorerKey = @c_StorerKey '
                      +'AND Status = ''0'' AND SOStatus=''PENDCOMB'' '
   SET @c_ExecSttmt = @c_ExecSttmt
                      +'SELECT '+@c_AllColumns+ ', ROW_NUMBER() OVER (ORDER BY ' +@c_AllColumns+') AS [Row_No]'
                      +'INTO #Temp_CombOrders '             --(search for combinable orders and set its row_no)
                      +'FROM #Temp_Orders '
                      +'GROUP BY '+@c_AllColumns+' '
                      +'HAVING COUNT(1) >1 '
   SET @c_ExecSttmt = @c_ExecSttmt
                      +'UPDATE #Temp_Orders '      --(update row_no <> 0 for combinable orders)
                      +'SET #Temp_Orders.[Row_No] = #Temp_CombOrders.[Row_No] '
                      +'FROM #Temp_Orders INNER JOIN #Temp_CombOrders  '
                      +'ON ( '+ @c_WhereColumn + ') '
   SET @c_ExecSttmt = @c_ExecSttmt
                      +'SELECT OrderKey, ExternOrderKey, M_Company, [Row_No], [C_State] from #Temp_Orders  ' --(jay03)
                      +'ORDER BY [Row_No] ' 

   SET @c_ExecArgSttmt = N'@c_AllColumns NVARCHAR(4000), '
                         +'@c_StorerKey  NVARCHAR(15), '
                         +'@c_WhereColumn NVARCHAR(4000)'

   IF(@b_debug = 1 )
   BEGIN
      SELECT @c_ExecSttmt AS 'TempOrd_Insert'
      SELECT @c_ExecArgSttmt AS 'TempOrd_Insert_Arg'
   END

   INSERT INTO #Temp_FinalOrders
   EXECUTE sp_executesql @c_ExecSttmt, @c_ExecArgSttmt, @c_AllColumns, @c_StorerKey,@c_WhereColumn

   IF(@b_debug = 1 )
   BEGIN
      SELECT COUNT(1) AS 'Number of Record in #Temp_Orders' FROM #Temp_FinalOrders
      SELECT * FROM #Temp_FinalOrders
   END

   IF NOT EXISTS (SELECT 1 FROM #Temp_FinalOrders)
   BEGIN
      SET @n_continue = 3

      IF (@b_debug = 1)
      BEGIN
         SELECT 'No orders in #Temp_FinalOrders' AS [debug_#Temp_FinalOrders]
      END
   END
END

/****************** Update  for Non-Combine Orders **********************/
IF (@n_continue = 1  OR @n_continue = 2)
BEGIN

   IF EXISTS (SELECT 1 FROM #Temp_FinalOrders WHERE [Row_No] = 0 )
   BEGIN
      DECLARE CUR_READ_NonCombineOrders CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT [OrderKey] 
      FROM #Temp_FinalOrders 
      WHERE [Row_No] = 0 

      OPEN CUR_READ_NonCombineOrders
      FETCH NEXT FROM CUR_READ_NonCombineOrders INTO @c_OrderKey

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
      
         UPDATE [dbo].[ORDERS] WITH (ROWLOCK)
         SET [SOStatus]   = '0'
            ,TrafficCop = NULL
            ,EditDate = GETDATE()
            ,EditWho = SUSER_SNAME()
         WHERE [OrderKey] = @c_OrderKey

         FETCH NEXT FROM CUR_READ_NonCombineOrders INTO @c_OrderKey
      END
      CLOSE CUR_READ_NonCombineOrders
      DEALLOCATE CUR_READ_NonCombineOrders

   END
END

/****************** Update/Locate/Combine  for Combinable Orders **********************/
IF (@n_continue = 1  OR @n_continue = 2)
BEGIN
   
   IF (@b_debug =1) 
   BEGIN
      SELECT 'Updating combinable orders'
   END
   
   DECLARE CUR_READ_CombineOrders CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT A.[Row_No] , MIN(A.[C_State] )
   FROM #Temp_FinalOrders A
   WHERE A.[Row_No] > 0
   GROUP BY A.[Row_No] 
   ORDER BY A.[Row_No] ASC

   OPEN CUR_READ_CombineOrders
   FETCH NEXT FROM CUR_READ_CombineOrders INTO @n_Row_No, @c_CState

   WHILE (@@FETCH_STATUS <> -1)
   BEGIN -- 1st cursor (Row_no)
      BEGIN TRAN

      SELECT @n_TotOpenQty = 0, @n_TotInvoiceAmount = 0, @n_TotUserdefine01 = 0, @n_TotUserdefine05 = 0
      SELECT @c_STOP_short = '' , @c_STOP_code = '', @c_STOP = ''

      SELECT @c_STOP_short = [Short], @c_STOP_code = [Code] 
      FROM #temp_CodelkupStopList
      WHERE Code = @c_CState

      IF ISNULL(RTRIM(@c_STOP_short) , '') = ''
         SET @c_STOP_short = ''

      IF ISNULL(RTRIM(@c_STOP_code) , '') = ''
         SET @c_STOP_code = ''

      IF (@c_STOP_short = 'HK')
      BEGIN
         SET @c_STOP = 'H-'
      END
      ELSE IF (@c_STOP_short = 'TW')
      BEGIN
         SET @c_STOP = 'T-'
      END
      ELSE
      BEGIN
         SET @c_STOP = 'C-'
      END
            
      IF (@c_STOP_short <> '') AND (@c_STOP_code <> '')
      BEGIN
         SET @c_STOP = @c_STOP + 'N-'
      END
      ELSE
      BEGIN
         SET @c_STOP = @c_STOP + 'M-'
      END

      SET @c_STOP = @c_STOP + 'N'
       
      IF(@n_continue= 1 OR @n_continue =2)
      BEGIN
         SELECT @c_NewOrderkey=''
         SELECT @b_success=1
         EXECUTE nspg_getkey
         'Order'
         ,10
         , @c_NewOrderkey OUTPUT
         , @b_success OUTPUT
         , @n_err OUTPUT
         , @c_errmsg OUTPUT
      END
      IF NOT (@b_success=1)
      BEGIN
         SELECT @n_continue=3
         SET @c_errmsg = N'FAIL MERGING. Unable to acquired new orderkey.'
         GOTO EXIT_SP
      END
       
      IF(@b_debug = 1)
      BEGIN
         SELECT @c_STOP AS 'STOP field value', @c_NewOrderkey AS 'NEW orderkey'
      END
      SET @c_OrderKey = ''
	  SET @n_Notes2 = ''

	  IF NOT EXISTS (SELECT 1 FROM SYSOBJECTS WHERE NAME='#M_COMPANY')
	  BEGIN
	  CREATE TABLE #M_COMPANY(M_COMPANY NVARCHAR(45))
	  END
	  
	  INSERT INTO #M_COMPANY 
	  SELECT DISTINCT(O.M_COMPANY) FROM ORDERS O WITH (NOLOCK) 
      JOIN  #Temp_FinalOrders B ON B.ORDERKEY = O.ORDERKEY
	  WHERE B.Row_no = @n_Row_No

	  DECLARE M_CUR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	  SELECT M_COMPANY FROM #M_COMPANY 
	  OPEN M_CUR FETCH NEXT FROM M_CUR INTO @c_M_Company
	  WHILE @@FETCH_STATUS<>-1
		BEGIN
			IF ISNULL(@n_Notes2,'') = ''
				BEGIN
				SET @n_Notes2 = @c_M_Company
				END
			ELSE
				BEGIN
				SET @n_Notes2 = @n_Notes2 + ',' + @c_M_Company
				END

		--SET @n_Notes2 = (CASE WHEN ISNULL(@n_Notes2,'')='' THEN @c_M_Company ELSE @n_Notes2 + ',' + @c_M_Company END )
		FETCH NEXT FROM M_CUR INTO @c_M_Company
		END
		CLOSE M_CUR
	  DEALLOCATE M_CUR

	  BEGIN
	  DROP TABLE #M_COMPANY
	  END

      SELECT @c_OrderKey = MIN(O.Orderkey),  -- for copy Order data from this Orders
             @n_TotOpenQty = SUM(OpenQty), 
             @n_TotInvoiceAmount = SUM(InvoiceAmount), 
             @n_TotUserdefine01 =  SUM ( CASE WHEN ISNUMERIC(RTRIM(Userdefine01)) = 1 THEN CAST(Userdefine01 AS float) ELSE 0 END), 
             @n_TotUserdefine05 = SUM ( CASE WHEN ISNUMERIC(RTRIM(Userdefine05)) = 1 THEN CAST(Userdefine05 AS float) ELSE 0 END)  
      FROM ORDERS O WITH (NOLOCK) 
      JOIN  #Temp_FinalOrders B ON B.ORDERKEY = O.ORDERKEY
      WHERE B.Row_no = @n_Row_No 


      TRUNCATE TABLE #temp_OrderDetail
      IF @b_debug = 1
      BEGIN
      SELECT @c_NewOrderkey, 0 ,T1.[ExternOrderKey],T1.[ExternLineNo] 
      ,T1.[Sku],T1.[StorerKey],T1.[ManufacturerSku],T1.[RetailSku],T1.[AltSku],T1.[OriginalQty],T1.[OpenQty],0,0 
      ,[QtyPreAllocated],[QtyAllocated],[QtyPicked],[UOM],[PackKey],[PickCode],[CartonGroup],[Lot],[ID],[Facility] 
      ,'0',T1.[UnitPrice],T1.[Tax01],T1.[Tax02],T1.[ExtendedPrice],T1.[UpdateSource],T1.[Lottable01],T1.[Lottable02],T1.[Lottable03] 
      ,T1.[Lottable04],T1.[Lottable05],T1.[FreeGoodQty],T1.[GrossWeight],T1.[Capacity],T1.[QtyToProcess], T1.[MinShelfLife]
      ,T1.[UserDefine01],T1.[UserDefine02],T1.[UserDefine03],T1.[UserDefine04],T1.Orderkey,T2.Externorderkey,T2.M_Company 
      ,T1.[POkey],T1.[ExternPOKey],T1.[UserDefine10], T1.EnteredQTY ,T1.[OrderKey]    -- *
      ,T2.ExternOrderKey,T1.[OrderLineNumber],T1.[Lottable06],T1.[Lottable07],T1.[Lottable08],T1.[Lottable09],T1.[Lottable10] -- *
      ,T1.[Lottable11],T1.[Lottable12],T1.[Lottable13],T1.[Lottable14],T1.[Lottable15],T1.[Notes],T1.[Notes2] 
      , ROW_NUMBER() OVER (ORDER BY T1.OrderKey , T1.[OrderLineNumber]) AS [Row_No]
      FROM ORDERDETAIL T1 WITH (NOLOCK) 
      JOIN #Temp_FinalOrders T2 ON T2.OrderKey = T1.OrderKey
      WHERE T2.Row_no = @n_Row_No 
      ORDER BY T1.OrderKey , T1.[OrderLineNumber]
      END


      INSERT INTO #temp_OrderDetail( [OrderKey],[OrderLineNumber],[ExternOrderKey],[ExternLineNo] 
      ,[Sku],[StorerKey],[ManufacturerSku],[RetailSku],[AltSku],[OriginalQty],[OpenQty],[ShippedQty],[AdjustedQty] 
      ,[QtyPreAllocated],[QtyAllocated],[QtyPicked],[UOM],[PackKey],[PickCode],[CartonGroup],[Lot],[ID],[Facility] 
      ,[Status],[UnitPrice],[Tax01],[Tax02],[ExtendedPrice],[UpdateSource],[Lottable01],[Lottable02],[Lottable03] 
      ,[Lottable04],[Lottable05],AddDate   ,AddWho,[FreeGoodQty],[GrossWeight],[Capacity],[QtyToProcess],[MinShelfLife]
      ,[UserDefine01],[UserDefine02],[UserDefine03],[UserDefine04],[UserDefine05],[UserDefine06],[UserDefine07] 
      ,UserDefine08, UserDefine09,[POkey],[ExternPOKey],[UserDefine10], EnteredQTY ,[ConsoOrderKey] 
      ,[ExternConsoOrderKey],[ConsoOrderLineNo],[Lottable06],[Lottable07],[Lottable08],[Lottable09],[Lottable10] 
      ,[Lottable11],[Lottable12],[Lottable13],[Lottable14],[Lottable15],[Notes],[Notes2], ROW_NO )
      SELECT @c_NewOrderkey, 0 ,T1.[ExternOrderKey],T1.[ExternLineNo] 
      ,T1.[Sku],T1.[StorerKey],T1.[ManufacturerSku],T1.[RetailSku],T1.[AltSku],T1.[OriginalQty],T1.[OpenQty],0,0 
      ,[QtyPreAllocated],[QtyAllocated],[QtyPicked],[UOM],[PackKey],[PickCode],[CartonGroup],[Lot],[ID],[Facility] 
      ,'0',T1.[UnitPrice],T1.[Tax01],T1.[Tax02],T1.[ExtendedPrice],T1.[UpdateSource],T1.[Lottable01],T1.[Lottable02],T1.[Lottable03] 
      ,T1.[Lottable04],T1.[Lottable05],AddDate   ,AddWho,T1.[FreeGoodQty],T1.[GrossWeight],T1.[Capacity],T1.[QtyToProcess], T1.[MinShelfLife]
      ,T1.[UserDefine01],T1.[UserDefine02],T1.[UserDefine03],T1.[UserDefine04],T1.Orderkey,T2.Externorderkey,'' 
      ,'', '',T1.[POkey],T1.[ExternPOKey],T1.[UserDefine10], T1.EnteredQTY ,T1.[OrderKey]    -- *
      ,T2.ExternOrderKey,T1.[OrderLineNumber],T1.[Lottable06],T1.[Lottable07],T1.[Lottable08],T1.[Lottable09],T1.[Lottable10]  -- *
      ,T1.[Lottable11],T1.[Lottable12],T1.[Lottable13],T1.[Lottable14],T1.[Lottable15],T2.M_Company,T1.[Notes2] 
      , ROW_NUMBER() OVER (ORDER BY T1.OrderKey , T1.[OrderLineNumber]) AS [Row_No]
      FROM ORDERDETAIL T1 WITH (NOLOCK) 
      JOIN #Temp_FinalOrders T2 ON T2.OrderKey = T1.OrderKey
      WHERE T2.Row_no = @n_Row_No 
      ORDER BY T1.OrderKey , T1.[OrderLineNumber]
      IF @b_debug = 1
      BEGIN
         SELECT * FROM #temp_OrderDetail
      END

      IF NOT EXISTS(SELECT 1 FROM #temp_OrderDetail)
      BEGIN
         ROLLBACK TRAN
         SET @n_continue = 3
         SET @c_errmsg = N'FAIL MERGING. Unable to INSERT Child orderdetail into @temp_OrderDetail'
         GOTO EXIT_SP
      END
       
 
      SET @c_GetM_Company = ''

      DECLARE CUR_READ_Orderkey_CombineOrders CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT [OrderKey], [M_Company] 
      FROM #Temp_FinalOrders 
      WHERE [Row_No] = @n_Row_No
     
      OPEN CUR_READ_Orderkey_CombineOrders
      FETCH NEXT FROM  CUR_READ_Orderkey_CombineOrders INTO @c_OrderKey, @c_M_Company

      WHILE (@@FETCH_STATUS <>-1)
      BEGIN -- 2nd cursor (orderkey)
         
         UPDATE [dbo].[ORDERS] WITH (ROWLOCK)
         SET  POKey        = @c_NewOrderkey
            ,[SOStatus]    = 'HOLD'
            ,[OrderGroup]  = 'CHILD_ORD'
            ,TrafficCop  = NULL
            , EditDate = GETDATE()
            , EditWho = SUSER_SNAME()
         WHERE [OrderKey]  = @c_OrderKey

         UPDATE dbo.Orderdetail  
         SET ConsoOrderKey = @c_NewOrderkey,
            TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE Orderkey = @c_OrderKey 
          
         IF ISNULL(RTRIM(@c_M_Company) , '') = ''
            SET @c_M_Company = ''

         IF @c_M_Company <> ''
         BEGIN
            IF @c_GetM_Company = ''
            BEGIN
               SET @c_GetM_Company = @c_M_Company
            END
            ELSE
            BEGIN
               SET @c_GetM_Company = @c_GetM_Company + ',' + @c_M_Company
            END
         END
          
         IF(@b_debug = 1)
         BEGIN 
            SELECT  @c_GetM_Company AS 'GetM_Company'
         END
          
         FETCH NEXT FROM CUR_READ_Orderkey_CombineOrders INTO @c_OrderKey, @c_M_Company
      END -- 2nd cursor (orderkey)
      CLOSE CUR_READ_Orderkey_CombineOrders
      DEALLOCATE CUR_READ_Orderkey_CombineOrders

      INSERT INTO ORDERS ([OrderKey],[StorerKey], [ExternOrderKey], [OrderDate], [DeliveryDate], [Priority], 
      [ConsigneeKey], [C_Contact1], [C_Contact2], [C_Company],[C_Address1], [C_Address2], [C_Address3], [C_Address4], 
      [C_City], [C_State], [C_Zip],C_Country,C_ISOCntryCode,[C_Phone1], [C_Phone2], C_Fax1,C_Fax2,C_vat,[BuyerPO], 
      BillToKey, B_contact1,B_Contact2,B_Company,B_Address1,B_Address2,B_Address3,B_Address4,B_City,B_State,B_Zip,
      B_Country,B_ISOCntryCode,B_Phone1,B_Phone2,B_Fax1,B_Fax2,B_Vat,IncoTerm,
      [PmtTerm], [OpenQty], [Status],DischargePlace,DeliveryPlace,IntermodalVehicle,CountryOfOrigin,CountryDestination,
      UpdateSource, [Type], [OrderGroup], [Stop], Notes, AddDate, AddWho, ContainerType, ContainerQty, [SOSTATUS], 
      [InvoiceAmount], [Salesman], [Notes2],SectionKey, [Facility], LabelPrice, [UserDefine01], [UserDefine03], [UserDefine05], 
      [UserDefine08], Issued, DeliveryNote, [SpecialHandling], [RoutingTool], M_Contact1 ,M_Contact2, [M_Company], 
      M_Address1,M_Address2,M_Address3,M_Address4,M_City,M_State,M_Zip,M_Country,M_ISOCntryCode,M_Phone1,M_Phone2,M_Fax1,
      M_Fax2,M_vat, [ShipperKey], [DocType]) 
      SELECT  @c_NewOrderkey, Storerkey, @c_NewOrderkey, OrderDate, DeliveryDate, [Priority], 
      ConsigneeKey, C_contact1, C_Contact2, C_Company, C_Address1, C_Address2, C_Address3, C_Address4, 
      C_City, C_State, C_Zip,C_Country, C_ISOCntryCode,C_Phone1,C_Phone2, C_Fax1,C_Fax2,C_vat, BuyerPO, 
      '','','','','','','','','','','','','','','','','','','',
      PmtTerm, @n_TotOpenQty, '0','','','','','','', [Type], 'COM_ORDER',@c_STOP,'', AddDate, AddWho, '',0, 0,  
      @n_TotInvoiceAmount, Salesman, @n_Notes2/*[Notes2]*/, '',Facility, '', CAST(@n_TotUserdefine01 AS Nvarchar), 
      Userdefine03, CAST(@n_TotUserdefine05 AS Nvarchar), UserDefine08, '','', SpecialHandling, RoutingTool, '','', ''/*[M_Company]*/, 
      '','','','','','','','','','','','','','', ShipperKey, DocType 
      FROM ORDERS WITH (NOLOCK) 
      WHERE ORDERKEY = @c_OrderKey   -- top 1 for copy order infor

      IF EXISTS ( SELECT 1 FROM #temp_OrderDetail )
      AND EXISTS ( SELECT 1 FROM ORDERS (NOLOCK) WHERE orderkey = @c_NewOrderkey )
      BEGIN
         --INSERT INTO dbo.ORDERDETAIL
         INSERT INTO dbo.ORDERDETAIL ( [OrderKey],[OrderLineNumber],[ExternOrderKey],[ExternLineNo] 
         ,[Sku],[StorerKey],[ManufacturerSku],[RetailSku],[AltSku],[OriginalQty],[OpenQty],[ShippedQty],[AdjustedQty] 
         ,[QtyPreAllocated],[QtyAllocated],[QtyPicked],[UOM],[PackKey],[PickCode],[CartonGroup],[Lot],[ID],[Facility] 
         ,[Status],[UnitPrice],[Tax01],[Tax02],[ExtendedPrice],[UpdateSource],[Lottable01],[Lottable02],[Lottable03] 
         ,[Lottable04],[Lottable05],AddDate   ,AddWho,[FreeGoodQty],[GrossWeight],[Capacity],[QtyToProcess],[MinShelfLife]
         ,[UserDefine01],[UserDefine02],[UserDefine03],[UserDefine04],[UserDefine05],[UserDefine06],[UserDefine07] 
         ,UserDefine08, UserDefine09,[POkey],[ExternPOKey],[UserDefine10], EnteredQTY ,[ConsoOrderKey] 
         ,[ExternConsoOrderKey],[ConsoOrderLineNo],[Lottable06],[Lottable07],[Lottable08],[Lottable09],[Lottable10] 
         ,[Lottable11],[Lottable12],[Lottable13],[Lottable14],[Lottable15],[Notes],[Notes2])
         SELECT [OrderKey], RIGHT('00000' + CAST(ROW_NO AS varchar), 5) ,[ExternOrderKey],[ExternLineNo] 
         ,[Sku],[StorerKey],[ManufacturerSku],[RetailSku],[AltSku],[OriginalQty],[OpenQty],[ShippedQty],[AdjustedQty] 
         ,[QtyPreAllocated],[QtyAllocated],[QtyPicked],[UOM],[PackKey],[PickCode],[CartonGroup],[Lot],[ID],[Facility] 
         ,[Status],[UnitPrice],[Tax01],[Tax02],[ExtendedPrice],[UpdateSource],[Lottable01],[Lottable02],[Lottable03] 
         ,[Lottable04],[Lottable05],AddDate   ,AddWho,[FreeGoodQty],[GrossWeight],[Capacity],[QtyToProcess],[MinShelfLife]
         ,[UserDefine01],[UserDefine02],[UserDefine03],[UserDefine04],[UserDefine05],[UserDefine06],[UserDefine07] 
         ,UserDefine08, UserDefine09,[POkey],[ExternPOKey],[UserDefine10], EnteredQTY ,[ConsoOrderKey] 
         ,[ExternConsoOrderKey],[ConsoOrderLineNo],[Lottable06],[Lottable07],[Lottable08],[Lottable09],[Lottable10] 
         ,[Lottable11],[Lottable12],[Lottable13],[Lottable14],[Lottable15],[Notes],[Notes2] 
         FROM #temp_OrderDetail
         ORDER BY ROW_NO 

         IF @@ROWCOUNT = 0 OR @@ERROR <> 0
         BEGIN
            ROLLBACK TRAN
            SET @n_continue =3 
            SET @c_errmsg = N'FAIL MERGING, Unable to insert parent orders orderdetail.'
            GOTO EXIT_SP
         END
      END 

      COMMIT TRAN

      FETCH NEXT FROM CUR_READ_CombineOrders INTO @n_Row_No, @c_CState
   END -- 1st cursor (Row_no)
   CLOSE CUR_READ_CombineOrders
   DEALLOCATE CUR_READ_CombineOrders


EXIT_SP:  
      
   IF @n_Continue=3  -- Error Occured - Process And Return      
   BEGIN      
      SELECT @b_Success = 0      
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt      
      BEGIN      
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartTCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END      
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_OrdersMerging'      
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012      
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartTCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END   
END
/*
 
SELECT @c_Orderkey=''
SELECT @b_success=1
EXECUTE nspg_getkey
'Order'
,10
, @c_Orderkey OUTPUT
, @b_success OUTPUT
, @n_err OUTPUT
, @c_errmsg OUTPUT
   
IF NOT @b_success=1
BEGIN
SELECT @n_continue=3
END


*/

END
GO
GRANT EXECUTE ON [dbo].[isp_OrdersMerging] TO nSQL 
GO
