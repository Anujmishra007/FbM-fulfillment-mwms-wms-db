SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************************************************/
/* Stored Proc : isp_ArchiveDropId_rdt                                                                  */
/* Creation Date: 2026-04-10                                                                            */
/*                                                                                                      */
/* Purpose: Add prefix to DropID in PackDetail and PickDetail tables                                    */
/*                                                                                                      */
/* Input Parameters:                                                                                    */
/*   @cStorerKey - Storer Key (Required)                                                                */
/*   @cDropId    - DropID to prefix (Required)                                                          */
/*   @cPrefix    - Prefix to add (Optional, default 'ARC')                                              */
/*                                                                                                      */
/* Updates:                                                                                             */
/* Date         Author          Purpose                                                                 */
/* 2026-04-13   AKH114          UWP-53936                                                               */
/********************************************************************************************************/
CREATE OR ALTER PROC [RDT].[isp_ArchiveDropId_rdt](
   @cToteID       NVARCHAR(20)
 , @cStorerKey    NVARCHAR(15) = 'LVSUSA'
 , @cPrefix       NVARCHAR(10) = 'ARC'
 , @cLangCode     NVARCHAR(3)  = 'ENG'
 , @nErrNo        INT OUTPUT
 , @cErrMsg       NVARCHAR(215) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET XACT_ABORT OFF

   DECLARE
      @n_PackDetail_Cnt       INT = 0,
      @n_PickDetail_Cnt       INT = 0,
      @cPackDetail_Keys       NVARCHAR(2000) = '',
      @cPickDetail_Keys       NVARCHAR(2000) = ''

   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- Default Prefix
   IF @cPrefix IS NULL OR RTRIM(LTRIM(@cPrefix)) = ''
      SET @cPrefix = 'ARC'

   SET @cToteID = RTRIM(LTRIM(@cToteID))

   -- Validations
   IF ( LEN(@cToteID) <> 10 )
   BEGIN
      SET @nErrNo  = 264757
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO ROLLBACK_UPD   
   END

   IF SUBSTRING(@cToteID, 1, 4) <> '0000'
   BEGIN
      SET @nErrNo  = 264758
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO ROLLBACK_UPD      
   END

   --------------------------------------------------------------------------------------
   -- Temp Tables
   --------------------------------------------------------------------------------------
   DECLARE @tPackDetail TABLE
   (
      PickSlipNo NVARCHAR(10),
      CartonNo   INT,
      LabelNo    NVARCHAR(20),
      LabelLine  NVARCHAR(5),
      PRIMARY KEY (PickSlipNo, CartonNo, LabelNo, LabelLine)
   )

   DECLARE @tPickDetail TABLE
   (
      PickDetailKey NVARCHAR(18) PRIMARY KEY
   )

   --------------------------------------------------------------------------------------

   BEGIN TRAN

   --------------------------------------------------------------------------------------
   -- Load PackDetail
   --------------------------------------------------------------------------------------
   BEGIN TRY
      INSERT INTO @tPackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine)
      SELECT DISTINCT PickSlipNo, CartonNo, LabelNo, LabelLine
      FROM dbo.PackDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND DropID    = @cToteID
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 264751
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO ROLLBACK_UPD
   END CATCH

   --------------------------------------------------------------------------------------
   -- Update PackDetail
   --------------------------------------------------------------------------------------
   IF EXISTS (SELECT 1 FROM @tPackDetail)
   BEGIN
      BEGIN TRY
         UPDATE PAD
         SET PAD.DropID = 'ARC' + PAD.DropID
         FROM dbo.PackDetail PAD
         INNER JOIN @tPackDetail T
            ON PAD.PickSlipNo = T.PickSlipNo
           AND PAD.CartonNo   = T.CartonNo
           AND PAD.LabelNo    = T.LabelNo
           AND PAD.LabelLine  = T.LabelLine

       SET @n_PackDetail_Cnt   = @@ROWCOUNT
       SELECT @cPackDetail_Keys =  STRING_AGG(PickSlipNo + ',' + CAST(CartonNo  AS NVARCHAR)+ ',' + LabelNo + ',' + LabelLine , '|') 
       FROM @tPackDetail               
         
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 264752
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO ROLLBACK_UPD
      END CATCH
   END
   ELSE
   BEGIN
      PRINT 'No records found in @tPackDetail'
   END

   --------------------------------------------------------------------------------------
   -- Load PickDetail
   --------------------------------------------------------------------------------------
   BEGIN TRY
      INSERT INTO @tPickDetail (PickDetailKey)
      SELECT PickDetailKey
      FROM dbo.PICKDETAIL WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND DropID    = @cToteID
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 264753
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO ROLLBACK_UPD
   END CATCH

   --------------------------------------------------------------------------------------
   -- Update PickDetail
   --------------------------------------------------------------------------------------
   IF EXISTS (SELECT 1 FROM @tPickDetail)
   BEGIN
      BEGIN TRY
         UPDATE PID
         SET PID.DropID = CONCAT('ARC', PID.DropID)
         FROM dbo.PICKDETAIL PID WITH (ROWLOCK)
         INNER JOIN @tPickDetail TPD
            ON PID.PickDetailKey = TPD.PickDetailKey

         SET @n_PickDetail_Cnt   = @@ROWCOUNT
       SELECT @cPickDetail_Keys = STRING_AGG(pickdetailkey, '|')   FROM @tPickDetail

      END TRY
      BEGIN CATCH
         SET @nErrNo  = 264754
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO ROLLBACK_UPD
      END CATCH
   END
   ELSE
   BEGIN
      PRINT 'No records found in @tPickDetail'
   END

   --------------------------------------------------------------------------------------
   -- Audit Insert + WCS Release
   --------------------------------------------------------------------------------------
   IF (@n_PackDetail_Cnt > 0 OR @n_PickDetail_Cnt > 0)
   BEGIN
      BEGIN TRY
         INSERT INTO RDT.rdtArchiveTote_Audit
         (
         StorerKey,
         DropID,
         PackDetail_Keys,
         PickDetail_Cnt,
         PickDetail_Keys,
         PackDetail_Cnt
         )
         VALUES
         (
         @cStorerKey,
         @cToteID,
         @cPackDetail_Keys,
         @n_PickDetail_Cnt,
         @cPickDetail_Keys,
         @n_PackDetail_Cnt
         )
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 264755
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO ROLLBACK_UPD
      END CATCH

      BEGIN TRY
         DECLARE @bSuccess INT

         EXECUTE ispGenTransmitLog2
            @c_TableName     = 'WSSortTotRel',
            @c_Key1          = @cToteID,
            @c_Key2          = '',
            @c_Key3          = @cStorerKey,
            @c_TransmitBatch = '',
            @b_Success       = @bSuccess OUTPUT,
            @n_err           = @nErrNo OUTPUT,
            @c_errmsg        = @cErrMsg OUTPUT
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 264756
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO ROLLBACK_UPD
      END CATCH
   END

   --------------------------------------------------------------------------------------
   -- Output
   --------------------------------------------------------------------------------------
   SELECT
      @cStorerKey                   AS StorerKey,
      @cToteID                      AS OriginalDropId,
      CONCAT(@cPrefix, @cToteID)    AS NewDropId,
      @cPackDetail_Keys             AS PickDetailExists,
      @cPickDetail_Keys             AS PackDetailExists,
      @n_PickDetail_Cnt             AS PickDetailUpdated,
      @n_PackDetail_Cnt             AS PackDetailUpdated,
      @bSuccess                     AS SorterToteRelease

   COMMIT TRAN

ROLLBACK_UPD:
   IF (XACT_STATE()) = -1
      ROLLBACK

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[isp_ArchiveDropId_rdt] TO NSQL
GO
