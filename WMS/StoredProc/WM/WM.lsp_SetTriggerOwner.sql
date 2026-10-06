SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: lsp_SetTriggerOwner                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Dual-run trigger routing (FN839 Phase 2).                   */
/*          Declares, per physical connection, TWO session-context      */
/*          signals used by migrated trigger guards:                    */
/*            wms.app_source        = 'MODERN'  (the modern app)        */
/*            wms.skip.<triggerName> = 1         (per migrated trigger)  */
/*          A migrated trigger skips its body ONLY when BOTH its         */
/*          app_source is MODERN AND its own wms.skip.<name> is set.     */
/*          Legacy SCE never calls this -> app_source unset -> every     */
/*          trigger runs in the DB exactly as today.                    */
/*          Both keys are @read_only = 1 (set once at connection init,   */
/*          cannot be flipped later within the same session).            */
/*                                                                      */
/* Date        Author   Rev   Purposes                                  */
/* 2026-09-28  AK01     1.0   Created (FN839 Phase 2 trigger migration)  */
/* 2026-09-29  AK01     1.1   Fix: EXEC param via @c_Key (CONCAT not     */
/*                            allowed in EXEC); CATCH logs + re-THROWs   */
/*                            so a failed init fails the connection.     */
/************************************************************************/
CREATE OR ALTER   PROCEDURE [WM].[lsp_SetTriggerOwner]
   @c_AppSource    NVARCHAR(20),         -- 'MODERN' (modern app). Legacy never calls this SP.
   @c_TriggerCsv   NVARCHAR(MAX) = ''    -- CSV of migrated + parity-passed triggers, e.g. 'ntrPickDetailUpdate,ntrLotUpdate'
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Err     INT = 0,
           @c_ErrMsg  NVARCHAR(250) = '',
           @c_Trigger NVARCHAR(128),
           @c_Key     NVARCHAR(128)

   BEGIN TRY
      -- Signal 1: which app is this request from. Read-only for the life of the session.
      EXEC sp_set_session_context @key = N'wms.app_source', @value = @c_AppSource, @read_only = 1;

      -- Signal 2: one wms.skip.<triggerName>=1 per migrated trigger named in the CSV.
      -- Empty/NULL CSV => no skip flags => modern app still runs every DB trigger.
      IF @c_TriggerCsv IS NOT NULL AND LTRIM(RTRIM(@c_TriggerCsv)) <> ''
      BEGIN
         DECLARE cur_trg CURSOR LOCAL FAST_FORWARD FOR
            SELECT LTRIM(RTRIM(value))
            FROM STRING_SPLIT(@c_TriggerCsv, ',')
            WHERE LTRIM(RTRIM(value)) <> ''

         OPEN cur_trg
         FETCH NEXT FROM cur_trg INTO @c_Trigger
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- EXEC parameters accept only constants/variables, so build the key first.
            SET @c_Key = CONCAT(N'wms.skip.', @c_Trigger);
            EXEC sp_set_session_context @key = @c_Key, @value = 1, @read_only = 1;
            FETCH NEXT FROM cur_trg INTO @c_Trigger
         END
         CLOSE cur_trg
         DEALLOCATE cur_trg
      END
   END TRY
   BEGIN CATCH
      -- Capture first: any later statement resets @@ERROR.
      SET @n_Err    = ERROR_NUMBER()
      SET @c_ErrMsg = LEFT(ERROR_MESSAGE(), 250)

      -- Clean up the cursor if the failure happened mid-iteration.
      IF CURSOR_STATUS('local', 'cur_trg') >= 0
         CLOSE cur_trg
      IF CURSOR_STATUS('local', 'cur_trg') >= -1
         DEALLOCATE cur_trg

      Execute nsp_logerror @n_Err, @c_ErrMsg, 'lsp_SetTriggerOwner';

      -- Fail closed: a partly-set session must not be used, or both the DB and Java bodies run.
      THROW;
   END CATCH

END -- End Procedure
GO

GRANT EXECUTE ON  [WM].[lsp_SetTriggerOwner] TO [NSQL]
GO
