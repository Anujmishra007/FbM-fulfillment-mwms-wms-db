SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



/******************************************************************************/
/* Store procedure: isp_SkipCartonizeSP01                                     */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2021-08-28   1.0  Chermaine  Created                                       */
/* 2024-02-12   1.1  YeeKung    FCR-1515  Add Option2 (yeekung01)             */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_SkipCartonizeSP01] (
   @cStorerKey    NVARCHAR( 15),
   @cFacility     NVARCHAR( 5),
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @cPickslipNo   NVARCHAR( 20),
   @cDropID       NVARCHAR( 20),
   @cOrderKey     NVARCHAR( 10),
   @skipCartonize NVARCHAR( 1) OUTPUT,
   @b_Success     INT = 1      OUTPUT,
   @n_Err         INT = 0      OUTPUT,
   @c_ErrMsg      NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

BEGIN
	IF @cOrderKey <> ''
	BEGIN
      DECLARE @cUDF02 NVARCHAR(20)

      SELECT @cUDF02 = Option2
      FROM StorerConfig (NOLOCK)
      WHERE Storerkey = @cStorerkey
         AND (Facility = @cFacility OR Facility = '')
         AND Configkey = 'TPS-skipCartonize'


		IF EXISTS (SELECT 1 FROM Orders WITH (NOLOCK) WHERE storerKey = @cStorerKey AND Orderkey = @cOrderKey AND TYPE = @cUDF02)
	   BEGIN
		   SET @skipCartonize = '0'
	   END
	   ELSE
	   BEGIN
		   SET @skipCartonize = '1'
	   END
	END
END


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_SkipCartonizeSP01 TO NSQL
GO


