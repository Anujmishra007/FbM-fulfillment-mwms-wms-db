
USE [GBRWMS]
GO
/****** Object:  StoredProcedure [RDT].[rdt_839ExtValJCB]    Script Date: 9/17/2025 10:28:29 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************************/
/* Store procedure: [rdt_839ExtValJCB]                                               */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 12/09/2025   1.0   PPA374   Only allow PickZones from CODELKUP PickPiece pick     */
/* 17/09/2025   2.0   PPA374   Stop from picking if stock is not available           */
/* 22/09/2025   2.1   PPA374   Check that order type and location are correct        */
/*************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_839ExtValJCB] (
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
   @nErrNo       INT    OUTPUT,  
   @cErrMsg      NVARCHAR(250) OUTPUT  
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cOrderKey AS NVARCHAR( 20)
   DECLARE @cOrderType   AS NVARCHAR( 20)
   DECLARE @cLocToMoveTo AS NVARCHAR( 20)

   SELECT TOP 1 @cOrderKey = OrderKey 
   FROM dbo.PICKHEADER WITH(NOLOCK) 
   WHERE PickHeaderKey = @cPickSlipNo

   SELECT TOP 1
      @cOrderType = Type
   FROM dbo.ORDERS WITH(NOLOCK)
   WHERE OrderKey = @cOrderKey

   SELECT TOP 1
      @cLocToMoveTo = Long
   FROM dbo.CODELKUP WITH(NOLOCK) 
   WHERE LISTNAME = 'JCBMVPPKIT' 
      AND Code = @cOrderType

   IF @nFunc = 839
   BEGIN
      IF @nStep = 1
	     AND @nInputKey = 1 --PickSlipNo
      BEGIN
	     IF ISNULL(@cLocToMoveTo,'') = ''
		 BEGIN 
		    SET @nErrNo = 218240
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Loc not set for type'
			GOTO QUIT
		 END

		 IF NOT EXISTS (
		    SELECT 1 
			FROM dbo.LOC WITH(NOLOCK) 
			WHERE LOC = @cLocToMoveTo 
			   AND Facility = 'EMG03'
         )
		 BEGIN
		    SET @nErrNo = 218241
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')+@cLocToMoveTo--'Bad loc '+@cLocToMoveTo
			GOTO QUIT
		 END

	     IF EXISTS (
		    SELECT 1
            FROM dbo.PICKDETAIL PD1 WITH (NOLOCK) 
               OUTER APPLY(
			      SELECT ISNULL(SUM(Qty),0)LLIQty 
				  FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) 
				  WHERE LLI.Loc = PD1.Loc 
				     AND LLI.LOT = PD1.LOT 
					 AND LLI.SKU = PD1.SKU
					 AND LLI.StorerKey = PD1.Storerkey
               )OA
            WHERE (
			   EXISTS (
                  SELECT 1 
                  FROM dbo.PICKDETAIL PD2 WITH (NOLOCK) 
                  WHERE PD1.Sku = PD2.Sku 
                     AND PD1.Storerkey = PD2.Storerkey 
	                 AND PD1.Lot = PD2.Lot 
	                 AND PD1.Loc = PD2.Loc 
	                 AND PD2.OrderKey = @cOrderKey 
	                 AND PD2.Status = '0' 
            ) 
			   AND PD1.Notes = 'Started'
			   )
               OR PD1.OrderKey = @cOrderKey
            GROUP BY PD1.Sku, PD1.Loc, PD1.Lot, OA.LLIQty
            HAVING OA.LLIQty - SUM(PD1.Qty) < 0
		 )
		 BEGIN
		    SET @nErrNo = 218239
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'No stock Need replen'
			GOTO QUIT
		 END
	  END

	  IF @nStep = 2 
	     AND @nInputKey = 1 --PickZone
	  BEGIN
	     IF NOT EXISTS (
		    SELECT 1 
			FROM dbo.CODELKUP WITH(NOLOCK) 
			WHERE LISTNAME = 'JCBPPPZ' 
			   AND Code = @cPickZone
	     )
		 BEGIN
		    SET @nErrNo = 218238
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
			GOTO QUIT
		 END

		 IF @cDropID = ''
		 BEGIN
		    SET @nErrNo = 218242
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'DropID cant be blank'
			GOTO QUIT
		 END
      END

	  IF @nStep = 3
	     AND @nInputKey = 1 --SKU / QTY
      BEGIN
	     IF @nQTY <> (SELECT TOP 1 V_QTY FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile) 
		    AND (SELECT TOP 1 V_String2 FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile) = 1
		 BEGIN
		    SET @nErrNo = 218243
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Wrong qty entered'
			GOTO QUIT
		 END
	  END

   END
Quit:
END
GO

GRANT EXECUTE ON rdt_839ExtValJCB TO NSQL
GO
