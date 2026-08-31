
/************************************************************************/
/* Store procedure: rdt_1641ExtValWAG                                */
/* Purpose: Validate Pallet Build                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-05-22 1.0  JRA432     Created for WAG implementation			*/
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_1641ExtValWAG] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(3),
   @nStep        INT,
   @nInputKey    INT, 
   @cStorerKey   NVARCHAR(15),
   @cDropID      NVARCHAR(20),
   @cUCCNo       NVARCHAR(20),
   @cPrevLoadKey NVARCHAR(10),
   @cParam1      NVARCHAR(20),
   @cParam2      NVARCHAR(20),
   @cParam3      NVARCHAR(20),
   @cParam4      NVARCHAR(20),
   @cParam5      NVARCHAR(20),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

IF @nFunc = 1641

   IF @nStep = 3 AND @nInputKey = 1
   BEGIN
      DECLARE
	     @cUccOrderKey  NVARCHAR(10),
	     @cUccOrderType  NVARCHAR(10),
		 @cUccOrderService NVARCHAR(30),
	     @cUccCarrier  NVARCHAR(30),
		 @cUccConsignee NVARCHAR(30),
		 @cUccMbolKey  NVARCHAR(10),
	     @cPalOrderType  NVARCHAR(10),
		 @cPalMbolKey  NVARCHAR(10),
		 @cPalOrderService NVARCHAR(30),
	     @cPalCarrier  NVARCHAR(30),
		 @cPalConsignee NVARCHAR(30),
		 @DelServiceList NVARCHAR(10) = 'DELSERVICE'
	 
	  --Get Order/Type/Mbol/Delivery Service for the scanned UCC
	  SELECT TOP 1
		 @cUccOrderKey = PD.OrderKey,
		 @cUccOrderType = O.[Type],
		 @cUccOrderService = O.UserDefine02,
		 @cUccMbolKey = O.MbolKey,
		 @cUccConsignee = O.ConsigneeKey
      FROM dbo.PickDetail PD (NOLOCK) 
	  JOIN dbo.Orders O (NOLOCK) ON O.StorerKey = PD.StorerKey AND O.Orderkey = PD.Orderkey
	  WHERE PD.StorerKey = @cStorerKey
	  AND PD.DropId = @cUCCNo

	  IF ISNULL(@cUccMbolKey,'') = ''
	  BEGIN
         SET @nErrNo = 54505
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Mbol
		 GOTO QUIT
      END

	  IF EXISTS (SELECT 1 FROM dbo.Lotxlocxid (NOLOCK)
				WHERE StorerKey = @cStorerKey
				AND ID = @cDropID 
				AND Qty > 0)
	  BEGIN
		  --Get Type/Mbol/Delivery Service for already used for Pallet
		  SELECT TOP 1
			 @cPalOrderType = O.[Type],
			 @cPalMbolKey = O.MbolKey,
			 @cPalOrderService = O.UserDefine02,
			 @cPalConsignee = O.ConsigneeKey
		  FROM dbo.PickDetail PD (NOLOCK) 
		  JOIN dbo.Orders O (NOLOCK) ON O.StorerKey = PD.StorerKey AND O.Orderkey = PD.Orderkey
		  WHERE PD.StorerKey = @cStorerKey
		  AND PD.ID = @cDropID
	  
		  IF ISNULL(@cPalOrderType,'') <> '' AND @cPalOrderType <> @cUccOrderType
		  BEGIN --Cannot mix Order Type on pallet
			 SET @nErrNo = 1
			 SET @cErrMsg = 'Different Ord Type'
			 GOTO QUIT
		  END

		  IF @cPalOrderType = 'B2C' 
		  BEGIN
			 --Get UCC Carrier
			 SELECT TOP 1
			    @cUccCarrier = C.UDF01 
			 FROM dbo.Codelkup C (NOLOCK) 
			 WHERE Storerkey = @cStorerKey
			 AND ListName = @DelServiceList 
			 AND Code = @cUccOrderService

			 --Get Pallet Carrier
			 SELECT TOP 1
			    @cPalCarrier = UDF01 
			 FROM dbo.Codelkup (NOLOCK) 
			 WHERE Storerkey = @cStorerKey
			 AND ListName = @DelServiceList 
			 AND Code = @cPalOrderService

			 IF @cUccCarrier <> @cPalCarrier
			 BEGIN --Cannot mix Carrier
				SET @nErrNo = 163613
				SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong Carrier
				GOTO QUIT
			 END
		  END
		  IF @cPalOrderType = 'B2B' 
		  BEGIN
			 IF @cPalOrderService <> @cUccOrderService
			 BEGIN --Cannot mix Delivery Service on pallet
				SET @nErrNo = 2
				SET @cErrMsg = 'Diff Delivery Serv' 
				GOTO QUIT
			 END
			 IF @cPalConsignee <> @cUccConsignee
			 BEGIN --Cannot mix Delivery Service on pallet
				SET @nErrNo = 3
				SET @cErrMsg = 'Diff Consignee' 
				GOTO QUIT
			 END
		  END

		  IF ISNULL(@cPalMbolKey,'') = '' 
		  BEGIN 
			 GOTO QUIT
		  END
		  IF @cUccMbolKey <> @cPalMbolKey 
		  BEGIN --Cannot mix Mbol on pallet
			 SET @nErrNo = 94851
			 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff MbolKey
			 GOTO QUIT
		  END
	  END
   END
QUIT:
END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_1641ExtValWAG TO NSQL
GO
