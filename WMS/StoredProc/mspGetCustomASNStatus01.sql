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
/* 16-Jun-2026 AYD01    1.1   Implementation for VA, UNL                */
/************************************************************************/

CREATE OR ALTER PROC dbo.mspGetCustomASNStatus01 
@c_StorerKey NVARCHAR(20),
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
  @c_SQLOperator NVARCHAR(10),
  @c_RefNoLKUP NVARCHAR(20)

  IF OBJECT_ID('tempdb..#TMP_SUPPORTED_CONDITIONS','u') IS NOT NULL
  BEGIN
      DROP TABLE #TMP_SUPPORTED_CONDITIONS
  END

  CREATE TABLE [#TMP_SUPPORTED_CONDITIONS] (        
    [column] NVARCHAR(100) NULL,
    [value] NVARCHAR(100) NULL,
    [condition] NVARCHAR(MAX) NULL                
  )  
  --AYD01 Start
  SELECT TOP 1 @c_RefNoLKUP = CODE
  FROM CODELKUP 
  WHERE LISTNAME = 'REFNOLKUP' 
  AND StorerKey = @c_StorerKey

  SET @c_RefNoLKUP = ISNULL(TRIM(@c_RefNoLKUP), '') 

  IF @c_RefNoLKUP <> '' AND EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'RECEIPT'
  )
  BEGIN
    INSERT INTO #TMP_SUPPORTED_CONDITIONS ([column], [value], [condition])
    VALUES 
    ('externasnStatus', 'VA', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      JOIN RDT.RDTVASLOG (NOLOCK) rvl ON rvl.REF1 = mspGetCustomASNStatus01_r.' + @c_RefNoLKUP + ' 
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''VA''
      AND RECEIPT.' + @c_RefNoLKUP + ' = ''0''
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) = 0
      )) '),
    ('externasnStatus', 'UNL', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      JOIN RDT.RDTVASLOG (NOLOCK) rvl ON rvl.REF1 = mspGetCustomASNStatus01_r.' + @c_RefNoLKUP + ' 
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''UNL''
      AND RECEIPT.' + @c_RefNoLKUP + ' = ''2''
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) = 0
      )) ')
  END
  --AYD01 End

  INSERT INTO #TMP_SUPPORTED_CONDITIONS ([column], [value], [condition])
  VALUES 
    ('externasnStatus', '0', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''0''
      AND RECEIPT.ASNSTATUS NOT IN (''0'',''9'',''CANC'',''VA'',''UNL'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) = 0
      )) '), 
    ('externasnStatus', '1', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''1''
      AND mspGetCustomASNStatus01_rd.FINALIZEFLAG =''N''
      AND RECEIPT.ASNSTATUS NOT IN (''1'', ''9'', ''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) < SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyExpected,0))
      AND SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) > 0  
      )) '),
    ('externasnStatus', 'REC', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''REC''
      AND mspGetCustomASNStatus01_rd.FINALIZEFLAG =''N''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) = SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyExpected,0))
      AND SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) > 0  
      )) '),
    ('externasnStatus', 'PFIN', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PFIN''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS = ''1''
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyExpected,0)) > SUM(mspGetCustomASNStatus01_rd.QtyReceived)
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) '),
    ('externasnStatus', 'FIN', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''FIN''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      AND RECEIPT.STATUS = ''9''
      )) '),
    ('externasnStatus', 'IP', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      JOIN StorerConfig mspGetCustomASNStatus01_sc (NOLOCK) ON mspGetCustomASNStatus01_sc.StorerKey = RECEIPT.StorerKey 
        AND mspGetCustomASNStatus01_sc.ConfigKey = ''UPDATE RECEIPTDETAIL TOLOC'' 
        AND mspGetCustomASNStatus01_sc.SValue IN (''0'', ''1'')
      JOIN LOTXLOCXID (NOLOCK) mspGetCustomASNStatus01_lli ON mspGetCustomASNStatus01_lli.StorerKey = mspGetCustomASNStatus01_rd.StorerKey 
        AND mspGetCustomASNStatus01_lli.Sku = mspGetCustomASNStatus01_rd.Sku 
        AND mspGetCustomASNStatus01_lli.Lot = mspGetCustomASNStatus01_rd.ToLot 
        AND mspGetCustomASNStatus01_lli.ID = mspGetCustomASNStatus01_rd.ToID
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''IP''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS IN (''PFIN'', ''FIN'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyExpected,0)) > SUM(mspGetCustomASNStatus01_rd.QtyReceived)
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) '),
    ('externasnStatus', 'PC', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      JOIN StorerConfig mspGetCustomASNStatus01_sc (NOLOCK) ON mspGetCustomASNStatus01_sc.StorerKey = RECEIPT.StorerKey 
        AND mspGetCustomASNStatus01_sc.ConfigKey = ''UPDATE RECEIPTDETAIL TOLOC'' 
        AND mspGetCustomASNStatus01_sc.SValue IN (''0'', ''1'')
      JOIN LOTXLOCXID (NOLOCK) mspGetCustomASNStatus01_lli ON mspGetCustomASNStatus01_lli.StorerKey = mspGetCustomASNStatus01_rd.StorerKey 
        AND mspGetCustomASNStatus01_lli.Sku = mspGetCustomASNStatus01_rd.Sku 
        AND mspGetCustomASNStatus01_lli.Lot = mspGetCustomASNStatus01_rd.ToLot 
        AND mspGetCustomASNStatus01_lli.ID = mspGetCustomASNStatus01_rd.ToID
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PC''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS IN (''PFIN'', ''FIN'', ''IP'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(mspGetCustomASNStatus01_lli.Qty) = 0
      AND SUM(mspGetCustomASNStatus01_rd.QtyReceived) > 0
      )) ')

  SET @c_ConvertedSQLStr = @c_SQLStr
  SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, 'RECEIPT.RECType,RECEIPT.ASNStatus,RECEIPT.ASNREASON,', 'RECEIPT.RECType,RECEIPT.ASNREASON,')
  SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, @c_TargetStr, @c_ReplaceStr)
  --debug
  print '1. @c_ConvertedSQLStr: ' + @c_ConvertedSQLStr

  SET @c_ConvertedColumnStr = 
      'SELECT CASE '

  --AYD01 Start - Add VA and UNL status
  IF @c_RefNoLKUP <> '' AND EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'RECEIPT'
  )
  BEGIN
    SET @c_ConvertedColumnStr = CONCAT(@c_ConvertedColumnStr, '
      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      JOIN RDT.RDTVASLOG (NOLOCK) rvl ON rvl.REF1 = mspGetCustomASNStatus01_r.' + @c_RefNoLKUP + ' 
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''VA''
      AND RECEIPT.' + @c_RefNoLKUP + '  = ''0''
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) = 0
      )) THEN ''VA''  

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      JOIN RDT.RDTVASLOG (NOLOCK) rvl ON rvl.REF1 = mspGetCustomASNStatus01_r.' + @c_RefNoLKUP + ' 
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''UNL''
      AND RECEIPT.' + @c_RefNoLKUP + '  = ''2''
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) = 0
      )) THEN ''UNL''
      ')
  END
  --AYD01 End

  SET @c_ConvertedColumnStr = CONCAT(@c_ConvertedColumnStr, 
      '
      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''0''
      AND RECEIPT.ASNSTATUS NOT IN (''0'',''9'',''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) = 0
      )) THEN ''0''  

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''1''
      AND mspGetCustomASNStatus01_rd.FINALIZEFLAG =''N''
      AND RECEIPT.ASNSTATUS NOT IN (''1'', ''9'', ''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) < SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyExpected,0))
      AND SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) > 0  
      )) THEN ''1''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''REC''
      AND mspGetCustomASNStatus01_rd.FINALIZEFLAG =''N''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) = SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyExpected,0))
      AND SUM(COALESCE(mspGetCustomASNStatus01_rd.BeforeReceivedQty,0)) > 0  
      )) THEN ''REC''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PFIN''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS = ''1''
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyExpected,0)) > SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyReceived,0))
      AND SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyReceived,0)) > 0
      )) THEN ''PFIN''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''FIN''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      AND RECEIPT.STATUS = ''9''
      )) THEN ''FIN''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      JOIN StorerConfig mspGetCustomASNStatus01_sc (NOLOCK) ON mspGetCustomASNStatus01_sc.StorerKey = RECEIPT.StorerKey 
        AND mspGetCustomASNStatus01_sc.ConfigKey = ''UPDATE RECEIPTDETAIL TOLOC'' 
        AND mspGetCustomASNStatus01_sc.SValue IN (''0'', ''1'')
      JOIN LOTXLOCXID (NOLOCK) mspGetCustomASNStatus01_lli ON mspGetCustomASNStatus01_lli.StorerKey = mspGetCustomASNStatus01_rd.StorerKey 
        AND mspGetCustomASNStatus01_lli.Sku = mspGetCustomASNStatus01_rd.Sku 
        AND mspGetCustomASNStatus01_lli.Lot = mspGetCustomASNStatus01_rd.ToLot 
        AND mspGetCustomASNStatus01_lli.ID = mspGetCustomASNStatus01_rd.ToID
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''IP''
      AND RECEIPT.ASNSTATUS NOT IN (''IP'', ''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS IN (''PFIN'', ''FIN'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyExpected,0)) > SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyReceived,0))
      AND SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyReceived,0)) > 0
      )) THEN ''IP''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomASNStatus01_cl (NOLOCK) 
      JOIN RECEIPT mspGetCustomASNStatus01_r (NOLOCK) ON mspGetCustomASNStatus01_r.StorerKey = mspGetCustomASNStatus01_cl.StorerKey 
        AND mspGetCustomASNStatus01_r.ReceiptKey = RECEIPT.ReceiptKey
      LEFT JOIN RECEIPTDETAIL mspGetCustomASNStatus01_rd (NOLOCK) ON mspGetCustomASNStatus01_rd.ReceiptKey = mspGetCustomASNStatus01_r.ReceiptKey
      JOIN StorerConfig mspGetCustomASNStatus01_sc (NOLOCK) ON mspGetCustomASNStatus01_sc.StorerKey = RECEIPT.StorerKey 
        AND mspGetCustomASNStatus01_sc.ConfigKey = ''UPDATE RECEIPTDETAIL TOLOC'' 
        AND mspGetCustomASNStatus01_sc.SValue IN (''0'', ''1'')
      JOIN LOTXLOCXID (NOLOCK) mspGetCustomASNStatus01_lli ON mspGetCustomASNStatus01_lli.StorerKey = mspGetCustomASNStatus01_rd.StorerKey 
        AND mspGetCustomASNStatus01_lli.Sku = mspGetCustomASNStatus01_rd.Sku 
        AND mspGetCustomASNStatus01_lli.Lot = mspGetCustomASNStatus01_rd.ToLot 
        AND mspGetCustomASNStatus01_lli.ID = mspGetCustomASNStatus01_rd.ToID
      WHERE mspGetCustomASNStatus01_cl.LISTNAME = ''ASNSTATUS'' 
      AND mspGetCustomASNStatus01_cl.StorerKey = RECEIPT.StorerKey 
      AND mspGetCustomASNStatus01_cl.CODE = ''PC''
      AND RECEIPT.ASNSTATUS NOT IN (''9'', ''CANC'')
      AND RECEIPT.ASNSTATUS IN (''PFIN'', ''FIN'', ''IP'')
      GROUP BY mspGetCustomASNStatus01_rd.ReceiptKey 
      HAVING SUM(COALESCE(mspGetCustomASNStatus01_lli.Qty,0)) = 0
      AND SUM(COALESCE(mspGetCustomASNStatus01_rd.QtyReceived,0)) > 0
      )) THEN ''PC''

      ELSE RECEIPT.ASNStatus
      END

      AS ASNStatus, ')

  SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, 
    'SELECT RECEIPT.ReceiptKey, RECEIPT.ExternReceiptKey', 
    @c_ConvertedColumnStr + ' RECEIPT.ReceiptKey, RECEIPT.ExternReceiptKey')
  

  SET @c_ConditionBuilder = ' (1=1' -- default condition, will be updated based on the operation

  --debug
  SELECT ssc.[column], ssc.[operation], ssc.[value], ssc.[logicalOperation], cc.[condition]
  FROM #TMP_SCE_SEARCHING_CRITERIAS SSC
  LEFT JOIN #TMP_SUPPORTED_CONDITIONS CC ON SSC.[column] = CC.[column] AND SSC.[value] = CC.[value]
  WHERE SSC.[column] = 'externasnStatus'
  AND SSC.[operation] <> 'IN'

  DECLARE CUR CURSOR READ_ONLY FAST_FORWARD FOR
  SELECT ssc.[column], ssc.[operation], ssc.[value], ssc.[logicalOperation], cc.[condition]
  FROM #TMP_SCE_SEARCHING_CRITERIAS SSC
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