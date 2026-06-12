SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: dbo.mspGetCustomASNStatus01                        */
/* Creation Date: 12-Jun-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose: Convert JDBC Query Statement for Customization              */
/*                                                                      */
/* Called By: WM.lsp_JDBCQueryConverter_Wrapper                         */
/* ConfigKey: CustomizeASNStatus                                        */
/* SValue:    mspGetCustomASNStatus01                                   */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 12-Jun-2026 AYD      1.0   Creation for FCR-11918                    */
/************************************************************************/

CREATE OR ALTER PROC dbo.mspGetCustomASNStatus01 
@c_SQLStr NVARCHAR(MAX),
@c_ConvertedSQLStr NVARCHAR(MAX) OUTPUT,
@c_ConvertedCountSQLStr NVARCHAR(MAX) OUTPUT

AS
BEGIN
  SET NOCOUNT ON
  SET ANSI_NULLS OFF
  SET QUOTED_IDENTIFIER OFF

  DECLARE 
  @c_ConvertedColumnStr NVARCHAR(MAX),
  @c_TargetStr NVARCHAR(MAX) = ' ( RECEIPT.ASNStatus',
  @c_ReplaceStr NVARCHAR(MAX) = ' ( 1=1 OR RECEIPT.ASNStatus',
  @c_Column NVARCHAR(30),
  @c_Operation NVARCHAR(10),
  @c_Value NVARCHAR(100),
  @c_LogicalOperation NVARCHAR(10),
  @c_ConditionBuilder NVARCHAR(MAX),
  @c_Condition NVARCHAR(MAX),
  @c_SQLOperator NVARCHAR(10)

  IF OBJECT_ID('tempdb..#TMP_SUPPORTED_CONDITIONS','u') IS NOT NULL
  BEGIN
      DROP TABLE #TMP_SUPPORTED_CONDITIONS
  END

  CREATE TABLE [#TMP_SUPPORTED_CONDITIONS] (        
    [column] NVARCHAR(100) NULL,
    [value] NVARCHAR(100) NULL,
    [condition] NVARCHAR(MAX) NULL                
  )  

  INSERT INTO #TMP_SUPPORTED_CONDITIONS ([column], [value], [condition])
  VALUES 
    ('ASNSTATUS', '0', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''0''
      AND RECEIPT.STATUS NOT IN (''0'',''9'',''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) = 0
      )) '), 
    ('ASNSTATUS', '1', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''1''
      AND mspGetCustomASNStatus01_rd.FINALIZEFLAG =''N''
      AND RECEIPT.STATUS NOT IN (''1'', ''9'', ''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) < SUM(mspGetCustomASNStatus01_rd.QtyExpected)
      AND SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) > 0  
      )) '),
    ('ASNSTATUS', 'REC', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''REC''
      AND mspGetCustomASNStatus01_rd.FINALIZEFLAG =''N''
      AND RECEIPT.STATUS NOT IN (''REC'', ''9'', ''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) = SUM(mspGetCustomASNStatus01_rd.QtyExpected)
      AND SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) > 0  
      )) '),
    ('ASNSTATUS', 'PFIN', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PFIN''
      AND RECEIPT.STATUS NOT IN (''PFIN'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS = ''1''
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.QtyExpected) > SUM(mspGetCustomASNStatus01_rd.QtyReceived)
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) '),
    ('ASNSTATUS', 'FIN', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''FIN''
      AND RECEIPT.STATUS NOT IN (''FIN'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS = ''9''
      )) '),
    ('ASNSTATUS', 'IP', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      JOIN StorerConfig mspGetCustomASNStatus01_sc (NOLOCK) ON mspGetCustomASNStatus01_sc.StorerKey = RECEIPT.StorerKey 
        AND mspGetCustomASNStatus01_sc.ConfigKey = ''UPDATE RECEIPTDETAIL TOLOC'' 
        AND mspGetCustomASNStatus01_sc.SValue IN (''0'', ''1'')
      JOIN LOTXLOCXID (NOLOCK) mspGetCustomASNStatus01_lli ON mspGetCustomASNStatus01_lli.StorerKey = mspGetCustomASNStatus01_rd.StorerKey 
        AND mspGetCustomASNStatus01_lli.Sku = mspGetCustomASNStatus01_rd.Sku 
        AND mspGetCustomASNStatus01_lli.Lot = mspGetCustomASNStatus01_rd.ToLot 
        AND mspGetCustomASNStatus01_lli.ID = mspGetCustomASNStatus01_rd.ToID
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PFIN''
      AND RECEIPT.STATUS NOT IN (''IP'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS IN (''PFIN'', ''FIN'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.QtyExpected) > SUM(mspGetCustomASNStatus01_rd.QtyReceived)
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) '),
    ('ASNSTATUS', 'PC', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      JOIN StorerConfig mspGetCustomASNStatus01_sc (NOLOCK) ON mspGetCustomASNStatus01_sc.StorerKey = RECEIPT.StorerKey 
        AND mspGetCustomASNStatus01_sc.ConfigKey = ''UPDATE RECEIPTDETAIL TOLOC'' 
        AND mspGetCustomASNStatus01_sc.SValue IN (''0'', ''1'')
      JOIN LOTXLOCXID (NOLOCK) mspGetCustomASNStatus01_lli ON mspGetCustomASNStatus01_lli.StorerKey = mspGetCustomASNStatus01_rd.StorerKey 
        AND mspGetCustomASNStatus01_lli.Sku = mspGetCustomASNStatus01_rd.Sku 
        AND mspGetCustomASNStatus01_lli.Lot = mspGetCustomASNStatus01_rd.ToLot 
        AND mspGetCustomASNStatus01_lli.ID = mspGetCustomASNStatus01_rd.ToID
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PFIN''
      AND RECEIPT.STATUS NOT IN (''PC'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS IN (''PFIN'', ''FIN'', ''IP'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_lli.Qty) = 0
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) ')

  SET @c_ConvertedSQLStr = @c_SQLStr
  SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, 'RECEIPT.RECType,RECEIPT.ASNStatus,RECEIPT.ASNREASON,', 'RECEIPT.RECType,RECEIPT.ASNREASON,')
  SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, @c_TargetStr, @c_ReplaceStr)
  

  SET @c_ConvertedColumnStr = 
      'SELECT CASE

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''0''
      AND RECEIPT.STATUS NOT IN (''0'',''9'',''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) = 0
      )) THEN ''0''  

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''1''
      AND mspGetCustomASNStatus01_rd.FINALIZEFLAG =''N''
      AND RECEIPT.STATUS NOT IN (''1'', ''9'', ''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) < SUM(mspGetCustomASNStatus01_rd.QtyExpected)
      AND SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) > 0  
      )) THEN ''1''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''REC''
      AND mspGetCustomASNStatus01_rd.FINALIZEFLAG =''N''
      AND RECEIPT.STATUS NOT IN (''REC'', ''9'', ''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) = SUM(mspGetCustomASNStatus01_rd.QtyExpected)
      AND SUM(mspGetCustomASNStatus01_rd.BeforeReceivedQty) > 0  
      )) THEN ''REC''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PFIN''
      AND RECEIPT.STATUS NOT IN (''PFIN'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS = ''1''
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.QtyExpected) > SUM(mspGetCustomASNStatus01_rd.QtyReceived)
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) THEN ''PFIN''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''FIN''
      AND RECEIPT.STATUS NOT IN (''FIN'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS = ''9''
      )) THEN ''FIN''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      JOIN StorerConfig mspGetCustomASNStatus01_sc (NOLOCK) ON mspGetCustomASNStatus01_sc.StorerKey = RECEIPT.StorerKey 
        AND mspGetCustomASNStatus01_sc.ConfigKey = ''UPDATE RECEIPTDETAIL TOLOC'' 
        AND mspGetCustomASNStatus01_sc.SValue IN (''0'', ''1'')
      JOIN LOTXLOCXID (NOLOCK) mspGetCustomASNStatus01_lli ON mspGetCustomASNStatus01_lli.StorerKey = mspGetCustomASNStatus01_rd.StorerKey 
        AND mspGetCustomASNStatus01_lli.Sku = mspGetCustomASNStatus01_rd.Sku 
        AND mspGetCustomASNStatus01_lli.Lot = mspGetCustomASNStatus01_rd.ToLot 
        AND mspGetCustomASNStatus01_lli.ID = mspGetCustomASNStatus01_rd.ToID
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PFIN''
      AND RECEIPT.STATUS NOT IN (''IP'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS IN (''PFIN'', ''FIN'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_rd.QtyExpected) > SUM(mspGetCustomASNStatus01_rd.QtyReceived)
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) THEN ''IP''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = RECEIPT.ReceiptKey
      JOIN StorerConfig mspGetCustomASNStatus01_sc (NOLOCK) ON mspGetCustomASNStatus01_sc.StorerKey = RECEIPT.StorerKey 
        AND mspGetCustomASNStatus01_sc.ConfigKey = ''UPDATE RECEIPTDETAIL TOLOC'' 
        AND mspGetCustomASNStatus01_sc.SValue IN (''0'', ''1'')
      JOIN LOTXLOCXID (NOLOCK) mspGetCustomASNStatus01_lli ON mspGetCustomASNStatus01_lli.StorerKey = mspGetCustomASNStatus01_rd.StorerKey 
        AND mspGetCustomASNStatus01_lli.Sku = mspGetCustomASNStatus01_rd.Sku 
        AND mspGetCustomASNStatus01_lli.Lot = mspGetCustomASNStatus01_rd.ToLot 
        AND mspGetCustomASNStatus01_lli.ID = mspGetCustomASNStatus01_rd.ToID
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PFIN''
      AND RECEIPT.STATUS NOT IN (''PC'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS IN (''PFIN'', ''FIN'', ''IP'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_lli.Qty) = 0
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) THEN ''PC''

      ELSE RECEIPT.ASNStatus
      END

      AS ASNStatus, ' 
  
  SET @c_ConvertedSQLStr = CONCAT(@c_ConvertedColumnStr, RIGHT(@c_ConvertedSQLStr, LEN(@c_ConvertedSQLStr) - 6))

  SET @c_ConditionBuilder = ' (1=1' -- default condition, will be updated based on the operation

  DECLARE CUR CURSOR READ_ONLY FAST_FORWARD FOR
  SELECT ssc.[column], ssc.[operation], ssc.[value], ssc.[logicalOperation], cc.[condition]
  FROM #TMP_SCE_SEARCHING_CRITERIAS SSC
  --Left join with supported conditions to make sure only the searching criteria with supported conditions will be converted, for those criteria without supported conditions, no change will be made to avoid potential issue.
  LEFT JOIN #TMP_SUPPORTED_CONDITIONS CC ON SSC.[column] = CC.[column] AND SSC.[value] = CC.[value]
  WHERE SSC.[column] = 'externasnStatus'
  AND SSC.[operation] <> 'IN'

  OPEN CUR
  FETCH NEXT FROM CUR INTO @c_Column, @c_Operation, @c_Value, @c_LogicalOperation, @c_Condition
  WHILE @@FETCH_STATUS = 0
  BEGIN
    
    SELECT @c_ConditionBuilder = CONCAT(
      @c_ConditionBuilder,
      IIF(@c_LogicalOperation IN ('OR'), ' OR ', ' AND ')
    )

    IF @c_Operation = '<>'
    BEGIN
      SET @c_ConditionBuilder = CONCAT(@c_ConditionBuilder, ' NOT ')
    END

    SET @c_SQLOperator = IIF(@c_Operation = 'contains', ' LIKE ', @c_Operation)

    IF ISNULL(TRIM(@c_Condition), '') = ''
    BEGIN 
      SET @c_Condition = CONCAT(' (RECEIPT.ASNStatus ', @c_SQLOperator, ' ''', @c_Value, ''' )') 
    END

    SET @c_ConditionBuilder = CONCAT(@c_ConditionBuilder, ' ', @c_Condition)

    FETCH NEXT FROM CUR INTO @c_Column, @c_Operation, @c_Value, @c_LogicalOperation, @c_Condition
  END
  CLOSE CUR
  DEALLOCATE CUR

  DECLARE CUR CURSOR READ_ONLY FAST_FORWARD FOR
  SELECT ssc.[column], ssc.[operation], ssc.[value], ssc.[logicalOperation], cc.[condition]
  FROM #TMP_SCE_SEARCHING_CRITERIAS SSC
  JOIN #TMP_SUPPORTED_CONDITIONS CC ON SSC.[column] = CC.[column] 
  WHERE SSC.[column] = 'externasnStatus'
  AND SSC.[operation] = 'IN'
  AND (ssc.[value] LIKE '%,' + cc.[value] + ',%' OR ssc.[value] LIKE cc.[value] + ',%' OR ssc.[value] LIKE '%,' + cc.[value] OR ssc.[value] = cc.[value])
  AND ISNULL(TRIM(CC.[condition]), '') <> ''

  OPEN CUR
  FETCH NEXT FROM CUR INTO @c_Column, @c_Operation, @c_Value, @c_LogicalOperation, @c_Condition
  WHILE @@FETCH_STATUS = 0
  BEGIN
    
    SELECT @c_ConditionBuilder = CONCAT(
      @c_ConditionBuilder,
      IIF(@c_LogicalOperation IN ('OR'), ' OR ', ' AND ')
    ) 

    IF @c_Operation = '<>'
    BEGIN
      SET @c_ConditionBuilder = CONCAT(@c_ConditionBuilder, ' NOT ')
    END

    -- add extra parentheses to make sure the logic is correct after replacement  
    IF ISNULL(TRIM(@c_Condition), '') <> ''
    BEGIN 
      SET @c_Condition = CONCAT
      (
        ' (RECEIPT.ASNStatus IN (''', 
        REPLACE(@c_Value, ',', ''','''), ''') OR ',
        @c_Condition, 
        ' )' 
      )
    END
    ELSE
    BEGIN
      SET @c_Condition = CONCAT
      (
        ' (RECEIPT.ASNStatus IN (''',
        REPLACE(@c_Value, ',', ''','''),
        ''')) ' 
      )
    END 

    SET @c_ConditionBuilder = CONCAT(@c_ConditionBuilder, ' ', @c_Condition)

    FETCH NEXT FROM CUR INTO @c_Column, @c_Operation, @c_Value, @c_LogicalOperation, @c_Condition
  END
  CLOSE CUR
  DEALLOCATE CUR

  SET @c_ConditionBuilder = CONCAT(@c_ConditionBuilder, ' ) ')

  SET @c_ConvertedSQLStr = REPLACE(
    @c_ConvertedSQLStr, 
    'ORDER BY', 
    CONCAT(' AND ', @c_ConditionBuilder, ' ORDER BY')
  )

  SET @c_ConvertedCountSQLStr = SUBSTRING(@c_ConvertedSQLStr, 0, CHARINDEX('order by RECEIPT.', @c_ConvertedSQLStr))
  SET @c_ConvertedCountSQLStr = SUBSTRING(@c_ConvertedCountSQLStr, CHARINDEX('FROM RECEIPT WITH (NOLOCK) LEFT OUTER JOIN V_ASN_Total_Expected_Received_Qty ter', @c_ConvertedCountSQLStr), LEN(@c_ConvertedCountSQLStr)) 
  SET @c_ConvertedCountSQLStr = 'SELECT COUNT(1) ' + @c_ConvertedCountSQLStr

  QUIT_SP:
END
GO
GRANT EXECUTE ON dbo.mspGetCustomASNStatus01 TO NSQL
GO