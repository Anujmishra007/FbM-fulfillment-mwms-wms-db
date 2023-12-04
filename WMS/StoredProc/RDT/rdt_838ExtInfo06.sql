SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_838ExtInfo06                                    */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 14-11-2023 1.0 yeekung     WMS-23946 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtInfo06] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @tVar           VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE @nSKUWeight Float
   DECLARE @nTTlSKUWeight Float = 0
   DECLARE @nMaxCtnWeight Float
   DECLARE @nCtnWeight Float
   DECLARE @cDefaultcartontype NVARCHAR(20)
   DECLARE @cPackSKU NVARCHAR(20)
   DECLARE @nPackQTY  INT
   DECLARE @nQTY       INT

   DECLARE @nCartonNo       NVARCHAR( 10),
            @cPickSlipNo    NVARCHAR( 10),
            @cSKU           NVARCHAR( 20)

   -- Table mapping
   SELECT @cPickSlipNo = Value FROM @tVar WHERE Variable = '@cPickSlipNo'
   SELECT @nCartonNo = Value FROM @tVar WHERE Variable = '@nCartonNo'
   SELECT @nQTY = Value FROM @tVar WHERE Variable = '@nQTY'
   SELECT @cSKU = Value FROM @tVar WHERE Variable = '@cSKU'

   IF @nFunc = 838 -- Pack
   BEGIN
      IF 3 IN (@nStep, @nAfterStep) -- SKU QTY
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN

            SET @cDefaultcartontype=rdt.RDTGetConfig( @nFunc, 'DefaultCartonType', @cStorerKey)  --(cc01)  
            IF @cDefaultcartontype = '0'    
               SET @cDefaultcartontype = ''   

            IF ISNULL(@cDefaultcartontype,'') <>''
            BEGIN
               SELECT   @nMaxCtnWeight = MaxWeight,
                        @nCtnWeight = CartonWeight
               FROM cartonization
               WHERE CartonType = @cDefaultcartontype

               DECLARE CurPDtl CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
               SELECT SKU,QTY
               FROM Packdetail (NOLOCK)
               Where PickSlipNo = @cPickslipNo
                  AND CartonNo = @nCartonNo
                  AND Storerkey = @cStorerKey
               OPEN CurPDtl  
               FETCH NEXT FROM CurPDtl INTO @cPackSKU, @nPackQTY  
               WHILE @@FETCH_STATUS = 0  
               BEGIN  
                  SELECT @nTTlSKUWeight = stdgrosswgt*@nPackQTY
                  FROM SKU (NOLOCK)
                  WHERE SKU = @cPackSKU
                     AND Storerkey = @cStorerKey

                  FETCH NEXT FROM CurPDtl INTO @cPackSKU, @nPackQTY
               END

               SET @nTTlSKUWeight = @nTTlSKUWeight 

               IF  @nTTlSKUWeight > @nMaxCtnWeight
               BEGIN
                  SET @cExtendedInfo ='Weight exceeds limit'
               END
               ELSE IF @nTTlSKUWeight = @nMaxCtnWeight
               BEGIN
                  SET @cExtendedInfo ='Weight reached limit'
               END


            END
         END
      END
         
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_838ExtInfo06] TO [NSQL]
GO
