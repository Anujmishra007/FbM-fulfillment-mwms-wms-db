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
-- @c_StorerKey NVARCHAR(10),
@c_ColumnNewValue NVARCHAR(100),
@c_ConvertedSQLStr NVARCHAR(MAX) OUTPUT


AS
BEGIN
  SET NOCOUNT ON
  SET ANSI_NULLS OFF
  SET QUOTED_IDENTIFIER OFF

  DECLARE @c_ConvertedColumnStr NVARCHAR(MAX)

  SET @c_ColumnNewValue = ISNULL(TRIM(@c_ColumnNewValue), '')
  SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, ', ORDERS.SOStatus,', ', ')
  
  SET @c_ConvertedColumnStr = 
      'SELECT CASE

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''0''
      AND ORDERS.SOStatus NOT IN (''0'', ''9'', ''CANC'')
      )) THEN ''0''  

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''1''
      AND ORDERS.SOStatus NOT IN (''PA'', ''9'', ''CANC'')
      )) THEN ''PA''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''2''
      AND ORDERS.SOStatus NOT IN (''FA'', ''9'', ''CANC'')
      )) THEN ''FA''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''3''
      AND ORDERS.SOStatus NOT IN (''IPK'', ''9'', ''CANC'')
      )) THEN ''IPK''
      
      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOSTATUS IN (''IPKD'',''MBL'')
      AND ORDERS.SOStatus NOT IN (''PKD'', ''9'', ''CANC'')
      AND pah.STATUS = ''9''
      )) THEN ''PKD''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
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
      AND ORDERS.Status = ''5''
      AND ORDERS.SOSTATUS = ''PC''
      AND ORDERS.SOStatus NOT IN (''IPKD'', ''9'', ''CANC'')
      GROUP BY o.OrderKey HAVING SUM(pid.Qty) > SUM(pad.Qty)
      )) THEN ''IPKD''

      WHEN (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
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
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''LD'', ''9'', ''CANC'')
      GROUP BY o.OrderKey 
      HAVING COUNT(pid.DropID) = COUNT(stt.URNNo)
      )) THEN ''LD''

      ELSE ORDERS.SOStatus
      END

      AS SOStatus, ' 
  
  SET @c_ConvertedSQLStr = CONCAT(@c_ConvertedColumnStr, RIGHT(@c_SQLStr, LEN(@c_SQLStr) - 6))

  IF @c_ColumnNewValue = '0'
  BEGIN   
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''0''
      AND ORDERS.SOStatus NOT IN (''0'', ''9'', ''CANC'')
      ))' )
  END
  ELSE IF @c_ColumnNewValue = 'PA'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''1''
      AND ORDERS.SOStatus NOT IN (''PA'', ''9'', ''CANC'')
      ))' )
  END
  ELSE IF @c_ColumnNewValue = 'FA'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''2''
      AND ORDERS.SOStatus NOT IN (''FA'', ''9'', ''CANC'')
      ))' )
  END
  ELSE IF @c_ColumnNewValue = 'IPK'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''3''
      AND ORDERS.SOStatus NOT IN (''IPK'', ''9'', ''CANC'')
      ))' )
  END
  ELSE IF @c_ColumnNewValue = 'PC'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''PC'', ''9'', ''CANC'')
      ))' )
  END
  ELSE IF @c_ColumnNewValue = 'IPKD'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      JOIN PackDetail pad (NOLOCK) ON pah.PickSlipNo = pad.PickSlipNo
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOSTATUS = ''PC''
      AND ORDERS.SOStatus NOT IN (''IPKD'', ''9'', ''CANC'')
      GROUP BY o.OrderKey HAVING SUM(pid.Qty) > SUM(pad.Qty)
      ))' )
  END  
  ELSE IF @c_ColumnNewValue = 'PKD'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOSTATUS IN (''IPKD'',''MBL'')
      AND ORDERS.SOStatus NOT IN (''PKD'', ''9'', ''CANC'')
      AND pah.STATUS = ''9''
      ))' )
  END 
  ELSE IF @c_ColumnNewValue = 'INV'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''INV'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo = ''''
      AND ORDERS.ShipperKey = ''''
      AND ORDERS.MBOLKey = ''''
      ))' )
  END 
  ELSE IF @c_ColumnNewValue = 'IEG'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''IEG'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo <> ''''
      AND ORDERS.ShipperKey = ''''
      AND ORDERS.MBOLKey = ''''
      ))' )
  END 
  ELSE IF @c_ColumnNewValue = 'ILR'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''ILR'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo <> ''''
      AND ORDERS.TrackingNo = ''''
      AND ORDERS.ShipperKey <> ''''
      AND ORDERS.MBOLKey = ''''
      ))' )
  END 
  ELSE IF @c_ColumnNewValue = 'ELR'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.SOSTATUS IN (''PKD'')
      AND ORDERS.SOStatus NOT IN (''ELR'', ''9'', ''CANC'')
      AND ORDERS.InvoiceNo = ''''
      AND ORDERS.TrackingNo <> ''''
      AND ORDERS.ShipperKey <> ''''
      AND ORDERS.MBOLKey = ''''
      ))' )
  END 
  ELSE IF @c_ColumnNewValue = 'MBL'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PackHeader pah (NOLOCK) ON o.OrderKey = pah.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.SOStatus NOT IN (''MBL'', ''9'', ''CANC'')
      AND ORDERS.STATUS = ''5''
      AND pah.STATUS = ''9''
      AND ORDERS.MBOLKey <> ''''
      ))' )
  END 
  ELSE IF @c_ColumnNewValue = 'IL'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      JOIN rdt.RDTScanToTruck stt (NOLOCK) ON pid.OrderKey = stt.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''IL'', ''9'', ''CANC'')
      GROUP BY o.OrderKey 
      HAVING COUNT(stt.URNNo) > 0 
      AND COUNT(pid.DropID) <> COUNT(stt.URNNo)
      )) ' )
  END 
  ELSE IF @c_ColumnNewValue = 'LD'
  BEGIN
    SET @c_ConvertedSQLStr = REPLACE(@c_ConvertedSQLStr, '( ( ORDERS.SOStatus = ?  ) )', 
      '( ( 1=1 OR ORDERS.SOStatus = ?  ) )
      AND (EXISTS (SELECT 1 FROM CODELKUP mspGetCustomSOStatus_cl (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON mspGetCustomSOStatus_cl.StorerKey = o.StorerKey AND o.OrderKey = ORDERS.OrderKey
      JOIN PICKDETAIL pid (NOLOCK) ON o.OrderKey = pid.OrderKey
      JOIN rdt.RDTScanToTruck stt (NOLOCK) ON pid.OrderKey = stt.OrderKey
      WHERE mspGetCustomSOStatus_cl.LISTNAME = ''SOSTATUS'' 
      AND mspGetCustomSOStatus_cl.StorerKey = ORDERS.StorerKey 
      AND ORDERS.Status = ''5''
      AND ORDERS.SOStatus NOT IN (''LD'', ''9'', ''CANC'')
      GROUP BY o.OrderKey 
      HAVING COUNT(pid.DropID) = COUNT(stt.URNNo)
      ))' )
  END 
  --debug
  SELECT @c_ConvertedSQLStr AS CONVERTED_SQL INTO #TMP_SQL_CONVERT
  SELECT * FROM #TMP_SQL_CONVERT
  ----------------
END
GO
GRANT EXECUTE ON dbo.mspGetCustomSOStatus TO NSQL
GO