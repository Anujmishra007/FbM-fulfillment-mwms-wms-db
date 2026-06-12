
/*****************************************************************************/
/* Store procedure: rdt_838ExtUpdCSC                                         */
/*                                                                           */
/* Purpose:  Update PACKDETAIL labelNo after recartonize                     */
/*                                                                           */
/* Date         Author   Purposes                                            */
/* 27/03/2026   AGA399   Create                                              */
/* 16/04/2026   AGA399   Update Pickdetail with the new dropID for PPS RDT   */
/*                                                                           */
/*****************************************************************************/

CREATE       PROC [RDT].[rdt_838ExtUpdCSC] (
 @nMobile         INT,
 @nFunc           INT,
 @cLangCode       NVARCHAR( 3),  
 @nStep           INT,
 @nInputKey       INT,
 @cFacility       NVARCHAR( 5),
 @cStorerKey      NVARCHAR( 15),
 @cPickSlipNo     NVARCHAR( 10),
 @cFromDropID     NVARCHAR( 20),
 @nCartonNo       INT,
 @cLabelNo        NVARCHAR( 20),
 @cSKU            NVARCHAR( 20),
 @nQTY            INT,
 @cUCCNo          NVARCHAR( 20),
 @cCartonType     NVARCHAR( 10),
 @cCube           NVARCHAR( 10),
 @cWeight         NVARCHAR( 10),
 @cRefNo          NVARCHAR( 20),
 @cSerialNo       NVARCHAR( 30),
 @nSerialQTY      INT,
 @cOption         NVARCHAR( 1),
 @cPackDtlRefNo   NVARCHAR( 20),
 @cPackDtlRefNo2  NVARCHAR( 20),
 @cPackDtlUPC     NVARCHAR( 30),
 @cPackDtlDropID  NVARCHAR( 20),
 @cPackData1      NVARCHAR( 30),
 @cPackData2      NVARCHAR( 30),
 @cPackData3      NVARCHAR( 30),
 @nErrNo          INT            OUTPUT,
 @cErrMsg         NVARCHAR( 20)  OUTPUT
) AS
BEGIN
 SET NOCOUNT ON
 SET QUOTED_IDENTIFIER OFF
 SET ANSI_NULLS OFF
 SET CONCAT_NULL_YIELDS_NULL OFF

 DECLARE @b_Success INT
 DECLARE @c_LabelNo  NVARCHAR(20)
 DECLARE @n_Err     INT
 DECLARE @c_ErrMsg  NVARCHAR(255)
 DECLARE @c_Status  NVARCHAR(10)
 DECLARE @c_ReasonKey  NVARCHAR(10)
 DECLARE @c_TaskDetailKey  NVARCHAR(10)
 DECLARE @c_FromLoc  NVARCHAR(10)
 DECLARE @c_ToLoc  NVARCHAR(10)
 DECLARE @c_Qty  INT
 DECLARE @c_outstring         NVARCHAR(255)
 DECLARE @cUserName      NVARCHAR( 18)

 SET  @cUserName = SUSER_SNAME()

 IF @nFunc = 838
 BEGIN
   IF @nStep = 4 --In step 4 (Carton type) system updates LabelNo
   BEGIN
    SET @b_success = 1
    SET @c_LabelNo = ''
    -- Get labelNo with GS128 format
    EXEC isp_GenUCCLabelNo_Std
           @cPickslipNo   = @cPickSlipNo
           ,@nCartonNo     = 0
           ,@cLabelNo      = @c_LabelNo   OUTPUT
           ,@b_success     = @b_success   OUTPUT
           ,@n_err         = @n_Err     OUTPUT
           ,@c_errmsg      = @c_ErrMsg    OUTPUT

     IF @b_Success = 0
     BEGIN
        SET @n_Err = 64020
        SET @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_Err)
                     +': Error Executing isp_GenUCCLabelNo_Std. (rdt_838ExtUpdCSC)'
                     + ' ( ' + @c_Errmsg + ' ) '
        GOTO Quit
     END
     ELSE
     BEGIN
        --Update table PackDetail with LabelNo GS128
        UPDATE dbo.PACKDETAIL WITH(ROWLOCK) SET
 LabelNo = @c_LabelNo,
 DropID = @c_LabelNo,   --ADDED 28/04
 qty = 0               --ADDED 28/04
        WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND StorerKey = @cStorerKey

  --Update PickDetail
        UPDATE dbo.PickDetail WITH(ROWLOCK) SET
          DropID     = @c_LabelNo,
 CaseID     = @c_LabelNo,  --ADDED 28/04
          CartonType = @cCartonType, --ADDED 28/04 --AGA 05/05
          EditDate = GETDATE(),
          EditWho  = SUSER_SNAME(),
          TrafficCop = NULL
       WHERE DropID = @cFromDropID

   --Update PACKINFO   ADDED 28/04
 UPDATE pi
      /* SET pi.Length   = CASE WHEN ISNULL(pi.Length,  0) = 0 THEN cz.CartonLength ELSE pi.Length  END,
           pi.Width    = CASE WHEN ISNULL(pi.Width,   0) = 0 THEN cz.CartonWidth  ELSE pi.Width   END,
           pi.Height   = CASE WHEN ISNULL(pi.Height,  0) = 0 THEN cz.CartonHeight ELSE pi.Height  END,*/
           SET pi.Length   = CASE WHEN ISNULL(cz.CartonLength,  0) = 0 THEN pi.Length ELSE cz.CartonLength  END, --updated by SKA900
           pi.Width    = CASE WHEN ISNULL(cz.CartonWidth,  0) = 0 THEN pi.Width  ELSE cz.CartonWidth END,
           pi.Height   = CASE WHEN ISNULL(cz.CartonHeight,  0) = 0 THEN pi.Height ELSE cz.CartonHeight  END,
           pi.EditDate = GETDATE(),
           pi.EditWho  = SUSER_SNAME(),
  pi.qty = 0 --AGA 05/05
       FROM dbo.PackInfo pi WITH (ROWLOCK)
       JOIN dbo.PackHeader ph WITH (NOLOCK)
         ON ph.PickSlipNo = pi.PickSlipNo
       JOIN dbo.Cartonization cz WITH (NOLOCK)
         ON cz.CartonizationGroup = ph.StorerKey
        AND cz.CartonType         = pi.CartonType
       WHERE pi.PickSlipNo = @cPickSlipNo
         AND pi.CartonNo   = @nCartonNo

--Update TaskDetail to allow drop the hospital cartons into CONVEYOR after HOSPITAL process

/*SELECT  @c_TaskDetailKey = TaskDetailKey,
@c_FromLoc = FromLoc,
@c_ToLoc = ToLoc,
@c_Qty = Qty,
@c_Status = Status,
@c_ReasonKey = ReasonKey
FROM dbo.TaskDetail WITH(NOLOCK)
WHERE Caseid = @cFromDropID AND Storerkey = @cStorerKey*/

        UPDATE dbo.TaskDetail WITH(ROWLOCK) SET
 CaseID = @c_LabelNo  --ADDED 06/05
       WHERE CaseID = @cFromDropID
 AND Storerkey = @cStorerKey
 AND Status IN ('X')
-- AND ReasonKey IN ('SIZE')


/* -- Update ReasonCode
    EXEC dbo.nspRFRSN01
        @c_sendDelimiter = NULL
       ,@c_ptcid         = 'RDT'
       ,@c_userid        = 'AGA399'--@cUserName
       ,@c_taskId        = 'RDT'
       ,@c_databasename  = NULL
       ,@c_appflag       = NULL
       ,@c_recordType    = NULL
       ,@c_server        = NULL
       ,@c_ttm           = NULL
       ,@c_TaskDetailKey = '0002000229'
       ,@c_fromloc       = 'PA08306123'--@c_FromLoc--@cSuggFromLOC
       ,@c_fromid        = ''
       ,@c_toloc         = 'CONVEYOR'--@c_ToLoc--@cSuggToloc
       ,@c_toid          = ''
       ,@n_qty           = 4--@c_Qty--@nShortQTY
       ,@c_PackKey       = ''
       ,@c_uom           = ''
       ,@c_reasoncode    = 'SIZE'--@c_ReasonKey--@cReasonCode
       ,@c_outstring     = @c_outstring    OUTPUT
       ,@b_Success       = @b_Success      OUTPUT
       ,@n_err           = @nErrNo         OUTPUT
       ,@c_errmsg        = @cErrMsg        OUTPUT
       ,@c_userposition  = '1' -- 1=at from LOC    */

UPDATE dbo.TaskDetail WITH(ROWLOCK) SET
 --ReasonKey = 'SIZE',
 Message01 = 'POST-HOSP'--@c_ReasonKey --ADDED 06/05
       WHERE CaseID = @c_LabelNo
 AND Storerkey = @cStorerKey

  UPDATE dbo.TaskDetail WITH(ROWLOCK) SET
 Status = 'X'--@c_Status --ADDED 06/05
       WHERE CaseID = @c_LabelNo
 AND Storerkey = @cStorerKey


       IF @@ERROR <> 0
       BEGIN
          SET @nErrNo = 149005
          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
          GOTO Quit
       END
     END
   END --Step4
 END --nFunc
Quit:
END-- end sp
