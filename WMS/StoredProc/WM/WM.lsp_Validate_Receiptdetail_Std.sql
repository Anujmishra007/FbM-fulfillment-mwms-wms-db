IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_Validate_ReceiptDetail_Std]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_Validate_ReceiptDetail_Std]
GO

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
/* Version: 1.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author   Ver  Purposes                                   */ 
/*************************************************************************/   
CREATE PROC [WM].[lsp_Validate_ReceiptDetail_Std] (
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
         @c_ReceiptKey           NVARCHAR(10) = ''
      ,  @c_ReceiptLineNo        NVARCHAR(5)  = ''
      ,  @c_Facility             NVARCHAR(5)  = ''
      ,  @c_Facility_LOC         NVARCHAR(5)  = ''
      ,  @c_Storerkey            NVARCHAR(15) = ''
      ,  @c_ToLoc                NVARCHAR(10) = ''

   SELECT TOP 1 
         @c_ReceiptKey    = RD.ReceiptKey
      ,  @c_ReceiptLineNo = RD.ReceiptLineNumber
      ,  @c_Storerkey     = RD.Storerkey
      ,  @c_ToLoc         = RTRIM(RD.ToLoc)
   FROM  #RECEIPTDETAIL RD  

   SELECT TOP 1 
         @c_Facility = RTRIM(R.Facility)
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
         SET @c_errmsg = 'Invalid Loc: ' + @c_ToLoc + '. (lsp_Validate_ReceiptDetail_Std)'
                       + ' |' + @c_ToLoc 
         GOTO EXIT_SP
      END


      IF @c_Facility_LOC <> @c_Facility AND @c_Facility <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 555252
         SET @c_errmsg = 'Loc: ' + @c_ToLoc + ' does not belong to facility: ' + @c_Facility + '. (lsp_Validate_ReceiptDetail_Std)'
                       + ' |' + @c_ToLoc + '|' + @c_Facility
         GOTO EXIT_SP
      END
   END
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
