SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1730ExtUpd01                                    */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-02-10   NickT     1.0   FCR-10345 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1730ExtUpd01
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cQCKey       NVARCHAR( 10),
   @cQCLine      NVARCHAR( 5),
   @cToLoc       NVARCHAR( 10),
   @cToID        NVARCHAR( 18),
   @cReason      NVARCHAR( 20),
   @nActQty      INT,
   @cFinalizeFlag NVARCHAR( 1),
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nLoopIndex    INT,
      @bSuccess      INT,
      @nTranCount    INT,
      @nScn          INT,
      @cFromLOC      NVARCHAR(10),
      @cFromID       NVARCHAR(18),
      @cQCLineNo     NVARCHAR(5),
      @cIQCValidationRules NVARCHAR(30),
      @cPostFinalizeIQCSP NVARCHAR(30),
      @cSQL NVARCHAR(MAX)

   SELECT @nScn = Scn,
      @cFromLOC = V_Loc, 
      @cFromID = V_ID
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @nTranCount = @@TRANCOUNT

   -- TM Replen From
   IF @nFunc = 1730
   BEGIN
      IF @nStep = 99 AND @nScn = 1738-- ToLoc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE @tIncQCDetail TABLE
            (
               RowRef            INT IDENTITY(1,1),
               QC_Key            NVARCHAR( 10),
               QCLineNo          NVARCHAR( 5),
               OriginalQty       INT,
               FinalizeFlag      NVARCHAR(1)
            )
            INSERT INTO @tIncQCDetail (QC_Key, QCLineNo, OriginalQty, FinalizeFlag)
            SELECT QC_Key, QCLineNo, OriginalQty, FinalizeFlag
            FROM dbo.InventoryQCDetail WITH (ROWLOCK)
            WHERE QC_KEY = @cQCKey
               AND FromLoc = @cFromLOC
               AND FromID = @cFromID

            BEGIN TRAN
            SAVE TRAN rdt_1730ExtUpd01

            SET @nLoopIndex = -1

            WHILE 1 = 1
            BEGIN
               SELECT TOP 1
                  @cQCKey = QC_Key,
                  @cQCLineNo = QCLineNo,
                  @nLoopIndex = RowRef,
                  @nActQty = OriginalQty,
                  @cFinalizeFlag = FinalizeFlag
               FROM @tIncQCDetail
               WHERE RowRef > @nLoopIndex
               ORDER BY RowRef

               IF @@ROWCOUNT = 0
                  BREAK

               BEGIN TRY
                  Update dbo.InventoryQCDetail WITH (ROWLOCK) SET
                     QTY    = @nActQty,
                     TOQty  = @nActQty, 
                     Reason = @cReason,
                     ToID   = @cToID,
                     ToLoc  = @cToLoc,
                     TrafficCop = NULL  
                  WHERE QC_KEY        = @cQCKey
                     AND QCLineNo     = @cQCLineNo
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 258651
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update InventoryQCDetail Failed
                  GOTO RollBackTran
               END CATCH

               IF ISNULL(@cFinalizeFlag, 0) <> 'Y'
               BEGIN
                  SELECT @cIQCValidationRules = SC.sValue
                  FROM dbo.STORERCONFIG SC WITH(NOLOCK)
                  INNER JOIN dbo.CODELKUP CL WITH(NOLOCK) ON SC.sValue = CL.Listname
                  WHERE SC.StorerKey = @cStorerKey
                  AND SC.Configkey = 'IQCExtendedValidation'

                  IF ISNULL(@cIQCValidationRules,'') <> ''
                  BEGIN
                        EXEC isp_IQC_ExtendedValidation @c_QC_Key = @cQCKey 
                                                      , @cIQCValidationRules = @cIQCValidationRules 
                                                      , @b_Success  = @bSuccess OUTPUT
                                                      , @c_ErrMsg = @cErrMsg OUTPUT

                     IF @bSuccess <> 1
                     BEGIN
                        SET @nErrNo = 258653
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Exec isp_IQC_ExtendedValidation Failed
                        GOTO RollBackTran
                     END
                  END
                  ELSE
                  BEGIN  
                     SELECT @cIQCValidationRules = SC.sValue    
                     FROM dbo.STORERCONFIG SC (NOLOCK) 
                     WHERE SC.StorerKey = @cStorerKey 
                        AND SC.Configkey = 'IQCExtendedValidation'    
                     
                     IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@cIQCValidationRules) AND type = 'P')          
                     BEGIN          
                        SET @cSQL = 'EXEC ' + @cIQCValidationRules + ' @c_qc_key, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT '          

                        EXEC sp_executesql @cSQL,          
                           N'@c_qc_key NVARCHAR(10), @b_Success Int OUTPUT, @n_Err Int OUTPUT, @c_ErrMsg NVARCHAR(250) OUTPUT'
                           , @cQCKey          
                           , @bSuccess  OUTPUT          
                           , @nErrNo      OUTPUT          
                           , @cErrMsg   OUTPUT 
                        
                        IF @bSuccess <> 1     
                        BEGIN    
                           SET @nErrNo = 258654
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Exec isp_IQC_ExtendedValidation Failed
                           GOTO RollBackTran
                        END         
                     END  
                  END

                  BEGIN TRY
                     UPDATE INVENTORYQCDETAIL WITH (ROWLOCK)
                        SET FinalizeFlag = 'Y'
                     WHERE QC_Key = @cQCKey 
                        AND QCLineNo = @cQCLineNo
                        AND Status <> '9'
                        AND FinalizeFlag <> 'Y'
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 258654
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update InventoryQCDetail Failed
                     GOTO RollBackTran
                  END CATCH

                  IF NOT EXISTS ( SELECT 1
                        FROM dbo.INVENTORYQCDETAIL WITH (NOLOCK)
                        WHERE QC_Key = @cQCKey
                        AND FinalizeFlag = 'N' )
                  BEGIN
                     BEGIN TRY
                        UPDATE dbo.INVENTORYQC WITH (ROWLOCK)
                        SET FinalizeFlag = 'Y'
                        WHERE QC_Key = @cQCKey
                           AND FinalizeFlag <> 'Y'
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 258655
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 258655 Update InventoryQC Failed
                        GOTO RollBackTran
                     END CATCH

                     SET @cPostFinalizeIQCSP = ''
                     EXEC nspGetRight 
                        @c_Facility = ''
                        ,@c_StorerKey = @cStorerKey
                        ,@c_sku = NULL
                        ,@c_ConfigKey = 'PostFinalizeIQCSP'
                        ,@b_Success = @bSuccess OUTPUT
                        ,@c_authority = @cPostFinalizeIQCSP OUTPUT
                        ,@n_err = @nErrNo OUTPUT
                        ,@c_errmsg = @cErrMsg OUTPUT  

                     IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cPostFinalizeIQCSP AND type = 'P')
                     BEGIN
                        SET @bSuccess = 0
                        BEGIN TRY
                           EXECUTE dbo.ispPostFinalizeIQCWrapper 
                                    @c_qc_key = @cQCKey,
                                    @c_PostFinalizeIQCSP = @cPostFinalizeIQCSP,
                                    @b_Success = @bSuccess OUTPUT,
                                    @n_Err = @nErrNo OUTPUT,
                                    @c_ErrMsg = @cErrMsg OUTPUT
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 258656
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update ispPostFinalizeIQCWrapper Failed
                           GOTO RollBackTran
                        END CATCH
                        
                        IF @nErrNo <> 0
                        BEGIN
                           GOTO RollBackTran
                        END
                     END
                  END
               END
            END

            COMMIT TRAN rdt_1730ExtUpd01 
         END
      END
   END

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1730ExtUpd01 -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1730ExtUpd01 TO NSQL
GO
