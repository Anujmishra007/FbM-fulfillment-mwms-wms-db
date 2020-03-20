IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[isp_GetColumnTitle]') 
                      AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[isp_GetColumnTitle]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: isp_GetColumnTitle                                 */
/* Creation Date: 22-May-2012                                           */
/* Copyright: IDS                                                       */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose: SOS#244027 - SkuInfo for Bond                               */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/

CREATE PROC [dbo].[isp_GetColumnTitle] 
      (  @c_ListName       NVARCHAR(10)
      ,  @c_Storerkey      NVARCHAR(15)
      ,  @c_ColName01      NVARCHAR(30) = ''  OUTPUT 
      ,  @c_ColTitle01     NVARCHAR(60) = ''  OUTPUT
      ,  @c_ColName02      NVARCHAR(30) = ''  OUTPUT  
      ,  @c_ColTitle02     NVARCHAR(60) = ''  OUTPUT 
      ,  @c_ColName03      NVARCHAR(30) = ''  OUTPUT  
      ,  @c_ColTitle03     NVARCHAR(60) = ''  OUTPUT 
      ,  @c_ColName04      NVARCHAR(30) = ''  OUTPUT  
      ,  @c_ColTitle04     NVARCHAR(60) = ''  OUTPUT 
      ,  @c_ColName05      NVARCHAR(30) = ''  OUTPUT  
      ,  @c_ColTitle05     NVARCHAR(60) = ''  OUTPUT 
      ,  @c_ColName06      NVARCHAR(30) = ''  OUTPUT  
      ,  @c_ColTitle06     NVARCHAR(60) = ''  OUTPUT
      ,  @c_ColName07      NVARCHAR(30) = ''  OUTPUT   
      ,  @c_ColTitle07     NVARCHAR(60) = ''  OUTPUT 
      ,  @c_ColName08      NVARCHAR(30) = ''  OUTPUT  
      ,  @c_ColTitle08     NVARCHAR(60) = ''  OUTPUT 
      ,  @c_ColName09      NVARCHAR(30) = ''  OUTPUT  
      ,  @c_ColTitle09     NVARCHAR(60) = ''  OUTPUT 
      ,  @c_ColName10      NVARCHAR(30) = ''  OUTPUT  
      ,  @c_ColTitle10     NVARCHAR(60) = ''  OUTPUT
      )
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_ExecStatement   NVARCHAR(MAX)
         , @c_ExecArguments   NVARCHAR(MAX)

   DECLARE @n_No              INT
         , @n_NoOfTitleSetup  INT         
   DECLARE @c_ColTitle        NVARCHAR(60)
         , @c_ColName         NVARCHAR(30)
         , @c_No              NVARCHAR(5)

   SET @n_No            = 1
   SET @n_NoOfTitleSetup=0
   SET @c_ExecStatement = ''
   SET @c_ExecArguments = ''
   SET @c_ColTitle      = ''
   SET @c_ColName       = ''
   SET @c_No            = ''

   SELECT @n_NoOfTitleSetup = COUNT(1)
   FROM  CODELKUP CL WITH (NOLOCK)
   WHERE CL.ListName = @c_ListName
   AND   CL.Storerkey= @c_Storerkey

   IF @n_NoOfTitleSetup = 0 GOTO QUIT

   DECLARE C_COLDESCR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT CL.Code
         ,CL.Description
         ,1
   FROM  CODELKUP CL WITH (NOLOCK)
   WHERE CL.ListName = @c_ListName
   AND   CL.Storerkey= @c_Storerkey
   AND   CL.Code IN (@c_ColName01, @c_ColName02, @c_ColName03, @c_ColName04, @c_ColName05
                    ,@c_ColName06, @c_ColName07, @c_ColName08, @c_ColName09, @c_ColName10)
   ORDER BY CL.Code
   
   OPEN C_COLDESCR 

   FETCH NEXT FROM C_COLDESCR INTO @c_ColName, @c_ColTitle, @n_NoOfTitleSetup
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @c_No = RIGHT('0' + CONVERT(VARCHAR(2), @n_No),2)


      SET @c_ExecStatement = ''
      SET @c_ExecStatement = N'SET @c_ColName' + @c_No + '= @c_ColName'
                           + ' SET @c_ColTitle'+ @c_No + '= @c_ColTitle'

      SET @c_ExecArguments = N'@c_ColName       NVARCHAR(30)'
                           + ',@c_ColTitle      NVARCHAR(60)'
                           + ',@c_ColName01     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle01    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName02     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle02    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName03     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle03    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName04     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle04    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName05     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle05    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName06     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle06    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName07     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle07    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName08     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle08    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName09     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle09    NVARCHAR(60) OUTPUT'
                           + ',@c_ColName10     NVARCHAR(30) OUTPUT'
                           + ',@c_ColTitle10    NVARCHAR(60) OUTPUT'
                        

      EXEC sp_ExecuteSql @c_ExecStatement 
                       , @c_ExecArguments 
                       , @c_ColName
                       , @c_ColTitle
                       , @c_ColName01     OUTPUT
                       , @c_ColTitle01    OUTPUT
                       , @c_ColName02     OUTPUT
                       , @c_ColTitle02    OUTPUT
                       , @c_ColName03     OUTPUT
                       , @c_ColTitle03    OUTPUT
                       , @c_ColName04     OUTPUT
                       , @c_ColTitle04    OUTPUT
                       , @c_ColName05     OUTPUT
                       , @c_ColTitle05    OUTPUT
                       , @c_ColName06     OUTPUT
                       , @c_ColTitle06    OUTPUT
                       , @c_ColName07     OUTPUT
                       , @c_ColTitle07    OUTPUT
                       , @c_ColName08     OUTPUT
                       , @c_ColTitle08    OUTPUT
                       , @c_ColName09     OUTPUT
                       , @c_ColTitle09    OUTPUT
                       , @c_ColName10     OUTPUT
                       , @c_ColTitle10    OUTPUT

      SET @n_No = @n_No + 1
      FETCH NEXT FROM C_COLDESCR INTO @c_ColName, @c_ColTitle, @n_NoOfTitleSetup
   END 
   CLOSE C_COLDESCR
   DEALLOCATE C_COLDESCR

   QUIT:
   WHILE @n_No <= 10 
   BEGIN
      SET @c_No = RIGHT('0' + CONVERT(NVARCHAR(2), @n_No),2)

      SET @c_ExecStatement = ''
      SET @c_ExecStatement = N'SET @c_ColName' + @c_No + '= '''''

      SET @c_ExecArguments = N'@c_ColName01     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName02     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName03     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName04     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName05     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName06     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName07     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName08     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName09     NVARCHAR(30) OUTPUT'
                           + ',@c_ColName10     NVARCHAR(30) OUTPUT'

      EXEC sp_ExecuteSql @c_ExecStatement 
                       , @c_ExecArguments  
                       , @c_ColName01     OUTPUT
                       , @c_ColName02     OUTPUT
                       , @c_ColName03     OUTPUT
                       , @c_ColName04     OUTPUT
                       , @c_ColName05     OUTPUT
                       , @c_ColName06     OUTPUT
                       , @c_ColName07     OUTPUT
                       , @c_ColName08     OUTPUT
                       , @c_ColName09     OUTPUT
                       , @c_ColName10     OUTPUT

      SET @n_No = @n_No + 1
   END
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

GRANT EXEC ON isp_GetColumnTitle TO nSQL