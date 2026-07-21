SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_1837ExtValJCB                                   */  
/*                                                                      */  
/* Purpose:       Not merging non-completed task IDs                    */  
/*                                                                      */  
/* Date         Rev   Author   Purposes                                 */  
/* 2026-07-09   1.0   PPA374   Created                                  */  
/* 2026-07-15   2.0   PPA374   Validation that wave is always the same  */
/************************************************************************/ 
CREATE OR ALTER PROC [RDT].[rdt_1837ExtValJCB] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cCartonID      NVARCHAR( 20), 
   @cPalletID      NVARCHAR( 20), 
   @cLoadKey       NVARCHAR( 10), 
   @cLoc           NVARCHAR( 10), 
   @cOption        NVARCHAR( 1), 
   @tExtValidate   VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cCartonOrder         AS NVARCHAR(20)
   DECLARE @cWaveOfNewOrder      AS NVARCHAR(20)
   DECLARE @cPalletOrder         AS NVARCHAR(20)
   DECLARE @cWaveOfExistingOrder AS NVARCHAR(20)

   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nStep = 1 -- Step 1 Start
   BEGIN
      BEGIN
         --Check that carton is not in any open task before the consolidation
         IF EXISTS 
         (
            SELECT 1 
            FROM TaskDetail WITH(NOLOCK)
            WHERE Status NOT IN ('x','9')
	           AND FromID = @cCartonID
		       AND FromID <> ''
		       AND Storerkey = @cStorerKey
         )
         BEGIN
            SET @nErrNo = 218154
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --LPN task is open
			RETURN
         END
      END 
   END -- Step 1 End

   IF @nStep = 2
   BEGIN --Step 2 Start
      --Check if there is already something on the pallet
      IF EXISTS (SELECT 1 FROM PICKDETAIL WITH(NOLOCK) WHERE DropID = @cPalletID AND Storerkey = @cStorerKey) AND @cPalletID <> ''
      BEGIN
	     --If there is already something on the pallet and it is not closure, collect information about what wave it is on the pallet and what wave is trying to be consolidated there
         IF @cCartonID <> ''
	     BEGIN
            SELECT TOP 1 @cCartonOrder = OrderKey FROM PICKDETAIL WITH(NOLOCK) WHERE (CaseID = @cCartonID OR DropID = @cCartonID) AND Storerkey = @cStorerKey --New carton orderkey
			SELECT TOP 1 @cWaveOfNewOrder = UserDefine09 FROM ORDERS WITH(NOLOCK) WHERE OrderKey = @cCartonOrder AND StorerKey = @cStorerKey --New carton wave
			SELECT TOP 1 @cPalletOrder = OrderKey FROM PICKDETAIL WITH(NOLOCK) WHERE DropID = @cPalletID AND StorerKey = @cStorerKey --Existing pallet orderkey
			SELECT TOP 1 @cWaveOfExistingOrder = UserDefine09 FROM ORDERS WITH(NOLOCK) WHERE OrderKey = @cPalletOrder AND StorerKey = @cStorerKey --Existing pallet wave

			--Comparing waves, as those must be the same wave
			IF (ISNULL(@cWaveOfNewOrder,'') <> ISNULL(@cWaveOfExistingOrder,'')) OR (ISNULL(@cWaveOfNewOrder,'') = '' AND ISNULL(@cWaveOfExistingOrder,'') = '')
			BEGIN
			   SET @nErrNo = 218155
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --Diff wave on pallet
			   RETURN
			END
	     END
	  END
   END --Step 2 End
END
GO
GRANT EXECUTE ON rdt_1837ExtValJCB TO NSQL
GO
