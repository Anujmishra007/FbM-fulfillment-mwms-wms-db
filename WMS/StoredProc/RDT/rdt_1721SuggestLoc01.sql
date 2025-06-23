SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1721SuggestLoc01                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Move                                      */
/*                                                                      */
/* Purpose: Check ID                                                    */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2024-11-28  1.0  CYU027   FCR-1391 Levis                              */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1721SuggestLoc01] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @cStorer         NVARCHAR( 15),
   @nStep           INT,
   @cID             NVARCHAR( 20),
   @cSuggestLoc     NVARCHAR( 15) OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS
BEGIN

   DECLARE @cMbolkey       NVARCHAR( 15)

   -- Search for pallet that is in the same mbolkey
   -- with location that falls under the loc.putawayzone = ‘OBSTG’

   SELECT top 1 @cMbolkey = PD.UserDefine01
      FROM PALLETDETAIL (NOLOCK ) PD
      --INNER JOIN ORDERS O on O.OrderKey = PD.OrderKey
   WHERE PD.PalletKey = @cID
   AND PD.Storerkey = @cStorer

   -- Check MbolKey
   IF ISNULL( @cMbolkey, '') = ''
   BEGIN
      SET @nErrNo = 229901
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- MbolKeyNotFound
      GOTO Quit
   END

   SELECT TOP 1 @cSuggestLoc = LLI.LOC FROM Palletdetail PD
      INNER JOIN LOC L (NOLOCK ) ON (PD.loc = L.Loc AND L.putawayzone = 'OBSTG')
      INNER JOIN LOTxLOCxID LLI ON (LLI.loc = PD.Loc and LLI.qty>0 and ISNULL(LLI.ID,'') <> '')
   WHERE PD.UserDefine01 = @cMbolkey
     AND PD.Storerkey = @cStorer
     AND ISNULL(PD.Palletkey, '') <> ''
     AND  PD.PalletKey <> @cID -- not self
     AND PD.status < 9
   GROUP BY LLI.LOC, L.MaxPallet
   HAVING COUNT(DISTINCT(LLI.ID)) < L.MaxPallet
   ORDER BY L.MaxPallet, LLI.loc

   Quit:


END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1721SuggestLoc01 TO NSQL
GO
