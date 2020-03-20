IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_Validate_InventoryQCDetail_Std]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [WM].[lsp_Validate_InventoryQCDetail_Std]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************/  
/* Stored Procedure: lsp_Validate_InventoryQCDetail_Std                  */  
/* Creation Date: 20-JAN-2020                                            */  
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
CREATE PROC [WM].[lsp_Validate_InventoryQCDetail_Std] (
  @c_XMLSchemaString    NVARCHAR(MAX) 
, @c_XMLDataString      NVARCHAR(MAX) 
, @b_Success            INT OUTPUT
, @n_Err                INT OUTPUT
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

   IF OBJECT_ID('tempdb..#INVENTORYQCDETAIL') IS NOT NULL
   BEGIN
      DROP TABLE #INVENTORYQCDETAIL
   END

   CREATE TABLE #INVENTORYQCDETAIL( Rowid  INT NOT NULL IDENTITY(1,1) )   

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
      SET @c_SQL = N'ALTER TABLE #INVENTORYQCDETAIL  ADD  ' + SUBSTRING(@c_SQLSchema, 1, LEN(@c_SQLSchema) - 1) + ' '
         
      EXEC (@c_SQL)

      SET @c_SQL = N' INSERT INTO #INVENTORYQCDETAIL' --+  @c_UpdateTable 
                  + ' ( ' + SUBSTRING(@c_TableColumns, 1, LEN(@c_TableColumns) - 1) + ' )'
                  + ' SELECT ' + SUBSTRING(@c_SQLData, 1, LEN(@c_SQLData) - 1) 
                  + ' FROM @x_XMLData.nodes(''Row'') TempXML (x) '  
         
      EXEC sp_executeSQl @c_SQL
                        , N'@x_XMLData xml'
                        , @x_XMLData
      
   END

   DECLARE 
         @c_FromFacility         NVARCHAR(5)  = ''
      ,  @c_QC_Key               NVARCHAR(10) = ''
      ,  @c_QCLineNo             NVARCHAR(5)  = ''

      ,  @c_Storerkey            NVARCHAR(15) = ''
      ,  @c_Sku                  NVARCHAR(20) = ''
      ,  @c_FromLot              NVARCHAR(10) = ''
      ,  @c_FromLoc              NVARCHAR(10) = ''
      ,  @c_FromID               NVARCHAR(18) = ''
      ,  @c_ToLot                NVARCHAR(10) = ''
      ,  @c_ToLoc                NVARCHAR(10) = ''
      ,  @c_ToID                 NVARCHAR(18) = ''
      ,  @c_Reason               NVARCHAR(10) = ''
      ,  @c_Status               NVARCHAR(1)  = '0'
      ,  @n_FromQty              INT          = 0
      ,  @n_ToQty                INT          = 0

      ,  @c_FinalizeIQC          NVARCHAR(30) = ''

   SELECT TOP 1 
         @c_QC_Key      = IQCD.QC_Key
      ,  @c_QCLineNo    = IQCD.QCLineNo
      ,  @c_Storerkey   = IQCD.Storerkey
      ,  @c_Sku         = RTRIM(IQCD.Sku)
      ,  @c_FromLot     = ISNULL(IQCD.FromLot,'')
      ,  @c_FromLoc     = ISNULL(IQCD.FromLoc,'')
      ,  @c_FromID      = ISNULL(IQCD.FromID,'')
      ,  @c_ToLoc       = ISNULL(IQCD.ToLoc,'')
      ,  @c_ToID        = ISNULL(IQCD.ToID,'')

      ,  @n_FromQty     = ISNULL(IQCD.Qty,0)
      ,  @n_ToQty       = ISNULL(IQCD.ToQty,0)
      ,  @c_Reason      = ISNULL(IQCD.Reason,'')
      ,  @c_Status      = ISNULL(IQCD.[Status],'0')
   FROM  #INVENTORYQCDETAIL IQCD  

   SELECT TOP 1 
         @c_FromFacility = IQCH.From_Facility
   FROM  INVENTORYQC IQCH WITH (NOLOCK) 
   WHERE IQCH.QC_Key = @c_QC_Key  

   IF @c_FromFacility = '' AND @c_FromLoc <> ''
   BEGIN
      SELECT @c_FromFacility = L.Facility
      FROM LOC L WITH (NOLOCK)
      WHERE L.Loc = @c_FromLoc
   END

   IF @n_FromQty > 0 AND @c_Reason = ''
   BEGIN 
      IF @n_ToQty = 0 OR @c_ToLoc = '' OR @c_ToId = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 557601
         SET @c_errmsg = 'Reason is required! (lsp_Validate_InventoryQCDetail_Std)'
         GOTO EXIT_SP
      END
   END

   IF @c_ToLoc = @c_FromLoc --OR @c_ToId = @c_FromId
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 557602
      SET @c_errmsg = 'ToLoc/ToID should be different from FromLoc/FromID! (lsp_Validate_InventoryQCDetail_Std)'
      GOTO EXIT_SP
   END

   SELECT @c_FinalizeIQC = dbo.fnc_GetRight(@c_FromFacility, @c_Storerkey, '', 'FinalizeIQC')

   IF @c_FinalizeIQC = '0' AND @c_Status < '9'
   BEGIN 
      IF NOT EXISTS (  SELECT 1
                        FROM LOTxLOCxID LLI WITH (NOLOCK)
                        WHERE LLI.Lot = @c_FromLot
                        AND   LLI.Loc = @c_FromLoc
                        AND   LLI.ID  = @c_FromID
                        AND   LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked >= @n_ToQty
                      )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 557603
         SET @c_errmsg = 'Inventory has been moved away from the original place!'  
                       + '(lsp_Validate_InventoryQCDetail_Std).'
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
GRANT EXECUTE ON [WM].[lsp_Validate_InventoryQCDetail_Std] TO nSQL 
GO
