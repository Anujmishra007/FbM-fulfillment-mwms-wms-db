CREATE TABLE [dbo].[WorkStation]
(
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_WorkZone] DEFAULT ('RACK'),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkMethod] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_WorkMethod] DEFAULT (''),
[Descr] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoOfAssignedWorker] [int] NULL CONSTRAINT [DF_WorkStation_NoOfAssignedWorker] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkStation_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkStation_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_Status] DEFAULT ('0'),
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDownTime] [datetime] NULL,
[EndDownTime] [datetime] NULL,
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_WorkOrderKey] DEFAULT (''),
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_JobKey] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Trigger: ntrWorkStationDelete                                           */
/* Creation Date: 22-Oct-2012                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose:  Trigger when Delete Workstation                               */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Inserted                                        */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrWorkStationDelete] ON [dbo].[WorkStation]
FOR DELETE
AS
BEGIN
   IF @@ROWCOUNT = 0  
   BEGIN
	   RETURN
   END

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue  INT                     
         , @n_StartTCnt INT            -- Holds the current transaction count    
         , @b_Success   INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err       INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg    NVARCHAR(255)  -- Error message returned by stored procedure or this trigger    

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT     


   IF (SELECT COUNT(1) FROM DELETED) = (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
   BEGIN
	   SET @n_Continue = 4
      GOTO QUIT
   END

   IF EXISTS ( SELECT 1 
               FROM DELETED
               JOIN WORKORDERSTEPS WITH (NOLOCK)   ON (DELETED.WorkStation = WORKORDERSTEPS.WorkStation)
               JOIN WORKORDERROUTING WITH (NOLOCK) ON (WORKORDERSTEPS.WorkOrderName = WORKORDERROUTING.WorkOrderName)
                                                   AND(WORKORDERSTEPS.MasterWorkOrder= WORKORDERROUTING.MasterWorkOrder)
                                                   AND(WORKORDERROUTING.Facility = DELETED.Facility)
             )  
   BEGIN
      SET @n_continue = 3
      SET @n_err=63701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Not Allow to delete Work Station exists in WORKORDERSTEPS. (ntrWorkStationDelete)'
      GOTO QUIT
   END

   IF EXISTS ( SELECT 1 
               FROM DELETED
               JOIN WORKORDERREQUEST WITH (NOLOCK) ON (DELETED.Facility = WORKORDERREQUEST.Facility)
                                                   AND(DELETED.WorkStation = WORKORDERREQUEST.WorkStation)
             )  
   BEGIN
      SET @n_continue = 3
      SET @n_err=63701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Not Allow to delete Work Station exists in WORKORDERREQUEST. (ntrWorkStationDelete)'
      GOTO QUIT
   END
   DELETE WORKSTATIONLOC WITH (ROWLOCK) 
   FROM DELETED
   WHERE WORKSTATIONLOC.WorkStation = DELETED.WorkStation

QUIT:
   /* #INCLUDE <TRRDA2.SQL> */    
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
      ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_starttcnt    
         BEGIN    
            COMMIT TRAN    
         END     
      END    

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkStationDelete'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR 

 
      RETURN    
   END    
   ELSE    
   BEGIN    
      WHILE @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    

      RETURN    
   END      
END
GO
ALTER TABLE [dbo].[WorkStation] ADD CONSTRAINT [PK_WorkStation] PRIMARY KEY CLUSTERED ([WorkStation]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkStation] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkStation] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkStation] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkStation] TO [NSQL]
GO
