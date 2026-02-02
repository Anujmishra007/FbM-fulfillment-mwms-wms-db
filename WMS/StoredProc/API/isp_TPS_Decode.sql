SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_TPS_Decode                                            */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2021-09-22   1.0  Chermaine  Created                                       */
/* 2022-02-15   1.1  yeekung    WMS-17771 correct storerkey                   */ 
/* 2025-01-17   1.2  yeekung    UWP-28861 Add facility (yeekung01)            */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_Decode] (
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
   DECLARE @cDecodeSP   NVARCHAR( 20)
   DECLARE @cSQL        NVARCHAR (MAX)
   DECLARE @cSQLParam   NVARCHAR (MAX)
   DECLARE @cBarcode    NVARCHAR (20)
   DECLARE @cFacility   NVARCHAR (5)

   --Decode Json Format
   SELECT @cStorerKey = StorerKey,
         @cBarcode = Barcode,
         @cFacility = Facility
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Barcode     NVARCHAR ( 20),
      Facility    NVARCHAR ( 5)  
   )

   EXEC nspGetRight    
         @c_Facility   = @cFacility
      ,  @c_StorerKey  = @cStorerKey   
      ,  @c_sku        = ''    
      ,  @c_ConfigKey  = 'TPS-DecodeSP'    
      ,  @b_Success    = @b_Success       OUTPUT    
      ,  @c_authority  = @cDecodeSP       OUTPUT    
      ,  @n_err        = @n_Err           OUTPUT    
      ,  @c_errmsg     = @c_ErrMsg        OUTPUT  

   IF ISNULL(@cDecodeSP,'') NOT IN ('','0')
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC API.' + RTRIM( @cDecodeSP) +
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
      ELSE
      BEGIN
         SET @n_Err = 400000
         SET @c_ErrMsg = 'InvalidDecodeSP'

         SET @jResult = (SELECT '' AS SKU
         FOR JSON PATH,INCLUDE_NULL_VALUES )    
         SET @b_Success = 0
      END
   END
   ELSE
   BEGIN
      SET @n_Err = 0
      SET @c_ErrMsg = ''-- 'DecodeSPNotNull'
      SET @jResult = (SELECT @cBarcode AS SKU, 1 AS QTY
            FOR JSON PATH,INCLUDE_NULL_VALUES )   
      SET @b_Success = 1
   END
END


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_Decode TO NSQL
GO


