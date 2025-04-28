SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidate                                       */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2021-09-22   1.0  YeeKung  Created                                         */
/* 2025-01-03   1.1  YeeKung  UWP-28822 Add Facility (yeekung01)              */
/******************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPS_ExtValidate] (
	@json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) OUTPUT,
   @b_Success  INT = 1        OUTPUT,
   @n_Err      INT = 0        OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE @cStorerKey  NVARCHAR( 15)
   DECLARE @cFacility   NVARCHAR( 5)
   DECLARE @cExtValidSP  NVARCHAR( 20)
   DECLARE @cSQL        NVARCHAR (MAX)
   DECLARE @cSQLParam   NVARCHAR (MAX)

   --Decode Json Format
   SELECT   @cStorerKey = StorerKey,
            @cFacility  = Facility 
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Facility    NVARCHAR ( 5)
   )

   EXEC nspGetRight    
         @c_Facility   = @cFacility
      ,  @c_StorerKey  = @cStorerKey   
      ,  @c_sku        = ''    
      ,  @c_ConfigKey  = 'TPS-ExtValidSP'    
      ,  @b_Success    = @b_Success       OUTPUT    
      ,  @c_authority  = @cExtValidSP     OUTPUT    
      ,  @n_err        = @n_Err           OUTPUT    
      ,  @c_errmsg     = @c_ErrMsg        OUTPUT  

   IF ISNULL(@cExtValidSP,'') NOT IN ('0','')
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtValidSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC API.' + RTRIM( @cExtValidSP) +
            ' @json, @jResult OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT '
         SET @cSQLParam =
            ' @json          NVARCHAR( MAX),  ' +
            ' @jResult       NVARCHAR( MAX) OUTPUT, ' +
            ' @b_Success     INT = 1        OUTPUT, ' +
            ' @n_Err         INT = 0        OUTPUT, ' +
            ' @c_ErrMsg      NVARCHAR( 255) OUTPUT '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @json, @jResult OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
      END
   END
   ELSE
   BEGIN
      SET @jResult = @json
      SET @b_Success = 1
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtValidate TO NSQL
GO
