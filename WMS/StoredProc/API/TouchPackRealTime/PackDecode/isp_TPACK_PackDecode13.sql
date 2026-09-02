SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PackDecode13                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Pack Decode Logic for SG Logitech                            */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-17   1.0  GCH225     UWP-27857: Created                               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode13] (
	  @cType             NVARCHAR(30)      = ''
   , @bIsDiscrete       BIT               = 0
   , @bIsCustom         BIT               = 0
   , @cPickSlipNo       NVARCHAR(10)      = ''
   , @cOrderKey         NVARCHAR(10)      = ''
   , @cLoadKey          NVARCHAR(10)      = ''
   , @cDropID           NVARCHAR(20)      = ''
   , @cStorerKey        NVARCHAR(15)      = ''
   , @cFacility         NVARCHAR(5)       = ''
   , @cInputValue1      NVARCHAR(128)     = ''
   , @cInputValue2      NVARCHAR(MAX)     = ''  OUTPUT
   , @cInputValue3      NVARCHAR(128)     = ''  OUTPUT
   , @c_UserID          NVARCHAR(256)     = ''
   , @cLangCode         NVARCHAR(3)       = ''
   , @cSKU              NVARCHAR(20)      = ''  OUTPUT
   , @nQty              INT                     OUTPUT
   , @b_Success         INT               = 0   OUTPUT
   , @n_ErrNo           INT               = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @cSerialNo      NVARCHAR(50)

   SET @b_Success       = 0
   SET @cSerialNo       = ''

   SET @cSKU = RTRIM(LEFT(@cInputValue1, CHARINDEX(CHAR(9), @cInputValue1) - 1));
   SET @cSerialNo = UPPER(LTRIM(SUBSTRING(@cInputValue1,CHARINDEX(CHAR(9), @cInputValue1) + 1,LEN(@cInputValue1)))) ;
   
   SET @cInputValue2 = '[' +  @cSerialNo + ']'
   SET @cInputValue3 = ''
   SET @b_Success = 1

QUIT:
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_PackDecode13] TO NSQL
GO