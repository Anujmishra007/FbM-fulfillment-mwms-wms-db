if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_838CapPackInfo01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_838CapPackInfo01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_838CapPackInfo01                                */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: ForeverNew need custom capture tagloop info                 */
/*                                                                      */
/* Called from: rdtfnc_Pack                                             */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 2024-05-21  1.0  Cuize    FCR-185   Capture Tagloop                  */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838CapPackInfo01] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipNo   NVARCHAR( 10),
   @cDropID       NVARCHAR( 20),
   @nCartonNo     INT,
   @cLabelNo      NVARCHAR( 20),
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT,
   @cPackInfo     NVARCHAR( 3)  OUTPUT,
   @cWeight       NVARCHAR( 10) OUTPUT,
   @cCube         NVARCHAR( 10) OUTPUT,
   @cRefNo        NVARCHAR( 20) OUTPUT,
   @cCartonType   NVARCHAR( 10) OUTPUT

) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 838
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE @cDisablePackRef   NVARCHAR(20)
            DECLARE @cUserDefine03     NVARCHAR(20)
            DECLARE @cUserDefine04     NVARCHAR(20)
            DECLARE @cSKU              NVARCHAR(20)

            SELECT @cSKU = I_Field03
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile

            SELECT TOP 1 @cPackInfo = ISNULL(ConfigDesc, '')
            FROM RDT.StorerConfig WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
              AND ConfigKey = 'CapturePackInfoSP'
              AND Function_ID = @nFunc

            IF (@cPackInfo = '')
               GOTO Quit

            SET @cDisablePackRef = rdt.RDTGetConfig( @nFunc, 'DisablePackRef', @cStorerkey)

            IF (rdt.RDTGetConfig( @nFunc, 'DisablePackRef', @cStorerkey) <> '')
            BEGIN
               SELECT TOP 1
                  @cUserDefine03 = OD.UserDefine03,
                  @cUserDefine04 = OD.UserDefine04
               FROM PICKHEADER PH WITH (NOLOCK)
                       INNER JOIN ORDERDETAIL OD WITH (NOLOCK)
                                  ON PH.OrderKey = OD.OrderKey
               WHERE PH.PickHeaderKey = @cPickSlipNo
                 AND OD.Sku = @cSKU

               IF (@cUserDefine03 <> 'TagLoopID') OR ( @cUserDefine04 <> 'Y')
                  SET @cPackInfo = REPLACE(@cPackInfo, @cDisablePackRef, '')

            END
         END
      END
   END


   Quit:
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838CapPackInfo01 TO NSQL
GO
