SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_511ExtValid14                                   */
/* Purpose: Move By ID Extended Validate                                */
/*                                                                      */
/* Called from: rdtfnc_Move_ID                                          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-12-12  1.0  PSJ036      UWP-48075 - validate correct TOLOC      */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtValid14] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cFromID          NVARCHAR( 18),    
   @cFromLOC         NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @cToID            NVARCHAR( 18),
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0

   -- IDENTIFY TYPE PROCESS TO VALIDATE TOLOC
   DECLARE @cB2BnoVas        NVARCHAR(10)
   DECLARE @cB2BVas          NVARCHAR(10)
   DECLARE @cB2CSingle       NVARCHAR(10)
   DECLARE @cB2CMulti        NVARCHAR(10)

   -- ORDER LEVEL
   DECLARE @cDocType         NVARCHAR(1)
   DECLARE @cOrderSingleFlag NVARCHAR(1)
   DECLARE @cVasInfo         NVARCHAR(10)

   IF @nStep = 1
   BEGIN
	   IF NOT EXISTS(SELECT 1 
					 FROM dbo.LOTXLOCXID WITH (NOLOCK)
					 WHERE ID = @cFromID 
					 AND QTY > 0
					 AND StorerKey = @cStorerKey)
		BEGIN
			SET @nErrNo = 257501
			SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, 'DSP') -- 257501: INVALID PALLET ID
			GOTO QUIT
		END
	END


   IF @nStep = 3 --ToLoc
   BEGIN
      IF @nInputKey = 1
      BEGIN
		 -- MOVE AFTER PICKING
         IF NOT EXISTS ( SELECT 1 
                     FROM dbo.CODELKUP AS CD WITH (NOLOCK)
					 WHERE CD.LISTNAME = 'ONBRMVOUT'
					 AND CD.Storerkey = @cStorerKey
					 AND CD.CODE = @cFromLOC 
                     )
		 BEGIN
			GOTO QUIT
		 END

		 ELSE

         BEGIN --CUSTOM VALIDATION
            SELECT @cB2BnoVas  = CD.UDF01,
				   @cB2BVas    = CD.UDF02,
				   @cB2CSingle = CD.UDF03,
				   @cB2CMulti  = CD.UDF04
            FROM dbo.CODELKUP AS CD WITH (NOLOCK)
			WHERE CD.LISTNAME = 'ONBRMVOUT'
			AND CD.Storerkey = @cStorerKey
			AND CD.CODE = @cFromLOC                

			-- WAVE IS CREATED BASED ON EACH ORDER TYPE
			IF NOT EXISTS( 
				SELECT 1 
				FROM dbo.ORDERS WITH (NOLOCK) 
				WHERE STORERKEY = @cStorerKey
				AND OrderKey = ( SELECT TOP 1 OrderKey 
								 FROM dbo.PICKDETAIL WITH (NOLOCK)
								 WHERE ID = @cFromID 
							)
						)
				 BEGIN
					SET @nErrNo = 257502  
					SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 257502: ORDER NOT FOUND 
					GOTO QUIT
				 END

			-- DocType = 'E'/'B2C'
			-- DocType = 'N'/'B2B'
			-- SingleFlag = 'S'/'SINGLE'
			-- SingleFlag = 'M'/'MULTI'

			SELECT TOP 1 @cDocType 		   = ISNULL(DocType,''),
				         @cOrderSingleFlag = ISNULL(ECOM_SINGLE_Flag,'')
			FROM dbo.ORDERS WITH (NOLOCK) 
			WHERE STORERKEY = @cStorerKey
			AND OrderKey = ( SELECT TOP 1 OrderKey 
							FROM dbo.PICKDETAIL WITH (NOLOCK)
							WHERE ID = @cFromID
					)
			-- B2C ORDER
			IF @cDocType = 'E' and @cFromLOC = 'ONESTEIRA'
			BEGIN
			IF @cOrderSingleFlag = 'S' AND @cToLOC <> @cB2CSingle
				BEGIN
					SET @nErrNo = 257503
					SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, 'DSP') -- 257503:LOC NOT MATCH
					GOTO QUIT
				END
				ELSE IF @cOrderSingleFlag <> 'S' AND @cToLOC <> @cB2CMulti
				BEGIN
					SET @nErrNo = 257503
					SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, 'DSP') -- 257503:LOC NOT MATCH
					GOTO QUIT
				END
			END -- END B2C

				 
			ELSE -- B2B ORDER

			BEGIN
				IF @cFromLOC = 'ONESTEIRA'
				   BEGIN
				     IF EXISTS( SELECT 1 
				     		FROM dbo.ORDERS WITH (NOLOCK) 
				     		LEFT JOIN dbo.OrderInfo WITH (NOLOCK) 
				     		ON ORDERS.OrderKey = OrderInfo.OrderKey
				     		WHERE (isnull(ORDERS.Notes,'') <> '' OR isnull(ORDERS.Notes2,'') <> '' OR isnull(OrderInfo.Notes,'') <> '')
				     		AND ORDERS.OrderKey IN (
				     			SELECT DISTINCT PD.OrderKey 
				     			FROM dbo.PICKDETAIL AS PD WITH (NOLOCK) 
				     			WHERE PD.ID = @cFromID))
				     	BEGIN
				     	IF @cToLOC = @cB2BVas
				     		BEGIN
				     			GOTO QUIT
				     		END
				     	ELSE
				     		BEGIN
				     			SET @nErrNo = 257503
				     			SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, 'DSP') -- 257503:LOC NOT MATCH
				     			GOTO QUIT
				     		END
				     	END
				     
				     ELSE
				     
				     BEGIN
				     IF @cToLOC <> @cB2BnoVas
				     	BEGIN
				     		SET @nErrNo = 257503
				     		SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, 'DSP') -- 257503:LOC NOT MATCH
				     		GOTO QUIT
				     	END
				     END
				 END
			END --END B2B

		    IF @cFromLOC = 'ONVASOUT' and @cToLOC <> @cB2BnoVas
			BEGIN
				SET @nErrNo = 100956
				SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, 'DSP') -- 100956 LOC NOT MATCH
				GOTO QUIT
			END
	     END -- END VALIDATION
	  END
   END
END
QUIT:

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_511ExtValid14] TO [NSQL]
GO