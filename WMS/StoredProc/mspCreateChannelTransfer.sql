SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: mspCreateChannelTransfer                           */
/* Creation Date: 17-APR-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by:    Supriya Sangeetham                                    */
/*                                                                      */
/* Purpose: PAGE – CHANNEL TRANSFER CREATION ON MOVE (SCE UI)  */
/* Called By: nspItrnAddMoveCheck from move        */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date                   Author    Ver  Purposes                       */
/* 17-APR-2026  SSA01       1.0  FCR-12159 - CHANNEL TRANSFER           */
/*                                         CREATION ON MOVEMENT (SCE UI)*/
/************************************************************************/
CREATE OR ALTER PROC mspCreateChannelTransfer
   @c_StorerKey        NVARCHAR(15),
    @c_Facility      NVARCHAR(5),
   @c_Itrnkey      NVARCHAR(10),
   @c_Sku          NVARCHAR(20),
   @c_FromLoc      NVARCHAR(10),
   @c_ToLoc        NVARCHAR(10),
   @n_Qty          INT ,
   @c_Lottable01   NVARCHAR(18) = ''  ,
   @b_Success          INT      OUTPUT,
   @n_Err              INT      OUTPUT, 
   @c_ErrMsg           NVARCHAR(250) OUTPUT    
AS   
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @n_Continue       INT,
           @n_StartTCnt      INT
                                                                 
   SELECT @n_Continue = 1, @n_StartTCnt = @@TRANCOUNT, @n_Err = 0, @c_ErrMsg = '', @b_Success = 1
   IF @@TRANCOUNT = 0
   BEGIN TRAN
	   
   DECLARE @c_ChannelInventoryMgmt   NVARCHAR(30),
                   @c_ChannelTransferkey     NVARCHAR(10),
                   @c_FromLocHosWHtCode     NVARCHAR(10),
                   @c_ToLocHostWHCode       NVARCHAR(10),
                   @c_Reasoncode          NVARCHAR(10) = 'MOVE',
                   @c_Type         NVARCHAR(10) = 'MOVE'

   
   SELECT @c_ChannelInventoryMgmt = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'ChannelInventoryMgmt') 
   
   IF @c_ChannelInventoryMgmt <> '1'
      GOTO QUIT_SP

   SELECT @c_FromLocHosWHtCode = ISNULL(HOSTWHCODE,'') FROM Loc WITH (NOLOCK) WHERE Loc = @c_FromLoc
   SELECT @c_ToLocHostWHCode = ISNULL(HOSTWHCODE,'') FROM Loc WITH (NOLOCK) WHERE Loc = @c_ToLoc

   IF @n_continue IN(1,2) AND @c_FromLocHosWHtCode <> ''
   AND  @c_ToLocHostWHCode <> '' AND @c_FromLocHosWHtCode  <>  @c_ToLocHostWHCode
   BEGIN

               EXEC dbo.nspg_GetKey                
                  @KeyName = 'ChannelTransferKey'    
                 ,@fieldlength = 10    
                 ,@keystring = @c_ChannelTransferkey OUTPUT    
                 ,@b_Success = @b_success OUTPUT    
                 ,@n_err = @n_err OUTPUT    
                 ,@c_errmsg = @c_errmsg OUTPUT
                 ,@b_resultset = 0    
                 ,@n_batch     = 1                              
               
               INSERT INTO ChannelTransfer (  
                           ChannelTransferKey
                          ,ExternChannelTransferKey
                          ,FromStorerKey
                          ,ToStorerKey
                          ,Type
                          ,ReasonCode
                          ,Facility
                          ,ToFacility
                         )
               VALUES (@c_ChannelTransferkey
                       ,@c_Itrnkey
                       ,@c_Storerkey
                       ,@c_Storerkey
                       ,@c_Type
                       ,@c_Reasoncode
                       ,@c_Facility
                       ,@c_Facility
                      )
                       
               SET @n_Err = @@ERROR
               IF @n_Err <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err)
                  SET @n_Err      = 62100
                  SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Insert ChannelTransfer Failed'
                                  + '. (mspCreateChannelTransfer)( SQLSvr MESSAGE='
                                  + RTRIM(@c_Errmsg) + ' ) '              
                  GOTO QUIT_SP                
               END       
                      
               INSERT INTO ChannelTransferDetail (
                           ChannelTransferKey
                          ,ChannelTransferLineNumber
                          ,ExternChannelTransferKey
                          ,FromStorerKey
                          ,FromSku
                          ,FromQty
                          ,ToStorerKey
                          ,ToSku
                          ,ToQty
                          ,FromC_Attribute01
                          ,ToC_Attribute01
                          ,FromChannel
                          ,ToChannel
                         )
                VALUES (@c_ChannelTransferkey
                       ,'00001'
                        ,@c_Itrnkey
                       ,@c_Storerkey
                       ,@c_Sku
                       ,@n_Qty
                       ,@c_Storerkey
                       ,@c_Sku           
                       ,@n_Qty
                       , @c_Lottable01
                       , @c_Lottable01
                       ,@c_FromLocHosWHtCode
                       ,@c_ToLocHostWHCode
                       )
                       
               SET @n_Err = @@ERROR
               IF @n_Err <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err)
                  SET @n_Err      = 62110
                  SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Insert ChannelTransferDetail Failed'
                                  + '. (mspCreateChannelTransfer)( SQLSvr MESSAGE='
                                  + RTRIM(@c_Errmsg) + ' ) '
                  GOTO QUIT_SP                                                
               END

     END

      
QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process AND Return
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'mspCreateChannelTransfer'
      --RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END  
END  
GO

GRANT EXECUTE ON [mspCreateChannelTransfer] TO NSQL
GO
