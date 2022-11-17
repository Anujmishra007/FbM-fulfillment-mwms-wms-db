SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************/  
/* Stored Procedure: lsp_Validate_ReceiptDetail_Std                      */  
/* Creation Date: 18-JAN-2019                                            */  
/* Copyright: LFL                                                        */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose:                                                              */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/*                                                                       */  
/* Version: 1.5                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 2020-12-04  Wan01    1.1   LFWM-2410 - UAT  Philippines  PH SCE No    */
/*                            Prompt For Entering Expired Stocks         */
/* 2021-02-25  Wan02    1.2   Add Big Outer Try/Catch                    */  
/*                            -Fix Error Msg and Error #                 */  
/* 2021-04-25  Wan03    1.3   LFWM-3505 Storerconfig:                    */
/*                            DisAllowDuplicateIdsOnWSRcpt SCE Enhancement*/
/* 2022-09-19  Wan04    1.4   LFWM-3760 - PH - SCE Returns Validation Allow*/
/*                            Duplicate ID                                */
/* 2022-10-13  Wan05    1.5   LFWM-3780 - PH Unilever                    */
/*                            DisAllowDuplicateIdsOnWSRcpt StorerCFG CR  */
/*************************************************************************/   
CREATE OR ALTER PROC [WM].[lsp_Validate_ReceiptDetail_Std] (
  @c_XMLSchemaString    NVARCHAR(MAX) 
, @c_XMLDataString      NVARCHAR(MAX) 
, @b_Success            INT           OUTPUT
, @n_Err                INT           OUTPUT
, @c_ErrMsg             NVARCHAR(250) OUTPUT
, @n_WarningNo          INT = 0       OUTPUT
, @c_ProceedWithWarning CHAR(1) = 'N'
, @c_IsSupervisor       CHAR(1) = 'N' 
, @c_XMLDataString_Prev NVARCHAR(MAX) = ''
) AS 
BEGIN
   SET ANSI_NULLS ON
   SET ANSI_PADDING ON
   SET ANSI_WARNINGS ON   
   SET QUOTED_IDENTIFIER ON
   SET CONCAT_NULL_YIELDS_NULL ON
   SET ARITHABORT ON
  
   DECLARE     
      @x_XMLSchema         XML
   ,  @x_XMLData           XML 
   ,  @c_TableColumns      NVARCHAR(MAX) = N''
   ,  @c_ColumnName        NVARCHAR(128) = N''
   ,  @c_DataType          NVARCHAR(128) = N''
   ,  @c_TableName         NVARCHAR(30)  = N''
   ,  @c_SQL               NVARCHAR(MAX) = N''
   ,  @c_SQLSchema         NVARCHAR(MAX) = N''
   ,  @c_SQLData           NVARCHAR(MAX) = N''   
   ,  @n_Continue          INT = 1 

   ,  @n_Cnt               INT = 0

   -- (Wan01) - START
   ,  @n_RowCnt            INT = 0

   ,  @c_Sku               NVARCHAR(20) = ''
   ,  @c_LottableLabel     NVARCHAR(20) = ''
   ,  @c_Lottable01Label   NVARCHAR(20) = ''
   ,  @c_Lottable02Label   NVARCHAR(20) = ''
   ,  @c_Lottable03Label   NVARCHAR(20) = ''
   ,  @c_Lottable04Label   NVARCHAR(20) = ''
   ,  @c_Lottable05Label   NVARCHAR(20) = ''
   ,  @c_Lottable06Label   NVARCHAR(20) = ''
   ,  @c_Lottable07Label   NVARCHAR(20) = ''
   ,  @c_Lottable08Label   NVARCHAR(20) = ''
   ,  @c_Lottable09Label   NVARCHAR(20) = ''
   ,  @c_Lottable10Label   NVARCHAR(20) = ''
   ,  @c_Lottable11Label   NVARCHAR(20) = ''
   ,  @c_Lottable12Label   NVARCHAR(20) = ''
   ,  @c_Lottable13Label   NVARCHAR(20) = ''
   ,  @c_Lottable14Label   NVARCHAR(20) = ''
   ,  @c_Lottable15Label   NVARCHAR(20) = ''
   ,  @c_LottableValue     NVARCHAR(30) = ''
   ,  @c_Lottable01        NVARCHAR(18) = ''
   ,  @c_Lottable02        NVARCHAR(18) = ''
   ,  @c_Lottable03        NVARCHAR(18) = ''
   ,  @dt_Lottable04       DATETIME 
   ,  @dt_Lottable05       DATETIME 
   ,  @c_Lottable06        NVARCHAR(30) = ''
   ,  @c_Lottable07        NVARCHAR(30) = ''
   ,  @c_Lottable08        NVARCHAR(30) = ''
   ,  @c_Lottable09        NVARCHAR(30) = ''
   ,  @c_Lottable10        NVARCHAR(30) = ''
   ,  @c_Lottable11        NVARCHAR(30) = ''
   ,  @c_Lottable12        NVARCHAR(30) = ''
   ,  @dt_Lottable13       DATETIME
   ,  @dt_Lottable14       DATETIME
   ,  @dt_Lottable15       DATETIME

   ,  @n_ExistsCnt         INT          = 1
   ,  @c_Cnt               NVARCHAR(2)  = ''

   ,  @c_CNNikeITF         NVARCHAR(30) = ''
   ,  @c_VLDLotLabelExist  NVARCHAR(30) = ''
   -- (Wan01) - END

   --(Wan02) - START
   BEGIN TRY
      IF OBJECT_ID('tempdb..#RECEIPTDETAIL') IS NOT NULL
      BEGIN
         DROP TABLE #RECEIPTDETAIL
      END

      CREATE TABLE #RECEIPTDETAIL( Rowid  INT NOT NULL IDENTITY(1,1) )   

      SET @x_XMLSchema = CONVERT(XML, @c_XMLSchemaString)
      SET @x_XMLData = CONVERT(XML, @c_XMLDataString)

      DECLARE CUR_SCHEMA CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT x.value('@ColName', 'NVARCHAR(128)') AS columnname
            ,x.value('@DataType','NVARCHAR(128)') AS datatype
      FROM @x_XMLSchema.nodes('/Table/Column') TempXML (x)
         
      OPEN CUR_SCHEMA

      FETCH NEXT FROM CUR_SCHEMA INTO @c_ColumnName, @c_DataType

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @c_TableName = ''
         IF CHARINDEX('.', @c_ColumnName) > 0 
         BEGIN
            SET @c_TableName  = LEFT(@c_ColumnName, CHARINDEX('.', @c_ColumnName))
            SET @c_ColumnName = RIGHT(@c_ColumnName, LEN(@c_ColumnName) -LEN(@c_TableName))
         END

         SET @c_SQLSchema  = @c_SQLSchema + @c_ColumnName + ' ' + @c_DataType + ' NULL, '
         SET @c_TableColumns = @c_TableColumns + @c_ColumnName + ', '
         SET @c_SQLData = @c_SQLData + 'x.value(''@' + @c_TableName + @c_ColumnName + ''', ''' + @c_DataType + ''') AS ['  + @c_ColumnName + '], '
            
         FETCH NEXT FROM CUR_SCHEMA INTO @c_ColumnName, @c_DataType
      END
      CLOSE CUR_SCHEMA
      DEALLOCATE CUR_SCHEMA
          
          
      IF LEN(@c_SQLSchema) > 0 
      BEGIN
         SET @c_SQL = N'ALTER TABLE #RECEIPTDETAIL  ADD  ' + SUBSTRING(@c_SQLSchema, 1, LEN(@c_SQLSchema) - 1) + ' '
            
         EXEC (@c_SQL)

         SET @c_SQL = N' INSERT INTO #RECEIPTDETAIL' --+  @c_UpdateTable 
                     + ' ( ' + SUBSTRING(@c_TableColumns, 1, LEN(@c_TableColumns) - 1) + ' )'
                     + ' SELECT ' + SUBSTRING(@c_SQLData, 1, LEN(@c_SQLData) - 1) 
                     + ' FROM @x_XMLData.nodes(''Row'') TempXML (x) '  
            
         EXEC sp_executeSQl @c_SQL
                           , N'@x_XMLData xml'
                           , @x_XMLData
         
      END

      DECLARE 
            @c_ReceiptKey                    NVARCHAR(10) = ''
         ,  @c_ReceiptLineNo                 NVARCHAR(5)  = ''
         ,  @c_Facility                      NVARCHAR(5)  = ''
         ,  @c_Facility_LOC                  NVARCHAR(5)  = ''
         ,  @c_Storerkey                     NVARCHAR(15) = ''
         ,  @c_ToLoc                         NVARCHAR(10) = ''
         
         ,  @c_ToID                          NVARCHAR(18) = ''             --(Wan03)
         ,  @c_DocType                       NVARCHAR(1)  = ''             --(Wan04)
      
         ,  @c_DisAllowDuplicateIdsOnWSRcpt  NVARCHAR(30) = '0'            --(Wan03)
         ,  @c_DisAllowDupIDsOnWSRcpt_Option5 NVARCHAR(1000) = ''          --(Wan04)
         ,  @c_UniqueIDSkipDocType           NVARCHAR(30) = ''             --(Wan04)
         
         ,  @c_AllowDupWithinPLTCnt          NVARCHAR(30) = 'N'            --(Wan05)
         ,  @n_BeforeReceivedQty             FLOAT        = 0.00           --(Wan05)
         ,  @b_ValidID                       INT          = 0              --(Wan05)  

      SELECT TOP 1 
            @c_ReceiptKey   = RD.ReceiptKey
         ,  @c_ReceiptLineNo= RD.ReceiptLineNumber
         ,  @c_Storerkey    = RD.Storerkey
         ,  @c_Sku          = RD.Sku            --(Wan01)
         ,  @c_ToLoc        = RTRIM(RD.ToLoc)
         ,  @c_Lottable01   = RD.Lottable01     --(Wan01)
         ,  @c_Lottable02   = RD.Lottable02     --(Wan01)
         ,  @c_Lottable03   = RD.Lottable03     --(Wan01)
         ,  @dt_Lottable04  = RD.Lottable04     --(Wan01)
         ,  @dt_Lottable05  = RD.Lottable05     --(Wan01)
         ,  @c_Lottable06   = RD.Lottable06     --(Wan01)
         ,  @c_Lottable07   = RD.Lottable07     --(Wan01)
         ,  @c_Lottable08   = RD.Lottable08     --(Wan01)
         ,  @c_Lottable09   = RD.Lottable09     --(Wan01)
         ,  @c_Lottable10   = RD.Lottable10     --(Wan01)
         ,  @c_Lottable11   = RD.Lottable11     --(Wan01)
         ,  @c_Lottable12   = RD.Lottable12     --(Wan01)
         ,  @dt_Lottable13  = RD.Lottable13     --(Wan01)
         ,  @dt_Lottable14  = RD.Lottable14     --(Wan01)
         ,  @dt_Lottable15  = RD.Lottable15     --(Wan01)
         ,  @c_ToID          = ISNULL(RD.ToID,'')              --(Wan03)
         ,  @n_BeforeReceivedQty = RD.BeforeReceivedQty        --(Wan05)
      FROM  #RECEIPTDETAIL RD  

      SELECT TOP 1 
            @c_Facility = RTRIM(R.Facility)
         ,  @c_DocType  = TRIM(R.DOCTYPE)                --(Wan04) 
      FROM  RECEIPT R WITH (NOLOCK) 
      WHERE R.ReceiptKey = @c_ReceiptKey 

      IF @c_ToLoc <> ''
      BEGIN
         SELECT @n_Cnt = 1
            ,   @c_Facility_LOC = L.Facility  
         FROM LOC L WITH (NOLOCK) 
         WHERE L.Loc = @c_ToLoc  

         IF @n_Cnt = 0
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 555251
            SET @c_errmsg =  'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Invalid Loc: ' + @c_ToLoc + '. (lsp_Validate_ReceiptDetail_Std)'
                          + ' |' + @c_ToLoc 
            GOTO EXIT_SP
         END


         IF @c_Facility_LOC <> @c_Facility AND @c_Facility <> ''
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 555252
            SET @c_errmsg =  'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Loc: ' + @c_ToLoc + ' does not belong to facility: ' + @c_Facility + '. (lsp_Validate_ReceiptDetail_Std)'
                          + ' |' + @c_ToLoc + '|' + @c_Facility
            GOTO EXIT_SP
         END
      END

      --(Wan01) - START
      SELECT @c_Lottable01Label = ISNULL(RTRIM(Lottable01Label),'')
           , @c_Lottable02Label = ISNULL(RTRIM(Lottable02Label),'')
           , @c_Lottable03Label = ISNULL(RTRIM(Lottable03Label),'')
           , @c_Lottable04Label = ISNULL(RTRIM(Lottable04Label),'')
           , @c_Lottable05Label = ISNULL(RTRIM(Lottable05Label),'')
           , @c_Lottable06Label = ISNULL(RTRIM(Lottable06Label),'')
           , @c_Lottable07Label = ISNULL(RTRIM(Lottable07Label),'')
           , @c_Lottable08Label = ISNULL(RTRIM(Lottable08Label),'')
           , @c_Lottable09Label = ISNULL(RTRIM(Lottable09Label),'')
           , @c_Lottable10Label = ISNULL(RTRIM(Lottable10Label),'')
           , @c_Lottable11Label = ISNULL(RTRIM(Lottable11Label),'')
           , @c_Lottable12Label = ISNULL(RTRIM(Lottable12Label),'')
           , @c_Lottable13Label = ISNULL(RTRIM(Lottable13Label),'')
           , @c_Lottable14Label = ISNULL(RTRIM(Lottable14Label),'')
           , @c_Lottable15Label = ISNULL(RTRIM(Lottable15Label),'')
      FROM SKU S WITH (NOLOCK)
      WHERE S.Storerkey = @c_Storerkey
      AND S.Sku = @c_Sku

      SELECT @c_CNNikeITF        = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'CNNikeITF')
      SELECT @c_VLDLotLabelExist = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'ValidateLotLabelExist')

      SET @n_Cnt = 1
      WHILE @n_Cnt <= 15
      BEGIN
         SET @c_LottableValue= CASE @n_Cnt WHEN 1  THEN @c_Lottable01
                                           WHEN 2  THEN @c_Lottable02
                                           WHEN 3  THEN @c_Lottable03
                                           WHEN 4  THEN CONVERT(NVARCHAR(10), @dt_Lottable04, 112)
                                           WHEN 5  THEN CONVERT(NVARCHAR(10), @dt_Lottable05, 112)
                                           WHEN 6  THEN @c_Lottable06
                                           WHEN 7  THEN @c_Lottable07
                                           WHEN 8  THEN @c_Lottable08
                                           WHEN 9  THEN @c_Lottable09
                                           WHEN 10 THEN @c_Lottable10
                                           WHEN 11 THEN @c_Lottable11
                                           WHEN 12 THEN @c_Lottable12
                                           WHEN 13 THEN CONVERT(NVARCHAR(10), @dt_Lottable13, 112)
                                           WHEN 14 THEN CONVERT(NVARCHAR(10), @dt_Lottable14, 112)
                                           WHEN 15 THEN CONVERT(NVARCHAR(10), @dt_Lottable15, 112)
                                           END
         
         SET @c_LottableLabel= CASE @n_Cnt WHEN 1  THEN @c_Lottable01Label
                                           WHEN 2  THEN @c_Lottable02Label
                                           WHEN 3  THEN @c_Lottable03Label
                                           WHEN 4  THEN @c_Lottable04Label
                                           WHEN 5  THEN @c_Lottable05Label
                                           WHEN 6  THEN @c_Lottable06Label
                                           WHEN 7  THEN @c_Lottable07Label
                                           WHEN 8  THEN @c_Lottable08Label
                                           WHEN 9  THEN @c_Lottable09Label
                                           WHEN 10 THEN @c_Lottable10Label
                                           WHEN 11 THEN @c_Lottable11Label
                                           WHEN 12 THEN @c_Lottable12Label
                                           WHEN 13 THEN @c_Lottable13Label
                                           WHEN 14 THEN @c_Lottable14Label
                                           WHEN 15 THEN @c_Lottable15Label
                                           END

         SET @c_Cnt = RIGHT('00' + CONVERT(NVARCHAR(2), @n_Cnt),2)                                       
         IF @n_Cnt = 3 
         BEGIN
            IF @c_LottableLabel = 'LOGL_WHSE'
            BEGIN
               SET @n_RowCnt = 0
               IF @c_LottableLabel <> ''
               BEGIN
                  SELECT TOP 1 @n_RowCnt = 1
                  FROM CODELKUP CL WITH (NOLOCK)
                  WHERE CL.ListName = 'LOGICALWH'
                  AND CL.Code = @c_LottableValue
               END

               IF @n_RowCnt = 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err = 555253
                  SET @c_errmsg =  'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Lottable' + @c_Cnt + '. Invalid Logical Warehouse Value: ' + @c_LottableValue + '. (lsp_Validate_ReceiptDetail_Std)'
                                 + '|' + @c_Cnt + '|' + @c_LottableValue
                  GOTO EXIT_SP
               END
            END

            IF @c_CNNikeITF = '1' AND @c_LottableLabel = 'SUB-INV'
            BEGIN
               SET @n_RowCnt = 0
               IF @c_LottableLabel <> ''
               BEGIN
                  SET @n_RowCnt = 0
                  SELECT TOP 1 @n_RowCnt = 1
                  FROM CODELKUP CL WITH (NOLOCK)
                  WHERE CL.ListName = 'SUBINVCODE'
                  AND CL.Code = @c_LottableValue

                  IF @n_RowCnt = 0
                  BEGIN
                     SELECT TOP 1 @n_RowCnt = 1
                     FROM CODELKUP CL WITH (NOLOCK)
                     WHERE CL.ListName = 'BJSUBINV'
                     AND CL.Code = @c_LottableValue
                  END
               END

               IF @n_RowCnt = 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err = 555254
                  SET @c_errmsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Lottable' + @c_Cnt + '. Invalid Sub Inventory Code: ' + @c_LottableValue + '. (lsp_Validate_ReceiptDetail_Std)'
                                 + '|' + @c_Cnt + '|' + @c_LottableValue
                  GOTO EXIT_SP
               END
            END
         END

         IF @c_VLDLotLabelExist = '1' AND @c_LottableLabel = '' AND
            (
               ( @n_Cnt NOT IN (4,5,13,14,15) AND ISNULL(@c_LottableValue,'') <> '' ) OR
               ( @n_Cnt IN (4,5,13,14,15) AND ISNULL(@c_LottableValue,'') <> '19000101' )
            )
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 555255
            SET @c_errmsg =  'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Lottable' + @c_Cnt + '''s Label Not Yet Setup In SKU: ' + @c_Sku + '. Edit disallow. (lsp_Validate_ReceiptDetail_Std)'
                           + '|' + @c_Cnt + '|' + @c_Sku
            GOTO EXIT_SP
         END
         
         SET @n_Cnt = @n_Cnt + 1
      END 
      --(Wan01) - END
      
      --(Wan03) - START
      IF @c_ToID <> ''
      BEGIN
         --(Wan04) - START
         SELECT @c_DisAllowDuplicateIdsOnWSRcpt = fgr.Authority
               ,@c_DisAllowDupIDsOnWSRcpt_Option5 = fgr.Option5
         FROM dbo.fnc_GetRight2( @c_Facility, @c_Storerkey, '', 'DisAllowDuplicateIdsOnWSRcpt') AS fgr      
      
         SELECT @c_UniqueIDSkipDocType = dbo.fnc_GetParamValueFromString('@c_UniqueIDSkipDocType', @c_DisAllowDupIDsOnWSRcpt_Option5, @c_UniqueIDSkipDocType)
         IF @c_DisAllowDuplicateIdsOnWSRcpt = '1' AND CHARINDEX(@c_DocType, @c_UniqueIDSkipDocType, 1) > 0
         BEGIN 
            SET @c_DisAllowDuplicateIdsOnWSRcpt = '0'
         END
         --(Wan04) - END
         
         IF @c_DisAllowDuplicateIdsOnWSRcpt = '1'
         BEGIN
            --(Wan05) - START
            SET @c_AllowDupWithinPLTCnt = 'N'
            SELECT @c_AllowDupWithinPLTCnt = dbo.fnc_GetParamValueFromString('@c_AllowDupWithinPLTCnt', @c_DisAllowDupIDsOnWSRcpt_Option5, @c_AllowDupWithinPLTCnt)
            --(Wan05) - END
            
            IF @c_AllowDupWithinPLTCnt = 'N'                --(Wan05) 
            BEGIN
               IF EXISTS ( SELECT TOP 1 1 FROM dbo.ID AS i WITH (NOLOCK) WHERE ID = @c_ToID
                           UNION
                           SELECT TOP 1 1 FROM dbo.RECEIPTDETAIL AS r WITH (NOLOCK) WHERE r.Toid = @c_ToID AND r.FinalizeFlag = 'N'
                           AND r.ReceiptKey < @c_ReceiptKey
                           AND r.Storerkey = @c_Storerkey
                           UNION
                           SELECT TOP 1 1 FROM dbo.RECEIPTDETAIL AS r WITH (NOLOCK) WHERE r.Toid = @c_ToID AND r.FinalizeFlag = 'N'
                           AND r.ReceiptKey = @c_ReceiptKey AND r.ReceiptLineNumber <> @c_ReceiptLineNo
                           UNION
                           SELECT TOP 1 1 FROM dbo.RECEIPTDETAIL AS r WITH (NOLOCK) WHERE r.Toid = @c_ToID AND r.FinalizeFlag = 'N'
                           AND r.ReceiptKey > @c_ReceiptKey 
                           AND r.Storerkey = @c_Storerkey
                         )
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err = 555256
                  SET @c_errmsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Disallow duplicate Movable Unit Id. (lsp_Validate_ReceiptDetail_Std)'
                  GOTO EXIT_SP
               END
            END                                             --(Wan05) - START                                       
            ELSE
            BEGIN
               SET @b_ValidID = 1
               SELECT TOP 1 @b_ValidID = 0
               FROM dbo.RECEIPTDETAIL AS r WITH (NOLOCK)
               WHERE r.ReceiptKey <> @c_ReceiptKey
               AND r.ToID = @c_ToID
                           
               IF @b_ValidID = 1
               BEGIN
                  SELECT TOP 1 @b_ValidID = IIF(r.Sku <> @c_Sku OR SUM(r.BeforeReceivedQty + @n_BeforeReceivedQty) > p.Pallet, 0, 1)
                  FROM dbo.RECEIPTDETAIL AS r WITH (NOLOCK)
                  JOIN dbo.SKU AS s WITH (NOLOCK) ON s.StorerKey = r.StorerKey AND s.Sku = r.Sku
                  JOIN dbo.PACK AS p WITH (NOLOCK) ON s.PackKey = p.PackKey
                  WHERE r.ReceiptKey = @c_ReceiptKey
                  AND r.ToID = @c_ToID
                  GROUP BY r.Sku, r.ToId, p.Pallet 
                  ORDER BY IIF(r.Sku <> @c_Sku OR SUM(r.BeforeReceivedQty + @n_BeforeReceivedQty) > p.Pallet, 0, 1)
               END 
               
               IF @b_ValidID = 1
               BEGIN
                  -- Last & Further check if the Received ID is archived with inventory 
                  SELECT TOP 1 @b_ValidID = 0
                  FROM dbo.RECEIPTDETAIL AS r WITH (NOLOCK)
                  WHERE r.ReceiptKey = @c_ReceiptKey
                  AND r.ToID = @c_ToID
                  AND EXISTS (SELECT 1 FROM dbo.LOTxLOCxID AS ltlci WITH (NOLOCK)
                              WHERE ltlci.ID = r.ToId
                              AND ltlci.Qty + ltlci.PendingMoveIN > 0
                              )    
                  GROUP BY r.ToId
                  HAVING MAX(r.FinalizeFlag) = 'N' 
               END 
                          
               IF @b_ValidID = 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err = 555257
                  SET @c_errmsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Diallow duplicate Movable Unit Id with qty more than Pallet Count'
                                + '. (lsp_Validate_ReceiptDetail_Std)'
                  GOTO EXIT_SP
               END
            END                                             --(Wan05) - END
         END
      END
      --(Wan03) - END
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH
   --(Wan02) - END
   EXIT_SP:
   
   IF @n_Continue = 3
   BEGIN
      SET @b_Success = 0 
   END
   ELSE
   BEGIN
      SET @b_Success = 1   
   END
END -- Procedure
GO
GRANT EXECUTE ON [WM].[lsp_Validate_ReceiptDetail_Std] TO nSQL 
GO
