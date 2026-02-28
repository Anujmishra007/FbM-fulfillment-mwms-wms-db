SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/************************************************************************/  
/* Store procedure: rdt_1864ExtVLT_JCB                                  */  
/*                                                                      */  
/* Purpose:       JCB validate the pick from VNA goes to OutboundP&D    */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2024-08-26 1.0  TPT001     Pick validate VNA and WA                  */  
/************************************************************************/  
CREATE OR ALTER PROCEDURE [RDT].[rdt_1864ExtVLT_JCB]
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipNo   NVARCHAR( 10),
   @cPickZone     NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20),
   @nTaskQTY      INT,
   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE	@Path	NVARCHAR(3),
            @ToLoc	NVARCHAR(10)
 
 
   IF @nFunc = 1864
   BEGIN
		--Step 5 Confirm ToLocation
      IF @nStep = 5
      BEGIN
	  -- Look if VNA or WideAisle location used
	  SELECT @Path = CASE WHEN LEN(LocationGroup)=0 THEN 'WA' ELSE 'VNA' END FROM dbo.Loc WITH(NOLOCK) WHERE Facility=@cFacility AND Loc=@cLOC
		--VNA path
         IF @Path = 'VNA'
         BEGIN
		 --Get PnD outbound for this particular VNA
            SELECT @ToLoc=LocationGroup FROM dbo.Loc WITH(NOLOCK) WHERE Facility=@cFacility and [Status]='OK' AND LEN(LocationGroup)>0 and Loc=@cLOC
            IF @cLoc<>@ToLoc
            BEGIN
				SET @nErrNo = 68784
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BAD Location 
				GOTO Quit
            END
			ELSE 
			BEGIN
			   GOTO Quit
			END
         END
		 --WideAisle path
		 ELSE
		 BEGIN
		 --Get outbound assigned lane
		    SELECT @ToLoc=M.OtherReference 
			FROM dbo.MBOL M WITH(NOLOCK)
			   INNER JOIN MBOLDETAIL MD WITH (NOLOCK) 
			      ON (M.MBOLkey = MD.MBOLkey)  
			   INNER JOIN ORDERS O WITH (NOLOCK) 
			      ON (MD.Orderkey = O.Orderkey)
			   INNER JOIN dbo.OrderDetail OD WITH(NOLOCK)
			      ON O.OrderKey=OD.OrderKey 
			   INNER JOIN dbo.PICKDETAIL PD WITH(NOLOCK)
			      ON OD.OrderKey=PD.OrderKey 
				  AND OD.OrderLineNumber=PD.OrderLineNumber
			WHERE PD.ID=@cID and O.StorerKey=@cStorerKey
			--lane not assigned
			IF (@ToLoc='' OR @ToLoc IS NULL)
			BEGIN
				SET @nErrNo = 72897
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --72897^No Location   
				GOTO Quit	
			END
			--lane assigned but not correct
			IF @cLoc<>@ToLoc
            BEGIN
				SET @nErrNo = 68784
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BAD Location
				GOTO Quit				
            END
		 END
      END
	END
Quit:	
END
GO
GRANT EXECUTE ON rdt_1864ExtVLT_JCB TO NSQL
GO
