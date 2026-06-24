SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/
/* Stored procedure : rdt_1650ExtUpdARLA                                */
/* Purpose          : Tracking last Picked BBD (Best Before Date)       */
/*                    per Storer/Consignee/SKU combination.              */
/*                    Called from RDT Function 1650                      */
/*                    (Scan Pallet To Door).                             */
/* Version 1.1                                                          */
/* Parameters:                                                          */
/*   @nMobile    - Mobile device ID                                     */
/*   @nFunc      - RDT Function number (1650)                           */
/*   @nStep      - Current step in the RDT function                     */
/*   @cLangCode  - Language code for error messages                     */
/*   @nInputKey  - Input key indicator (1 = user input)                 */
/*   @cStorerKey - Storer key for filtering                             */
/*   @cPalletID  - Scanned pallet ID (may include GS1 AI prefix)       */
/*   @cMbolKey   - Master Bill of Lading key                            */
/*   @cDoor      - Assigned door                                        */
/*   @cOption    - Option flag                                          */
/*   @nAfterStep - Step to proceed to after execution                   */
/*   @nErrNo     - OUTPUT: Error number (0 = success)                   */
/*   @cErrMsg    - OUTPUT: Error message text                           */
/*                                                                      */
/* Target table: dbo.CUSTOMERDATETRACKER                                */
/*   PK: (StorerKey, ConsigneeKey, SKU)                                 */
/*   Tracks the latest Best Before Date per customer/SKU combo.         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* --------- ---- -------- ------------------------------------------- */
/* SUNDAR    0.1  SUNDAR   Initial version                              */
/* 2026-06-03 1.0  SYO054   Strip GS1 AI (00) prefix from PalletID     */
/*                          Fix MERGE PK violation — NVARCHAR/VARCHAR   */
/*                          mismatch on join keys causing INSERT instead */
/*                          of UPDATE. Added CAST to source columns.    */
/*                          Added @nDebug parameter for troubleshooting */
/* 2026-06-03 1.1  SYO054   Fix MERGE PK violation — duplicate source   */
/*                          rows when multiple lots exist for the same  */
/*                          SKU on an order. Pre-aggregate source with  */
/*                          GROUP BY + MAX(LOTTABLE04) to guarantee one */
/*                          row per (StorerKey, ConsigneeKey, SKU).     */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1650ExtUpdARLA] (
   @nMobile          INT,
   @nFunc            INT,
   @nStep            INT,
   @cLangCode        NVARCHAR(3),
   @nInputKey        INT,
   @cStorerKey       NVARCHAR(15),
   @cPalletID        NVARCHAR(20),
   @cMbolKey         NVARCHAR(10),
   @cDoor            NVARCHAR(20),
   @cOption          NVARCHAR(1),
   @nAfterStep       INT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR(20)   OUTPUT,
   ---------------------------------------------------------------
   -- Debug flag: 0 = off (default), 1 = on (prints diagnostic info)
   -- Usage: Pass @nDebug = 1 when troubleshooting from SSMS.
   -- In production RDT calls this parameter is omitted (defaults to 0).
   ---------------------------------------------------------------
   @nDebug           INT = 0
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount        INT,
           @cLoadkey          NVARCHAR(10),
           @cOrderkey         NVARCHAR(10),
           @cMBOL4PltID       NVARCHAR(10),
           @nRowRef           INT,
           @nSourceRows       INT           -- rows in MERGE source (debug)

   DECLARE @curUpd            CURSOR

   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1650ExtUpdARLA

   ---------------------------------------------------------------
   -- STEP 1: GS1-128 Barcode Decode
   -- Scanners may send the full GS1 barcode including the
   -- Application Identifier, e.g. (00)357202606030727415.
   -- The AI (00) identifies an SSCC-18. We strip it here so
   -- downstream lookups use only the 18-digit SSCC.
   ---------------------------------------------------------------
   IF @nInputKey = 1
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @nDebug = 1
            PRINT '[DEBUG] Step 1 — Raw PalletID input: [' + ISNULL(@cPalletID, 'NULL') + ']'

         IF LEFT(@cPalletID, 4) = '(00)'
         BEGIN
            SET @cPalletID = SUBSTRING(@cPalletID, 5, LEN(@cPalletID) - 4)

            IF @nDebug = 1
               PRINT '[DEBUG] Step 1 — GS1 AI (00) stripped. PalletID now: [' + @cPalletID + ']'
         END
         ELSE
         BEGIN
            IF @nDebug = 1
               PRINT '[DEBUG] Step 1 — No GS1 AI (00) prefix detected. PalletID unchanged.'
         END
      END
   END

   ---------------------------------------------------------------
   -- STEP 2: Validate Pallet and Update CUSTOMERDATETRACKER
   -- Looks up the order via PickDetail, then MERGEs the latest
   -- Best Before Date (LotAttribute.Lottable04) into the
   -- tracking table per Storer/Consignee/SKU.
   ---------------------------------------------------------------
   IF @nInputKey = 1
   BEGIN
      IF @nStep = 2
      BEGIN
         -- Validate: Pallet ID is required
         IF ISNULL(@cPalletID, '') = ''
         BEGIN
            SET @nErrNo = 201951
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PALLET ID REQ

            IF @nDebug = 1
               PRINT '[DEBUG] Step 2 — ERROR: PalletID is empty or NULL. ErrNo=' + CAST(@nErrNo AS VARCHAR(10))

            GOTO RollBackTran
         END

         IF @nDebug = 1
            PRINT '[DEBUG] Step 2 — Looking up OrderKey for PalletID: [' + @cPalletID + '], StorerKey: [' + @cStorerKey + ']'

         -- Find the order associated with this pallet
         SELECT TOP 1 @cOrderKey = OrderKey
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND   (ID = @cPalletID OR CASEID = @cPalletID)
         AND   [Status] < '9'
         ORDER BY 1

         IF @nDebug = 1
         BEGIN
            IF @cOrderKey IS NULL
               PRINT '[DEBUG] Step 2 — WARNING: No OrderKey found for PalletID [' + @cPalletID + ']. MERGE will produce no rows.'
            ELSE
               PRINT '[DEBUG] Step 2 — OrderKey resolved: [' + @cOrderKey + ']'
         END

         ---------------------------------------------------------------
         -- Debug: Check how many source rows the MERGE would process
         -- If > 1 row per (StorerKey, ConsigneeKey, SKU) without
         -- aggregation, MERGE would fail with PK violation.
         ---------------------------------------------------------------
         IF @nDebug = 1
         BEGIN
            SELECT @nSourceRows = COUNT(*)
            FROM dbo.PICKDETAIL PD WITH (NOLOCK)
            INNER JOIN dbo.ORDERS O WITH (NOLOCK)
                ON O.ORDERKEY = PD.ORDERKEY
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
                ON LA.SKU       = PD.SKU
               AND LA.LOT       = PD.LOT
               AND LA.STORERKEY = PD.STORERKEY
            WHERE O.ORDERKEY = @cOrderKey

            PRINT '[DEBUG] Step 2 — Raw source rows (before GROUP BY): ' + CAST(@nSourceRows AS VARCHAR(10))
            PRINT '[DEBUG] Step 2 — If raw rows > distinct (Storer/Consignee/SKU) combos, duplicates exist.'
         END

         ---------------------------------------------------------------
         -- MERGE: Upsert Best Before Date into CUSTOMERDATETRACKER
         --
         -- FIX v1.0 (2026-06-03 SYO054):
         -- CAST source NVARCHAR keys to VARCHAR to match target table.
         --
         -- FIX v1.1 (2026-06-03 SYO054):
         -- A single order can have multiple PickDetail lines for the
         -- same SKU across different Lots (production batches). Each
         -- lot joins to a separate LotAttribute row, producing
         -- duplicate (StorerKey, ConsigneeKey, SKU) rows in the
         -- MERGE source. MERGE cannot handle duplicate source keys —
         -- the first row triggers NOT MATCHED → INSERT, the second
         -- also tries INSERT → PK violation.
         --
         -- Solution: GROUP BY the three PK columns and use
         -- MAX(LOTTABLE04) to get the latest BBD per combination.
         -- This guarantees exactly one source row per target PK,
         -- eliminating the duplicate key error.
         ---------------------------------------------------------------

         MERGE dbo.CUSTOMERDATETRACKER AS TARGET
         USING
         (
             SELECT
                 CAST(O.STORERKEY    AS VARCHAR(15))  AS STORERKEY,
                 CAST(O.CONSIGNEEKEY AS VARCHAR(15))  AS CONSIGNEEKEY,
                 CAST(PD.SKU         AS VARCHAR(20))  AS SKU,
                 MAX(LA.LOTTABLE04)                   AS LASTBESTBEFOREDATE
             FROM dbo.PICKDETAIL PD WITH (NOLOCK)
             INNER JOIN dbo.ORDERS O WITH (NOLOCK)
                 ON O.ORDERKEY = PD.ORDERKEY
             INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
                 ON LA.SKU       = PD.SKU
                AND LA.LOT       = PD.LOT
                AND LA.STORERKEY = PD.STORERKEY
             WHERE O.ORDERKEY = @cOrderKey
             ---------------------------------------------------------------
             -- GROUP BY ensures one row per (StorerKey, ConsigneeKey, SKU).
             -- MAX(LOTTABLE04) picks the latest Best Before Date across
             -- all lots for that SKU — which is the desired business logic.
             ---------------------------------------------------------------
             GROUP BY
                 CAST(O.STORERKEY    AS VARCHAR(15)),
                 CAST(O.CONSIGNEEKEY AS VARCHAR(15)),
                 CAST(PD.SKU         AS VARCHAR(20))
         ) AS SOURCE
         ON  TARGET.STORERKEY    = SOURCE.STORERKEY
         AND TARGET.CONSIGNEEKEY = SOURCE.CONSIGNEEKEY
         AND TARGET.SKU          = SOURCE.SKU

         -- Only update if the new BBD is later than the stored one
         WHEN MATCHED
              AND SOURCE.LASTBESTBEFOREDATE > TARGET.LASTBESTBEFOREDATE
         THEN
             UPDATE SET
                 TARGET.LASTBESTBEFOREDATE = SOURCE.LASTBESTBEFOREDATE

         -- First time seeing this Storer/Consignee/SKU — insert
         WHEN NOT MATCHED BY TARGET
         THEN
             INSERT (STORERKEY, CONSIGNEEKEY, SKU, LASTBESTBEFOREDATE)
             VALUES (SOURCE.STORERKEY,
                     SOURCE.CONSIGNEEKEY,
                     SOURCE.SKU,
                     SOURCE.LASTBESTBEFOREDATE);

         -- Debug: report MERGE outcome
         IF @nDebug = 1
         BEGIN
            PRINT '[DEBUG] Step 2 — MERGE completed. @@ROWCOUNT=' + CAST(@@ROWCOUNT AS VARCHAR(10))
            PRINT '[DEBUG] Step 2 — StorerKey=[' + ISNULL(@cStorerKey, 'NULL')
                  + '] OrderKey=[' + ISNULL(@cOrderKey, 'NULL') + ']'
         END

         GOTO Quit
      END
   END

   COMMIT TRAN rdt_1650ExtUpdARLA

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1650ExtUpdARLA -- Only rollback changes made here

   IF @nDebug = 1
      PRINT '[DEBUG] Transaction rolled back to savepoint rdt_1650ExtUpdARLA'

Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

   IF @nDebug = 1
      PRINT '[DEBUG] Procedure complete. Final ErrNo=' + CAST(ISNULL(@nErrNo, 0) AS VARCHAR(10))
GO
