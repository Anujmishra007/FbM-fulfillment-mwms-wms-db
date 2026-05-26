SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: WM.lsp_JDBCQueryConverter_Wrapper                  */
/* Creation Date: 18-May-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose: Convert JDBC Query Statement for Customization              */
/*                                                                      */
/* Called By: SCE JAVA Layer                                            */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 18-May-2026 AYD      1.0   Creation for FCR-11918, FCR-11923         */
/************************************************************************/
CREATE OR ALTER PROCEDURE [WM].[lsp_JDBCQueryConverter_Wrapper]
   @c_SQLStr NVARCHAR(MAX),
   @c_RequestJSON NVARCHAR(MAX),
   @c_StorerKey NVARCHAR(10),
   @c_ConfigKey NVARCHAR(20),
   @c_ConvertedSQLStr NVARCHAR(MAX) OUTPUT,
   @b_Success INT OUTPUT,
   @n_err INT OUTPUT,
   @c_ErrMsg NVARCHAR(215) OUTPUT,
   @c_UserName NVARCHAR(50) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue                 INT,
           @c_CustomSPName             NVARCHAR(30),
           @c_SQL_CallSP               NVARCHAR(MAX)

   SELECT @n_continue = 1, @b_Success = 0

   SET @n_Err = 0
   DECLARE @b_ExecuteAs BIT = 0
   IF SUSER_SNAME() <> @c_UserName
   BEGIN 

      EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
         ,  @b_ExecuteAs = @b_ExecuteAs OUTPUT
         
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END

      IF @b_ExecuteAs = 1                    
         EXECUTE AS LOGIN = @c_UserName
   END

   SELECT TOP 1 @c_CustomSPName = sc.SValue  
   FROM dbo.StorerConfig sc (NOLOCK)  
   WHERE sc.StorerKey = @c_StorerKey
   AND sc.ConfigKey = @c_ConfigKey
   AND ISNULL(RTRIM(sc.SValue), '') <> ''


   IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_CustomSPName) AND type = 'P')  
   BEGIN
      IF OBJECT_ID('tempdb..#TMP_SCE_SEARCHING_CRITERIAS','u') IS NOT NULL
      BEGIN
         DROP TABLE #TMP_SCE_SEARCHING_CRITERIAS
      END

      CREATE TABLE [#TMP_SCE_SEARCHING_CRITERIAS] (        
         [column] NVARCHAR(100) NULL,
         [operation] NVARCHAR(10) NULL,
         [value] NVARCHAR(100) NULL,
         [logicalOperation] NVARCHAR(10) NULL                
      )

      INSERT INTO #TMP_SCE_SEARCHING_CRITERIAS ([column], [operation], [value], [logicalOperation])
      SELECT [column], [operation], [value], [logicalOperation] 
      FROM OPENJSON(@c_RequestJSON, '$.searchCriteria.conditions[0].clauses')
      WITH (
         [column] NVARCHAR(100) '$.column',
         [operation] NVARCHAR(10) '$.operation',
         [value] NVARCHAR(100) '$.value',
         [logicalOperation] NVARCHAR(10) '$.logicalOperation'
      ) AS MandatorySearchClauses

      INSERT INTO #TMP_SCE_SEARCHING_CRITERIAS ([column], [operation], [value], [logicalOperation])
      SELECT [column], [operation], [value], [logicalOperation] 
      FROM OPENJSON(@c_RequestJSON, '$.searchCriteria.conditions[1].clauses')
      WITH (
         [column] NVARCHAR(100) '$.column',
         [operation] NVARCHAR(10) '$.operation',
         [value] NVARCHAR(100) '$.value',
         [logicalOperation] NVARCHAR(10) '$.logicalOperation'
      ) AS NonMandatorySearchClauses

      --debug
      SELECT * FROM #TMP_SCE_SEARCHING_CRITERIAS


      SET @c_SQL_CallSP = 'EXEC ' + @c_CustomSPName + 
      ' @c_SQLStr = @c_SQLStr, @c_ConvertedSQLStr = @c_ConvertedSQLStr OUTPUT'
      EXEC sp_executesql @c_SQL_CallSP, 
         N'@c_SQLStr NVARCHAR(MAX), @c_ConvertedSQLStr NVARCHAR(MAX) OUTPUT', 
         @c_SQLStr, @c_ConvertedSQLStr OUTPUT
   END
   ELSE
   BEGIN
      SET @c_ConvertedSQLStr = @c_SQLStr
   END

   EXIT_SP:
   IF @n_continue <> 3
   BEGIN
      SET @b_success = 1
   END
   ELSE
   BEGIN
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_JDBCQueryConverter_Wrapper'
   END
   IF @b_ExecuteAs = 1              
      REVERT                        

   EXEC [WM].[lsp_ResetUser]
END
GO
GRANT EXECUTE ON  [WM].[lsp_JDBCQueryConverter_Wrapper] TO [NSQL]
GO
