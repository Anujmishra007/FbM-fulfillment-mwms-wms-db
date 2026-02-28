SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPRSHPMO02                                          */
/* Creation Date: 23-Jun-2025                                              */
/* Copyright: MAERSK                                                       */
/* Written by: Michael Lam                                                 */
/*                                                                         */
/* Purpose: UWP-30987 - Request update the MBOL pallet count when shipped  */
/*                                                                         */
/* Called By: ispPreMBOLShipWrapper                                        */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 23-Jun-2025  Michael 1.0   DevOps Combine Script                        */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPRSHPMO02]
(
   @c_MBOLkey   NVARCHAR(10)
 , @c_Storerkey NVARCHAR(15)
 , @b_Success   INT           OUTPUT
 , @n_Err       INT           OUTPUT
 , @c_ErrMsg    NVARCHAR(255) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue  INT = 1
         , @n_StartTCnt INT = @@TRANCOUNT

   DECLARE @c_Option5          NVARCHAR(4000)= ''
         , @c_ExtendedUpdate   NVARCHAR(10)  = ''
         , @c_Storerkey2       NVARCHAR(15)  = @c_Storerkey
         , @c_Code             NVARCHAR(30)
         , @c_FullFieldName    NVARCHAR(250)
         , @c_TableName        NVARCHAR(250)
         , @c_FieldName        NVARCHAR(250)
         , @c_Notes            NVARCHAR(MAX)
         , @c_SQL              NVARCHAR(MAX)

   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_ErrMsg = ''

   --Main Process
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SELECT @c_Option5 = SC.Option5
      FROM dbo.fnc_GetRight2('', @c_Storerkey2, '', 'PreMBOLShipSP') AS SC
      WHERE Authority='ispPRSHPMO02'

      SELECT @c_ExtendedUpdate = dbo.fnc_GetParamValueFromString ('@c_ExtendedUpdate', @c_option5, @c_ExtendedUpdate)

      IF ISNULL(@c_ExtendedUpdate,'')<>''
      BEGIN
         IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.CodeLkup WITH (NOLOCK)
                   WHERE Listname = @c_ExtendedUpdate AND Storerkey = @c_Storerkey2 )
            SET @c_Storerkey2 = ''

         DECLARE C_EXTENDED_UPDATE CURSOR FAST_FORWARD READ_ONLY FOR
          SELECT Code
               , ISNULL(TRIM(Long), '')
               , Notes
            FROM dbo.CodeLkup WITH (NOLOCK)
           WHERE Listname = @c_ExtendedUpdate
             AND Storerkey = @c_Storerkey2
             AND Short = 'Y'
             AND ISNULL(Notes,'')<>''
           ORDER BY Code

         OPEN C_EXTENDED_UPDATE

         WHILE 1=1
         BEGIN
            FETCH NEXT FROM C_EXTENDED_UPDATE
            INTO @c_Code, @c_FullFieldName, @c_Notes

            IF @@FETCH_STATUS<>0
               BREAK

            IF ISNULL(@c_FullFieldName,'') = '' OR ISNULL(@c_Notes,'') = ''
               CONTINUE

            SELECT @c_TableName = ''
                 , @c_FieldName = ''

            SELECT @c_TableName = ISNULL(MAX(CASE WHEN SeqNo=1 THEN TRIM(ColValue) END), '')
                 , @c_FieldName = ISNULL(MAX(CASE WHEN SeqNo=2 THEN TRIM(ColValue) END), '')
            FROM dbo.fnc_DelimSplit('.', REPLACE(REPLACE(@c_FullFieldName,'[',''),']',''))

            IF @c_TableName<>'' AND ISNULL(@c_FieldName,'')=''
            BEGIN
               SET @c_FieldName = @c_TableName
               SET @c_TableName = 'MBOL'
            END

            IF ISNULL(@c_TableName, '') NOT IN ('MBOL')
            BEGIN
               SET @n_Continue = 3
               SET @n_err  = 35100
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Table [' + ISNULL(@c_TableName,'') + '] Not Allowed. (ispPRSHPMO02)'
               BREAK
            END

            IF NOT EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = @c_TableName AND COLUMN_NAME= @c_FieldName )
            BEGIN
               SET @n_Continue = 3
               SET @n_err  = 35101
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Field ' + ISNULL(@c_TableName,'')+'.'+ISNULL(@c_FieldName,'') + ' Not Exist. (ispPRSHPMO02)'
               BREAK
            END

            IF @c_FieldName IN ('MbolKey', 'Status', 'Facility', 'AddDate', 'AddWho', 'EditDate', 'EditWho', 'TrafficCop', 'ArchiveCop', 'TimeStamp')
            BEGIN
               SET @n_Continue = 3
               SET @n_err  = 35102
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not Allow to Update Field ' + ISNULL(@c_TableName,'')+'.'+ISNULL(@c_FieldName,'') + '. (ispPRSHPMO02)'
               BREAK
            END

            SET @c_SQL = ''
            IF @c_TableName = 'MBOL'
               SET @c_SQL = N'UPDATE ' + ISNULL(@c_TableName,'') + ' WITH(ROWLOCK)' + CHAR(10)
                          + ' SET '    + ISNULL(@c_FieldName,'') + ' = ' + ISNULL(@c_Notes,'') + CHAR(10)
                          + ' WHERE MBOL.MBOLKey = ''' + ISNULL(REPLACE(@c_MBOLKey,'''',''''''),'') + ''''
            IF @c_SQL <> ''
            BEGIN
               BEGIN TRY
                  EXEC sp_ExecuteSQL @c_SQL
               END TRY
               BEGIN CATCH
                  IF XACT_STATE() = -1   -- uncommittable transaction
                     ROLLBACK TRAN

                  SET @n_Continue = 3
                  SET @n_err  = 35103
                  SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Extended Update Err ' + ISNULL(@c_Code,'') + ' (' + ISNULL(ERROR_MESSAGE(),'') +'). (ispPRSHPMO02)'
                  BREAK
               END CATCH
            END
         END

         CLOSE C_EXTENDED_UPDATE
         DEALLOCATE C_EXTENDED_UPDATE
      END
   END

   QUIT_SP:
   IF CURSOR_STATUS('LOCAL', 'C_EXTENDED_UPDATE') IN ( 0, 1 )
   BEGIN
      CLOSE C_EXTENDED_UPDATE
      DEALLOCATE C_EXTENDED_UPDATE
   END

   IF @n_Continue = 3 -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPRSHPMO02'
      RAISERROR(@c_ErrMsg, 16, 1) WITH SETERROR -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[ispPRSHPMO02] TO [NSQL]
GO