SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/
/* Stored Procedure: isp_QCmd_GetPendingTask                                     */
/* Creation Date: 02-Aug-2021                                                    */
/* Copyright: LFL                                                                */
/* Written by: TKLIM                                                             */
/*                                                                               */
/* Purpose: Get Pending Task in TCPSocket_QueueTask table                        */
/*                                                                               */
/* Usage: Pass in @c_Port = XXXXX to get task for this specific Port number only */
/*        Pass In @c_Status = R0WT to filter Task with status R,W,0,T            */
/*        Pass In @c_LastID = 1 to filter Task start from ID = 1                 */
/*                                                                               */
/* Called By: QCSvc                                                              */
/*                                                                               */
/* PVCS Version: 1.0                                                             */
/*                                                                               */
/* Updates:                                                                      */
/* Date         Author   Ver        Purposes                                     */
/* 01-Aug-2021  TKLim    2.0.9.8    Initial                                      */
/* 27-Aug-2021  TKLim    2.1.0.0    Get table Schema to support OMS DB           */
/* 23-Nov-2022  TKLim    2.1.0.9    Ensure status=0 before return to QCMD        */
/* 09-May-2025  TLTING   2.1.1.0    Performance tune, avoid blocking             */
/*********************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_QCmd_GetPendingTask]
(
     @c_Port      NVARCHAR(5)
   , @c_Status    NVARCHAR(10)
   , @c_LastID    NVARCHAR(20)  = 0
   , @b_Success   INT           = 1  OUTPUT
   , @n_Err       INT           = 0  OUTPUT
   , @c_ErrMsg    NVARCHAR(256) = '' OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   /*********************************************/
   /* Variables Declaration                     */
   /*********************************************/
   CREATE TABLE #tbl_QueueTask (
        RowRef      INT            NOT NULL IDENTITY(1,1) PRIMARY KEY
      , ID          BIGINT         NOT NULL
      , CmdType     NVARCHAR(10)   NOT NULL
      , Cmd         NVARCHAR(1024) NOT NULL
      , TargetDB    NVARCHAR(30)   NOT NULL
      , Priority    INT            NOT NULL
      , HashValue   TINYINT        NULL
   )

   DECLARE @n_ID               BIGINT
         , @cTableSchema       NVARCHAR(200)
         , @cDBName            NVARCHAR(200)
         , @cSQLStatement      NVARCHAR(4000)
         , @cSQLStatement2     NVARCHAR(4000)
         , @cSQLParms          NVARCHAR(4000)
         , @cSQLParms2         NVARCHAR(4000)
         , @c_NewStatus        NVARCHAR(1)
         , @n_Retry            INT
         , @n_QueueTask_RowRef INT
         , @n_HashValue        TINYINT

   SET @n_ID         = 0
   SET @cTableSchema = ''
   SET @cDBName      = DB_NAME()
   SET @c_NewStatus  = ''
   SET @n_Retry      = 0

   /*********************************************/
   /* Variables Validation                      */
   /*********************************************/

   IF ISNULL(RTRIM(@c_Port),'') = ''
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 68002
      SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_err) + ': Port cannot be blank! (isp_QCmd_GetPendingTask)'
      GOTO QUIT
   END

   IF ISNULL(RTRIM(@c_Status),'') = ''
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 68002
      SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_err) + ': Status cannot be blank! (isp_QCmd_GetPendingTask)'
      GOTO QUIT
   END

   --Get table schema for TCPSocket_QueueTask
   SET @cSQLStatement = N'SELECT TOP 1 @cTableSchema = TBL.TABLE_SCHEMA ' +
                         ' FROM ' + QUOTENAME(@cDBName) + '.[INFORMATION_SCHEMA].[TABLES] TBL WITH (NOLOCK) ' +
                         ' WHERE tbl.TABLE_NAME = ''TCPSocket_QueueTask'' '
   EXEC master.sys.sp_ExecuteSQL @cSQLStatement, N'@cTableSchema NVARCHAR(200) OUTPUT', @cTableSchema OUTPUT

   /*********************************************/
   /* INSERT INTO Variable Table                */
   /*********************************************/

   IF @c_Status = 'R0WT'
   BEGIN
      --Filter status with R0WT
      SET @cSQLStatement =
         N' INSERT INTO #tbl_QueueTask (ID, CmdType, Cmd, TargetDB, Priority, HashValue) ' +
         N' SELECT ID, CmdType, Cmd, TargetDB, Priority, HashValue ' +
         N' FROM ' + QUOTENAME(@cDBName) + '.' + QUOTENAME(@cTableSchema) + '.TCPSocket_QueueTask WITH (NOLOCK, FORCESEEK) ' +
         N' WHERE Port = @c_Port ' +
         N' AND ID > CAST(@c_LastID AS BIGINT) ' +
         N' AND Status IN (''R'', ''0'', ''W'', ''T'') ' +
         N' ORDER BY ID ASC '
   END
   ELSE
   BEGIN
      SET @cSQLStatement =
         N' INSERT INTO #tbl_QueueTask (ID, CmdType, Cmd, TargetDB, Priority, HashValue) ' +
         N' SELECT ID, CmdType, Cmd, TargetDB, Priority, HashValue ' +
         N' FROM ' + QUOTENAME(@cDBName) + '.' + QUOTENAME(@cTableSchema) + '.TCPSocket_QueueTask WITH (NOLOCK, FORCESEEK)  ' +
         N' WHERE Port = @c_Port ' +
         N' AND ID > CAST(@c_LastID as BIGINT) ' +
         N' AND Status = @c_Status ' +
         N' ORDER BY ID ASC '
   END

   SET @cSQLParms = N' @c_Port   NVARCHAR(5)'
                  + ', @c_LastID NVARCHAR(20)'
                  + ', @c_Status NVARCHAR(10)'

   EXEC master.sys.sp_ExecuteSQL @cSQLStatement
                               , @cSQLParms
                               , @c_Port
                               , @c_LastID
                               , @c_Status

   /******************************************************/
   /* UPDATE Status = 0 to indicate Picked Up by Qcmd    */
   /******************************************************/
   DECLARE C_QCSvc_JSON CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT ID, HashValue, RowRef
   FROM #tbl_QueueTask WITH (NOLOCK)
   ORDER BY RowRef

   OPEN C_QCSvc_JSON
   FETCH NEXT FROM C_QCSvc_JSON INTO @n_ID, @n_HashValue, @n_QueueTask_RowRef

   WHILE (@@FETCH_STATUS <> -1)
   BEGIN
      --UPDATE Statement
      SET @cSQLStatement =
         N' UPDATE ' + QUOTENAME(@cDBName) + '.' + QUOTENAME(@cTableSchema) + '.TCPSocket_QueueTask ' +
         N' SET Status = ''0'' ' +
         N' WHERE ID = @n_ID ' +
         N' AND HashValue = @n_HashValue ' +
         N' AND Status <> ''0'' '

      SET @cSQLParms = N' @n_ID BIGINT'
                     + N', @n_HashValue TINYINT '

      --SELECT Query for update confirmation
      SET @cSQLStatement2 =
         N' SELECT @c_NewStatus = Status ' +
         N' FROM ' + QUOTENAME(@cDBName) + '.' + QUOTENAME(@cTableSchema) + '.TCPSocket_QueueTask WITH (NOLOCK) ' +
         N' WHERE ID = @n_ID ' +
         N' AND HashValue = @n_HashValue '

      SET @cSQLParms2 = N' @n_ID BIGINT'
                      + N', @n_HashValue TINYINT '
                      + N', @c_NewStatus NVARCHAR(1) OUTPUT'

      SET @c_NewStatus = ''
      SET @n_Retry = 0

      --Loop while the status still not updated. retry limit 5x
      WHILE @c_NewStatus <> '0' AND @n_Retry < 5
      BEGIN
         BEGIN TRY
            BEGIN TRAN
            --UPDATE Status to 0
            EXEC master.sys.sp_ExecuteSQL @cSQLStatement, @cSQLParms, @n_ID, @n_HashValue

            WHILE @@TranCount  > 0
               COMMIT TRAN

            --QUERY status to confirm update success.
            EXEC master.sys.sp_ExecuteSQL @cSQLStatement2, @cSQLParms2, @n_ID, @n_HashValue, @c_NewStatus OUTPUT

            SET @n_Retry = @n_Retry + 1
         END TRY
         BEGIN CATCH
            -- A TRY-CATCH construct catches all execution errors that have a severity higher than 10 that do not close the database connection.
            SET @n_Retry = 5
         END CATCH
      END

      --If still failed to update to '0', Delete from table and not return to Qcmd Queue.
      IF @c_NewStatus <> '0' AND @n_Retry >= 5
      BEGIN
         --DELETE record from temp table
         SET @cSQLStatement =  N' DELETE FROM #tbl_QueueTask WHERE ID = @n_ID AND RowRef = @n_QueueTask_RowRef '
         SET @cSQLParms = N' @n_ID BIGINT'
                        + N', @n_QueueTask_RowRef INT '

         EXEC master.sys.sp_ExecuteSQL @cSQLStatement, @cSQLParms, @n_ID, @n_QueueTask_RowRef
      END

      FETCH NEXT FROM C_QCSvc_JSON INTO @n_ID, @n_HashValue, @n_QueueTask_RowRef
   END --End of while
   CLOSE C_QCSvc_JSON
   DEALLOCATE C_QCSvc_JSON

   /******************************************************/
   /* Query and Return data from Variable Table          */
   /******************************************************/
   SELECT ID, CmdType, Cmd, TargetDB, Priority
   FROM #tbl_QueueTask WITH (NOLOCK)

   QUIT:
END -- End of Procedure
GO
GRANT EXECUTE ON [dbo].[isp_QCmd_GetPendingTask] TO nSQL
GO
