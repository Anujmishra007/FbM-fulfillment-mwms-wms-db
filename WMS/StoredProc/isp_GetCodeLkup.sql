IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetCodeLkup]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetCodeLkup]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- 2018-08-06 created ===============================================
-- Author   : KHLim
-- Date       Author   Ver Purpose
-- ==================================================================
CREATE  PROC  [dbo].[isp_GetCodeLkup]
   @LISTNAME  NVARCHAR(30) ,@StorerKey NVARCHAR(15)
  ,@Code      NVARCHAR(30) ,@code2     NVARCHAR(30) 
  ,@ErrMsg    NVARCHAR(250) = '' OUTPUT  ,@Err       INT = 0 OUTPUT ,@Description NVARCHAR(250) OUTPUT
  ,@Short     NVARCHAR(10)  = '' OUTPUT  ,@Long      NVARCHAR(250) = '' OUTPUT
  ,@Notes     NVARCHAR(4000)= '' OUTPUT  ,@Notes2    NVARCHAR(4000)= '' OUTPUT
  ,@UDF01     NVARCHAR(60)  = '' OUTPUT  ,@UDF02     NVARCHAR(60)  = '' OUTPUT ,@UDF03   NVARCHAR(60) = '' OUTPUT ,@UDF04 NVARCHAR(60) = '' OUTPUT ,@UDF05 NVARCHAR(60) = '' OUTPUT
AS    
BEGIN    
   SET NOCOUNT ON       ;   SET ANSI_NULLS OFF  ;   SET QUOTED_IDENTIFIER OFF;   SET CONCAT_NULL_YIELDS_NULL OFF;

   DECLARE @Proc  NVARCHAR(128)  , @Start DATETIME   , @Duration INT, @Stmt NVARCHAR(max)
   --BEGIN TRY
      SELECT TOP 1 
  @LISTNAME   =LISTNAME
, @Code       =Code
, @Description=[Description]
, @Short      =Short
, @Long       =Long
, @Notes      =Notes
, @Notes2     =Notes2
, @Storerkey  =Storerkey
, @UDF01      =UDF01
, @UDF02      =UDF02
, @UDF03      =UDF03
, @UDF04      =UDF04
, @UDF05      =UDF05
      FROM CODELKUP WITH (nolock) 
WHERE Code = @Code  AND Listname = @LISTNAME
AND   code2= @code2 AND StorerKey = @StorerKey
ORDER BY EditDate DESC

   --END TRY
   --BEGIN CATCH
      --EXEC dbo.ispLogError @DB, @Schema, @Proc, @Id, @ErrMsg OUTPUT, @Err OUTPUT, @Success OUTPUT
   --END CATCH
   --SET @Duration = DATEDIFF(s,@Start,GETDATE())
   --IF @Err <> 0
   --   EXEC dbo.ispLogSQL   @DB, @Schema, @Proc, @Id, @Stmt, @Duration

   SELECT @Description=ISNULL(@Description,''), @Short=ISNULL(@Short,''), @Long=ISNULL(@Long, ''), @Notes=ISNULL(@Notes, ''), @Notes2=ISNULL(@Notes2, '')
      , @UDF01=ISNULL(@UDF01, ''), @UDF02=ISNULL(@UDF02, ''), @UDF03=ISNULL(@UDF03, ''), @UDF04=ISNULL(@UDF04, ''), @UDF05=ISNULL(@UDF05, '')

END
GO
GRANT EXECUTE ON [dbo].[isp_GetCodeLkup] TO nSQL 
GO
