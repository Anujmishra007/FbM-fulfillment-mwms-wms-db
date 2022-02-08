CREATE TABLE [dbo].[VehicleDispatchDetail]
(
[VehicleDispatchKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_VehicleDispatchKey] DEFAULT (''),
[VehicleDispatchLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_VehicleDispatchLineNumber] DEFAULT (''),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_Orderkey] DEFAULT (''),
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_ExternOrderkey] DEFAULT (''),
[OrderLineNumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_OrderLineNumber] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_Sku] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_Qty] DEFAULT ((0)),
[Cube] [float] NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_Cube] DEFAULT ((0.00)),
[Weight] [float] NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_Weight] DEFAULT ((0.00)),
[NoOfPallet] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_NoOfPallet] DEFAULT ((0)),
[NoOfCarton] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_NoOfCarton] DEFAULT ((0)),
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_FinalizeFlag] DEFAULT ('N'),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_AddWho] DEFAULT (suser_name()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCHDETAIL_EditWho] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/  
/* Trigger: ntrVehicledispatchDetailDelete                              */  
/* Creation Date:                                                       */  
/* Copyright: LFL                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When delete records in VEHICLEDISPATCHDETAIL              */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/  
CREATE TRIGGER [dbo].[ntrVehicledispatchDetailDelete]
ON [dbo].[VehicleDispatchDetail]
FOR  DELETE
AS
BEGIN
    SET NOCOUNT ON  
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
   DECLARE @n_Continue        INT                     
         , @n_StartTCnt       INT            -- Holds the current transaction count    
         , @b_Success         INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err             INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg          NVARCHAR(255)  -- Error message returned by stored procedure or this trigger    

         , @c_VehicleDispatchKey NVARCHAR(10)          
         , @c_OrderKey           NVARCHAR(10)

         , @n_NoOfOrders      INT
         , @n_NoOfStops       INT
         , @n_NoOfCustomers   INT
    
         , @n_TotalCube       FLOAT   
         , @n_TotalWeight     FLOAT 
         , @n_TotalPallets    INT 
         , @n_TotalCartons    INT
         , @n_TotalDropIDs    INT
   
   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   

   IF (SELECT COUNT(1) FROM DELETED) = (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END

   DECLARE CUR_DEL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT 
          DELETED.VehicleDispatchKey
         ,DELETED.Orderkey
   FROM DELETED 

   OPEN CUR_DEL
   
   FETCH NEXT FROM CUR_DEL INTO @c_VehicleDispatchKey
                              , @c_OrderKey

   WHILE @@FETCH_STATUS <> -1  AND (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM VEHICLEDISPATCHDETAIL WITH (NOLOCK)
                     WHERE VehicleDispatchKey = @c_VehicleDispatchKey
                     AND   OrderKey = @c_OrderKey 
                     )
      BEGIN

         SET @n_NoOfOrders = 0
         SET @n_NoOfStops = 0
         SET @n_NoOfCustomers = 0
         SET @n_TotalCube = 0.00
         SET @n_TotalWeight = 0.00

         SELECT @n_NoOfOrders   = ISNULL(COUNT( DISTINCT VDD.Orderkey ),0)
            ,   @n_NoOfStops    = ISNULL(COUNT( DISTINCT OH.Stop ),0)
            ,   @n_NoOfCustomers= ISNULL(COUNT( DISTINCT OH.ConsigneeKey ),0)
            ,   @n_TotalCube    = ISNULL(SUM(VDD.Cube),0.00) 
            ,   @n_TotalWeight  = ISNULL(SUM(VDD.Weight),0.00)
         FROM VEHICLEDISPATCHDETAIL VDD WITH (NOLOCK)  
         JOIN ORDERS                OH  WITH (NOLOCK) ON (VDD.Orderkey = OH.Orderkey)
         WHERE VDD.VehicleDispatchKey = @c_VehicleDispatchKey

         SET @n_TotalPallets = 0
         SET @n_TotalCartons = 0
         SELECT  @n_TotalPallets = ISNULL(COUNT(DISTINCT PD.ID),0)
               , @n_TotalCartons = ISNULL(COUNT(DISTINCT PD.DropID),0)
              -- , @n_TotalDropIDs = COUNT(DISTINCT PD.DropID) 
         FROM VEHICLEDISPATCHDETAIL VDD WITH (NOLOCK) 
         JOIN PICKDETAIL        PD   WITH (NOLOCK) ON (VDD.Orderkey = PD.ORderkey) 
         WHERE VDD.VehicleDispatchKey = @c_VehicleDispatchKey
         AND PD.Status >= '5'

         UPDATE VEHICLEDISPATCH WITH (ROWLOCK)
         SET NoOfOrders    = @n_NoOfOrders
            ,NoOfStops     = @n_NoOfStops
            ,NoOfCustomers = @n_NoOfCustomers   
            ,TotalCube     = @n_TotalCube 
            ,TotalWeight   = @n_TotalWeight        
            ,TotalPallets  = @n_TotalPallets            
            ,TotalCartons  = @n_TotalCartons           
            ,Trafficcop    = NULL
            ,EditDate      = GETDATE()
            ,EditWho       = SUSER_NAME()
         WHERE VehicleDispatchKey = @c_VehicleDispatchKey

         SET @n_err = @@ERROR
         IF @n_err <> 0  
         BEGIN 
            SET @n_Continue= 3 
            SET @n_err  = 61005
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': UPDATE VEHICLEDISPATCH Failed.'
                          + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ). (ntrVehicledispatchDetailDelete) '
            GOTO QUIT
         END
      END

      FETCH NEXT FROM CUR_DEL INTO @c_VehicleDispatchKey
                                 , @c_OrderKey
   END
   CLOSE CUR_DEL
   DEALLOCATE CUR_DEL
    
   QUIT:
   IF CURSOR_STATUS( 'LOCAL', 'CUR_DEL') in (0 , 1)  
   BEGIN
      CLOSE CUR_DEL
      DEALLOCATE CUR_DEL
   END

   /* #INCLUDE <TRRDD2.SQL> */  
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SET @b_Success = 0

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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrVehicledispatchDetailDelete'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR 

      RETURN    
   END    
   ELSE    
   BEGIN  
      SET @b_Success = 1
  
      WHILE @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    

      RETURN    
   END  
END  
GO
ALTER TABLE [dbo].[VehicleDispatchDetail] ADD CONSTRAINT [PK_VehicleDispatchDetail] PRIMARY KEY CLUSTERED ([VehicleDispatchKey], [VehicleDispatchLineNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VehicleDispatchDetail_ExternOrderkey] ON [dbo].[VehicleDispatchDetail] ([ExternOrderkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VehicleDispatchDetail_OrderLineNumber] ON [dbo].[VehicleDispatchDetail] ([Orderkey], [OrderLineNumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VehicleDispatchDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VehicleDispatchDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VehicleDispatchDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VehicleDispatchDetail] TO [NSQL]
GO
