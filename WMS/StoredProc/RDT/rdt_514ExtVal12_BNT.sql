SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************/
/* Store procedure: rdt_514ExtValid12                                  */
/* Purpose: Move By UCC Extended Validate                                */
/*                                                                      */
/* Called from: rdtfnc_Move_ID                                          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-12-24  1.0  ASC199    on pick loc UCC Move allow for same sku only  */
/************************************************************************/

CREATE or ALTER   PROC [RDT].[rdt_514ExtVal12_BNT] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cToID          NVARCHAR( 18),
   @cToLoc         NVARCHAR( 10),
   @cFromLoc       NVARCHAR( 10),
   @cFromID        NVARCHAR( 18),
   @cUCC           NVARCHAR( 20),
   @cUCC1          NVARCHAR( 20),
   @cUCC2          NVARCHAR( 20),
   @cUCC3          NVARCHAR( 20),
   @cUCC4          NVARCHAR( 20),
   @cUCC5          NVARCHAR( 20),
   @cUCC6          NVARCHAR( 20),
   @cUCC7          NVARCHAR( 20),
   @cUCC8          NVARCHAR( 20),
   @cUCC9          NVARCHAR( 20),
   @nErrNo         INT           OUTPUT, 
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFacility   NVARCHAR( 5)
   DECLARE @nSku NVARCHAR( 20)
   DECLARE @nmaxSku  NVARCHAR( 20)
    DECLARE @nmaxqty  INT
	DECLARE @nmaxqtylimit int
   DECLARE @nloc     NVARCHAR( 10)

   SET @nErrNo = 0

   SELECT @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

    IF (@cUCC ='' OR @cUCC IS NULL)
   BEGIN
   SELECT @cUCC = V_String1
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile
   END

   IF @nFunc = 514
   BEGIN
      IF @nStep = 2
      BEGIN
         IF @nInputKey = 1

		  IF EXISTS ( SELECT 1 FROM dbo.loc WITH (NOLOCK)
                        WHERE LOC = @cToLOC
                           AND Facility = @cFacility
                           AND LocationType in( 'CASE','BULK')) 
		BEGIN
		if (@cToID ='')
		BEGIN
		 SET @nErrNo = 255501
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --255501^ID is blank            
		END
		END
		ELSE IF EXISTS ( SELECT 1 FROM dbo.loc WITH (NOLOCK)
                        WHERE LOC = @cToLOC
                           AND Facility = @cFacility
                           AND LocationType = 'PICK') 
         
         BEGIN

	 select @nSku= SKU  from dbo.skuxloc WITH (NOLOCK)
                        WHERE LOC = @cToLOC
                           AND StorerKey = @cStorerKey
                           AND LocationType = ''
						   AND Qty > 0
						   if (@nSku <>'')
						   BEGIN
						  SET @nErrNo = 255502
						  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --255502 Different SKU in PICK location
						  GOTO Quit
						  END

		 select @nSku= SKU, @nmaxqtylimit= (QtyLocationLimit-Qty) from dbo.skuxloc WITH (NOLOCK)
                        WHERE LOC = @cToLOC
                           AND StorerKey = @cStorerKey
                           AND LocationType = 'PICK'
		select @nmaxSku=sku, @nmaxqty=qty from dbo.ucc  WITH (NOLOCK)
						 WHERE UCCNo = @cUCC
                           AND StorerKey = @cStorerKey

		if (@nSku = @nmaxSku AND @nSku <>'' AND @nmaxqtylimit < @nmaxqty)
		BEGIN
		 SET @nErrNo = 255503
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --255503^OVER UCC QTY
            GOTO Quit
		END

		if (@nSku <> @nmaxSku AND @nSku <>'')
			 BEGIN
            SET @nErrNo = 255504
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --255504^Over MaxSku
            GOTO Quit
			END
		END
	END
END
	Quit:
END
GO
GRANT EXECUTE ON  [dbo].[rdt_514ExtVal12_BNT] TO [NSQL]
GO

           
