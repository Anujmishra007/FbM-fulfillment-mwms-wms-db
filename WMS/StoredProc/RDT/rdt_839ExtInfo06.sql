IF EXISTS (SELECT * FROM sys.objects WHERE Object_ID = OBJECT_ID(N'[RDT].[rdt_839ExtInfo06]') AND OBJECTPROPERTY(object_id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_839ExtInfo06]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/  
/* Store procedure: rdt_839ExtInfo06                                    */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2020-11-10 1.0  James      WMS-15538 Created                         */  
/************************************************************************/  
  
CREATE PROC rdt.rdt_839ExtInfo06 (  
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,       
   @nAfterStep   INT,    
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5) , 
   @cStorerKey   NVARCHAR( 15), 
   @cType        NVARCHAR( 10), 
   @cPickSlipNo  NVARCHAR( 10), 
   @cPickZone    NVARCHAR( 1),  
   @cDropID      NVARCHAR( 20), 
   @cLOC         NVARCHAR( 10), 
   @cSKU         NVARCHAR( 20), 
   @nQTY         INT,           
   @nActQty      INT,
   @nSuggQTY     INT,
   @cExtendedInfo NVARCHAR(20) OUTPUT, 
   @nErrNo       INT           OUTPUT, 
   @cErrMsg      NVARCHAR(250) OUTPUT  
)  
AS  

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cID         NVARCHAR( 18)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)  
   DECLARE @ccurPD      CURSOR
   DECLARE @nPD_Qty     INT
   
   -- Get storer config  
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)  
   IF @cPickConfirmStatus = '0'  
      SET @cPickConfirmStatus = '5'  

   SET @cExtendedInfo = ''

   IF @nStep IN ( 3) OR @nAfterStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF LEFT(@cPickSlipNo, 1) = 'P'
         BEGIN
            SET @ccurPD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT RIGHT(RTRIM(PD.ID),3), ISNULL( SUM( PD.Qty), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE EXISTS ( SELECT 1 FROM dbo.PICKHEADER PH WITH (NOLOCK) 
                           WHERE PD.OrderKey = PH.OrderKey 
                           AND   PH.PickHeaderKey = @cPickSlipNo)
            AND   PD.Loc = @cLOC
            AND   PD.Sku = @cSKU
            AND   PD.[Status] < @cPickConfirmStatus
            AND   PD.QTY > 0  
            AND   PD.Status <> '4'  
            GROUP BY RIGHT(RTRIM(PD.ID),3)
            ORDER BY RIGHT(RTRIM(PD.ID),3)
            OPEN @ccurPD
            FETCH NEXT FROM @ccurPD INTO @cID, @nPD_Qty
            WHILE @@FETCH_STATUS = 0
            BEGIN
               SET @cExtendedInfo = @cExtendedInfo + RTRIM( @cID) + ':' + 
                                    RTRIM( CAST( @nPD_Qty AS NVARCHAR( 4))) + '/'
               
               FETCH NEXT FROM @ccurPD INTO @cID, @nPD_Qty
            END
         END
 
         IF LEFT(@cPickSlipNo,1) = 'B'
         BEGIN
            SET @ccurPD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT RIGHT(RTRIM(PD.ID),3), ISNULL( SUM( PD.Qty), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND   PD.Loc = @cLOC
            AND   PD.Sku = @cSKU
            AND   PD.[Status] < @cPickConfirmStatus
            AND   PD.QTY > 0  
            AND   PD.Status <> '4'  
            GROUP BY RIGHT(RTRIM(PD.ID),3)
            ORDER BY RIGHT(RTRIM(PD.ID),3)
            OPEN @ccurPD
            FETCH NEXT FROM @ccurPD INTO @cID, @nPD_Qty
            WHILE @@FETCH_STATUS = 0
            BEGIN
               SET @cExtendedInfo = @cExtendedInfo + RTRIM( @cID) + ':' + 
                                    RTRIM( CAST( @nPD_Qty AS NVARCHAR( 4))) + '/'
               
               FETCH NEXT FROM @ccurPD INTO @cID, @nPD_Qty
            END
         END
         
         -- Remove the last '/'
         IF @cExtendedInfo <> ''
            SET @cExtendedInfo = SUBSTRING( @cExtendedInfo, 1, LEN( RTRIM( @cExtendedInfo)) - 1)
      END
   END
  
QUIT:  
 
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_839ExtInfo06 TO NSQL
GO
  
 