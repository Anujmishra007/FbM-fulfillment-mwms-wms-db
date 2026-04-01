LP26011601
 
DE003 VIVOCART1  1 0000030198_2
30002P4B
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/
/* Store procedure: rdt_839ExtValidSP16                                 */
/* Copyright      : Maersk                                              */
/* Customer       : PAGEIND                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-01-04 1.0  NickT      FCR-9040. Created                         */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_839ExtValidSP16] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5) ,
   @cStorerKey   NVARCHAR( 15),
   @cType        NVARCHAR( 10),
   @cPickSlipNo  NVARCHAR( 10),
   @cPickZone    NVARCHAR( 10),
   @cDropID      NVARCHAR( 20),
   @cLOC         NVARCHAR( 10),
   @cSKU         NVARCHAR( 20),
   @nQTY         INT,
   @cPackData1   NVARCHAR( 30),
   @cPackData2   NVARCHAR( 30),
   @cPackData3   NVARCHAR( 30),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   IF @nFunc = 839
   BEGIN
      IF @nStep = 1
      BEGIN
         IF NOT EXISTS(SELECT 1 
                  FROM dbo.PickHeader PH WITH(NOLOCK)
                  INNER JOIN dbo.WaveDetail WD WITH(NOLOCK) ON PH.WaveKey = WD.WaveKey
                  INNER JOIN dbo.OrderDetail ORD WITH(NOLOCK) ON PH.StorerKey = ORD.StorerKey AND WD.OrderKey = ORD.OrderKey
                  INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON ORD.StorerKey = PD.StorerKey AND ORD.OrderKey = PD.OrderKey AND ORD.OrderLineNumber = PD.OrderLineNumber
                  WHERE PH.PickHeaderKey = @cPickSlipNo 
                     AND PH.StorerKey = @cStorerkey
                     AND PD.Status = '0')
         BEGIN
            SET @nErrNo = 255301
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No open task
            GOTO Quit
         END
         IF EXISTS(SELECT 1 
                  FROM dbo.PickHeader PH WITH(NOLOCK)
                  INNER JOIN dbo.WaveDetail WD WITH(NOLOCK) ON PH.WaveKey = WD.WaveKey
                  INNER JOIN dbo.Orders ORM WITH(NOLOCK) ON PH.StorerKey = ORM.StorerKey AND WD.OrderKey = ORM.OrderKey
                  WHERE PH.PickHeaderKey = @cPickSlipNo 
                     AND PH.StorerKey = @cStorerkey
                     AND ORM.SOStatus = 'CANC'
                  )
         BEGIN
            SET @nErrNo = 255302
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cancelled order is found
            GOTO Quit
         END
      END
      ELSE IF @nStep = 2
      BEGIN
         DECLARE @cDropIDScn NVARCHAR( 20)
         SELECT TOP 1 @cDropIDScn = C_String5
         FROM rdt.RDTMOBREC WITH(NOLOCK)
         WHERE Mobile = @nMobile
         IF @cDropIDScn = 'PickZoneScn'
         BEGIN
            IF ISNULL(@cDropID, '') = ''
            BEGIN
               SET @nErrNo = 255303
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID cannot be empty
               GOTO Quit
            END
            DECLARE @cListFacility NVARCHAR(5) = ''
            DECLARE @iMatch   INT = 0
            DECLARE @cPattern NVARCHAR(250) = ''
            DECLARE @cCode    NVARCHAR(30) = ''
            SET @iMatch = 1 -- True
            SET @cCode = RTRIM( CAST( @nFunc AS NVARCHAR(5))) + '-DropID' 
            SELECT @cListFacility = code2,
                  @cPattern = ISNULL( Long, '')
            FROM CodeLkup WITH (NOLOCK) 
            WHERE ListName = 'DRIDFormat' 
               AND Code = @cCode 
               AND StorerKey = @cStorerKey
            IF @@ROWCOUNT > 1 OR                               -- Multi record means facility config exist or  
               (@cListFacility <> '' AND @cListFacility IS NOT NULL)   -- Single record with facility config  
            BEGIN 
               -- Retrieve own facility config  
               IF @cFacility <> @cListFacility  
               BEGIN   
                  -- Get config by facility, then by storer  
                  SET @cPattern = ''
                  SELECT @cPattern = ISNULL( Long, '')
                  FROM CodeLkup WITH (NOLOCK) 
                  WHERE ListName = 'DRIDFormat' 
                     AND Code = @cCode 
                     AND StorerKey = @cStorerKey
                     AND (code2 = '' OR code2 = @cFacility) 
               END
            END
            
            IF ISNULL(@cPattern, '') <> ''
            BEGIN
               SELECT @iMatch = master.dbo.RegExIsMatch( @cPattern, @cDropID, 0) -- 0=RegexOptions.None
               IF @iMatch = 0
               BEGIN
                  SET @nErrNo = 255305
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid DropID format
                  GOTO Quit
               END
            END
            IF EXISTS(SELECT 1 FROM rdt.rdtPickLog WITH(NOLOCK) WHERE DropID = @cDropID)
            BEGIN
               SET @nErrNo = 255304
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID is in use
               GOTO Quit
            END
         END
      END
   END
END
QUIT:
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_839ExtValidSP16] TO [NSQL]
GO
 