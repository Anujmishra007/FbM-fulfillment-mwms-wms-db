if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_867DecodeSP01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_867DecodeSP01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_867DecodeSP01                                   */
/*                                                                      */
/* Purpose: Decode PickDetail.DropID return OrderKey                    */
/*                                                                      */
/* Called from: rdtfnc_PickByTrackNo                                    */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2020-05-22  1.0  James      WMS-13481. Created                       */
/************************************************************************/

CREATE PROC [RDT].[rdt_867DecodeSP01] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cBarcode     NVARCHAR( 60),
   @cSKU         NVARCHAR( 20),    
   @cTracKNo     NVARCHAR( 18),   
   @cSerialNo    NVARCHAR( 30),
   @cOrderKey    NVARCHAR( 10)  OUTPUT,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 867 -- Pick To Drop ID  
   BEGIN  
      IF @nStep = 1 -- OrderKey
      BEGIN  
         IF @nInputKey = 1 -- ENTER  
         BEGIN  
            IF @cBarcode <> ''  
            BEGIN  
               SET @cOrderKey = ''
               SELECT TOP 1 @cOrderKey = OrderKey
               FROM dbo.PICKDETAIL WITH (NOLOCK)
               WHERE Storerkey = @cStorerKey
               AND   DropID = @cBarcode
               AND   [Status] = '0'
               ORDER BY 1
            END
         END
      END
   END
         
   Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_867DecodeSP01 TO NSQL
GO