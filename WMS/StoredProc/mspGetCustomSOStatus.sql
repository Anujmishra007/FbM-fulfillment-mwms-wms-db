SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: dbo.mspGetCustomSOStatus                           */
/* Creation Date: 18-May-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose: Convert JDBC Query Statement for Customization              */
/*                                                                      */
/* Called By: WM.lsp_JDBCQueryConverter_Wrapper                         */
/* ConfigKey: GetAddOrderStatus                                         */
/* SValue:    mspGetCustomSOStatus                                      */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 18-May-2026 AYD      1.0   Creation for FCR-11923                    */
/************************************************************************/

CREATE OR ALTER PROC dbo.mspGetCustomSOStatus 
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
  @c_TargetStr NVARCHAR(MAX) = ' ( ORDERS.SOStatus ',
  @c_ReplaceStr NVARCHAR(MAX) = ' ( 1=1 OR ORDERS.SOStatus ',
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
    ('sostatus', '0', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
        WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
        AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
        AND mspGetCustomSOStatus_cl.CODE = ''0''
        AND ORDERS.Status = ''0''
        AND ORDERS.SOStatus NOT IN (''0'', ''9'', ''CANC'')
        )) '), 
    ('sostatus', 'PA', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
        WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
        AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
        AND mspGetCustomSOStatus_cl.CODE = ''PA''
        AND ORDERS.Status = ''1''
        AND ORDERS.SOStatus NOT IN (''PA'', ''9'', ''CANC'')
        )) '),
    ('sostatus', 'FA', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''FA''
      AND ORDERS.Status = ''2''
      AND ORDERS.SOStatus NOT IN (''FA'', ''9'', ''CANC'')
      )) '),
    ('sostatus', 'IPK', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''IPK''
      AND ORDERS.Status = ''3''
      AND ORDERS.SOStatus NOT IN (''IPK'', ''9'', ''CANC'')
      )) '),
    ('sostatus', 'PKD', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''PKD''
      AND ORDERS.Status = ''5''
      AND ORDERS.SOSTATUS IN (''IPKD'',''MBL'')
      AND ORDERS.SOStatus NOT IN (''PKD'', ''9'', ''CANC'')
      AND pah.STATUS = ''9''
      )) '),
    ('sostatus', 'PC', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''PC''
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''PC'', ''9'', ''CANC'')
      )) '),
    ('sostatus', 'IPKD', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      JOIN PackDetail pad (NOLOCK) ON pah.PickSlipNo = pad.PickSlipNo
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''IPKD''
      AND ORDERS.Status = ''5''
      AND ORDERS.SOSTATUS = ''PC''
      AND ORDERS.SOStatus NOT IN (''IPKD'', ''9'', ''CANC'')
      GROUP BY o.OrderKey HAVING SUM(pid.Qty) > SUM(pad.Qty)
      )) '),
    ('sostatus', 'INV', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''INV''
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''INV'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo = ''''
      AND ORDERS.ShipperKey = ''''
      AND ORDERS.MBOLKey = ''''
      )) '),
    ('sostatus', 'IEG', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''IEG''
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''IEG'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo <> ''''
      AND ORDERS.ShipperKey = ''''
      AND ORDERS.MBOLKey = ''''
      )) '),
    ('sostatus', 'ILR', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''ILR''
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''ILR'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo = ''''
      AND ORDERS.ShipperKey <> ''''
      AND ORDERS.MBOLKey = ''''
      )) '),
    ('sostatus', 'ELR', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''ELR''
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''ELR'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo = ''''
      AND ORDERS.TrackingNo <> ''''
      AND ORDERS.ShipperKey <> ''''
      AND ORDERS.MBOLKey = ''''
      )) '),
    ('sostatus', 'MBL', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''MBL''
      AND ORDERS.SOStatus NOT IN (''MBL'', ''9'', ''CANC'')
      AND ORDERS.STATUS = ''5''
      AND pah.STATUS = ''9''
      AND ORDERS.MBOLKey <> ''''
      )) '),
    ('sostatus', 'IL', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      JOIN rdt.RDTScanToTruck stt (NOLOCK) ON pid.OrderKey = stt.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''IL''
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''IL'', ''9'', ''CANC'')
      GROUP BY o.OrderKey 
      HAVING COUNT(stt.URNNo) > 0 
      AND COUNT(pid.DropID) <> COUNT(stt.URNNo)
      )) '),  
    ('sostatus', 'LD', ' (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      JOIN rdt.RDTScanToTruck stt (NOLOCK) ON pid.OrderKey = stt.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''LD''
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''LD'', ''9'', ''CANC'')
      GROUP BY o.OrderKey 
      HAVING COUNT(pid.DropID) = COUNT(stt.URNNo)
      )) ')


  SET @c_ConvertedSQLStr = @c_SQLStr
  SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, 'ORDERS.ContainerQty, ORDERS.SOStatus, ORDERS.MBOLKey,', 'ORDERS.ContainerQty, ORDERS.MBOLKey,')
  SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, @c_TargetStr, @c_ReplaceStr)
  

  SET @c_ConvertedColumnStr = 
      'SELECT CASE

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''0''
      AND ORDERS.Status = ''0''
      AND ORDERS.SOStatus NOT IN (''0'', ''9'', ''CANC'')
      )) THEN ''0''  

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''PA''
      AND ORDERS.Status = ''1''
      AND ORDERS.SOStatus NOT IN (''PA'', ''9'', ''CANC'')
      )) THEN ''PA''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''FA''
      AND ORDERS.Status = ''2''
      AND ORDERS.SOStatus NOT IN (''FA'', ''9'', ''CANC'')
      )) THEN ''FA''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''IPK''
      AND ORDERS.Status = ''3''
      AND ORDERS.SOStatus NOT IN (''IPK'', ''9'', ''CANC'')
      )) THEN ''IPK''
      
      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''PKD''
      AND ORDERS.Status = ''5''
      AND ORDERS.SOSTATUS IN (''IPKD'',''MBL'')
      AND ORDERS.SOStatus NOT IN (''PKD'', ''9'', ''CANC'')
      AND pah.STATUS = ''9''
      )) THEN ''PKD''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''PC''
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''PC'', ''9'', ''CANC'')
      )) THEN ''PC''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      JOIN PackDetail pad (NOLOCK) ON pah.PickSlipNo = pad.PickSlipNo
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''IPKD''
      AND ORDERS.Status = ''5''
      AND ORDERS.SOSTATUS = ''PC''
      AND ORDERS.SOStatus NOT IN (''IPKD'', ''9'', ''CANC'')
      GROUP BY o.OrderKey HAVING SUM(pid.Qty) > SUM(pad.Qty)
      )) THEN ''IPKD''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''INV''
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''INV'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo = ''''
      AND ORDERS.ShipperKey = ''''
      AND ORDERS.MBOLKey = ''''
      )) THEN ''INV''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''IEG''
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''IEG'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo <> ''''
      AND ORDERS.ShipperKey = ''''
      AND ORDERS.MBOLKey = ''''
      )) THEN ''IEG''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''ILR''
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''ILR'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo = ''''
      AND ORDERS.ShipperKey <> ''''
      AND ORDERS.MBOLKey = ''''
      )) THEN ''ILR''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND mspGetCustomSOStatus_cl.CODE = ''ELR''
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''ELR'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo = ''''
      AND ORDERS.TrackingNo <> ''''
      AND ORDERS.ShipperKey <> ''''
      AND ORDERS.MBOLKey = ''''
      )) THEN ''ELR''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.CODE = ''MBL''
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.SOStatus NOT IN (''MBL'', ''9'', ''CANC'')
      AND ORDERS.STATUS = ''5''
      AND pah.STATUS = ''9''
      AND ORDERS.MBOLKey <> ''''
      )) THEN ''MBL''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      JOIN rdt.RDTScanToTruck stt (NOLOCK) ON pid.OrderKey = stt.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.CODE = ''IL''
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''IL'', ''9'', ''CANC'')
      GROUP BY o.OrderKey 
      HAVING COUNT(stt.URNNo) > 0 
      AND COUNT(pid.DropID) <> COUNT(stt.URNNo)
      )) THEN ''IL''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      JOIN rdt.RDTScanToTruck stt (NOLOCK) ON pid.OrderKey = stt.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.CODE = ''LD''
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''LD'', ''9'', ''CANC'')
      GROUP BY o.OrderKey 
      HAVING COUNT(pid.DropID) = COUNT(stt.URNNo)
      )) THEN ''LD''

      ELSE ORDERS.SOStatus
      END

      AS SOStatus, ' 
  
  SET @c_ConvertedSQLStr = CONCAT(@c_ConvertedColumnStr, RIGHT(@c_ConvertedSQLStr, LEN(@c_ConvertedSQLStr) - 6))

  SET @c_ConditionBuilder = ' (1=1' -- default condition, will be updated based on the operation

  DECLARE CUR CURSOR READ_ONLY FAST_FORWARD FOR
  SELECT ssc.[column], ssc.[operation], ssc.[value], ssc.[logicalOperation], cc.[condition]
  FROM #TMP_SCE_SEARCHING_CRITERIAS SSC
  --Left join with supported conditions to make sure only the searching criteria with supported conditions will be converted, for those criteria without supported conditions, no change will be made to avoid potential issue.
  LEFT JOIN #TMP_SUPPORTED_CONDITIONS CC ON SSC.[column] = CC.[column] AND SSC.[value] = CC.[value]
  WHERE SSC.[column] = 'sostatus'
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
      SET @c_Condition = CONCAT(' (ORDERS.SOStatus ', @c_SQLOperator, ' ''', @c_Value, ''' )') 
    END

    SET @c_ConditionBuilder = CONCAT(@c_ConditionBuilder, ' ', @c_Condition)

    FETCH NEXT FROM CUR INTO @c_Column, @c_Operation, @c_Value, @c_LogicalOperation, @c_Condition
  END
  CLOSE CUR
  DEALLOCATE CUR

  --For 'IN' operation, the condition is expected to be like "ORDERS.SOStatus IN ('A', 'B', 'C')", no need to add extra parentheses
  DECLARE CUR CURSOR READ_ONLY FAST_FORWARD FOR
  SELECT ssc.[column], ssc.[operation], ssc.[value], ssc.[logicalOperation], cc.[condition]
  FROM #TMP_SCE_SEARCHING_CRITERIAS SSC
  JOIN #TMP_SUPPORTED_CONDITIONS CC ON SSC.[column] = CC.[column] 
  WHERE SSC.[column] = 'sostatus'
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
        ' (ORDERS.SOStatus IN (''', 
        REPLACE(@c_Value, ',', ''','''), ''') OR ',
        @c_Condition, 
        ' )' 
      )
    END
    ELSE
    BEGIN
      SET @c_Condition = CONCAT
      (
        ' (ORDERS.SOStatus IN (''',
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

  SET @c_ConvertedCountSQLStr = SUBSTRING(@c_ConvertedSQLStr, 0, CHARINDEX('ORDER BY ORDERS.OrderKey ASC', @c_ConvertedSQLStr))
  SET @c_ConvertedCountSQLStr = SUBSTRING(@c_ConvertedCountSQLStr, CHARINDEX('FROM ORDERS WITH (NOLOCK) LEFT OUTER JOIN STORER SHIPPER WITH (NOLOCK) ON (SHIPPER.STORERKEY = ORDERS.ShipperKey)', @c_ConvertedCountSQLStr), LEN(@c_ConvertedCountSQLStr)) 
  SET @c_ConvertedCountSQLStr = 'SELECT COUNT(1) ' + @c_ConvertedCountSQLStr

  QUIT_SP:
END
GO
GRANT EXECUTE ON dbo.mspGetCustomSOStatus TO NSQL
GO