IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_Unallocation_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_Unallocation_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: lsp_Unallocation_Wrapper                           */  
/* Creation Date: 14-Mar-2018                                           */  
/* Copyright: LFLogistics                                               */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: Unallocation                                                */  
/*                                                                      */  
/* Called By: Unallocation                                              */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 8.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/* 28-Dec-2020  SWT01    1.0  Adding Begin Try/Catch                     */
/************************************************************************/   
CREATE PROCEDURE [WM].[lsp_Unallocation_Wrapper]
    @c_Storerkey NVARCHAR(15) = ''      --optional
   ,@c_Pickdetailkey NVARCHAR(10) = ''  --optional  
   ,@c_Orderkey NVARCHAR(10) = ''       --optional
   ,@c_OrderLineNumber NVARCHAR(5) = '' --optional
   ,@c_Loadkey NVARCHAR(10) = ''        --optional
   ,@c_Wavekey NVARCHAR(10) = ''        --optional
   ,@c_Sku     NVARCHAR(15) = ''        --optional
   ,@b_Success INT = 1 OUTPUT 
   ,@n_Err INT = 0 OUTPUT
   ,@c_ErrMsg NVARCHAR(250) = '' OUTPUT
   ,@c_UserName NVARCHAR(128) = ''
   ,@c_UnAllocateFrom NVARCHAR(20) = ''  --ORDER = Shipment Order Screen (Pickdetaileky)
                                         --UAORDER = Unallocate Orders screen   (orderkey)
                                         --UAPICKLINE = Unallocate Pickdetail Lines screen  (pickdetailkey)
                                         --UALOAD = Unallocate LoadPlan screen (storerkey,loadkey,sku)
                                         --UATMLOAD = Unallocate TM Load Screen (storerkey, loadkey)
                                         --UAWAVE = Unallocate Wave screen (storerkey, wavekey)
                                         --UAWAVEBYLOAD = Unallocate Wavebyload screen (storerkey, wavekey, loadkey)
                                         --UAWAVEBYSKU = Unallocate Wavebysku screen (storerkey, wavekey, sku)
AS
BEGIN 
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF
    
    SET @n_Err = 0 
    EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT
    
    IF @n_Err <> 0 
    BEGIN
      GOTO EXIT_SP
    END
    
    EXECUTE AS LOGIN = @c_UserName
    BEGIN TRY -- SWT01 - Begin Outer Begin Try   
    
    DECLARE @n_Continue              INT
           ,@n_starttcnt             INT

    SELECT @n_starttcnt=@@TRANCOUNT, @n_err=0, @b_success=1, @c_errmsg='', @n_continue=1

    IF @n_continue IN(1,2)
    BEGIN      
       IF ISNULL(@c_Pickdetailkey,'') = '' AND ISNULL(@c_Orderkey,'') = '' AND ISNULL(@c_Loadkey,'') = '' AND ISNULL(@c_Wavekey,'') = ''
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_Err = 551801
          SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + 
                ': All key parameters are empty. (lsp_Unallocation_Wrapper)'
       END       
    END
    
    IF @n_continue IN(1,2) AND @c_UnallocateFrom = 'UALOAD'    
    BEGIN
       EXECUTE dbo.ispUnallocate_DynamicLPAlloc @c_Storerkey=@c_Storerkey, @c_Loadkey=@c_LoadKey, @c_Sku=@c_SKU 

       SET @n_err =  @@ERROR 
       
       IF @n_err <> 0
       BEGIN
          SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 551802
             SELECT @c_errmsg='NSQL'+CONVERT(char(6),@n_err)+': Execute dbo.ispUnallocate_DynamicLPAlloc Failed. (lsp_Unallocation_Wrapper)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
       END                
    END

    IF @n_continue IN(1,2) AND @c_UnallocateFrom = 'UATMLOAD'    
    BEGIN
       EXECUTE dbo.ispUnallocate_TMLoadPlan_Wrapper @c_Storerkey=@c_Storerkey, @c_Loadkey=@c_LoadKey

       SET @n_err =  @@ERROR 
       
       IF @n_err <> 0
       BEGIN
          SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 551803
             SELECT @c_errmsg='NSQL'+CONVERT(char(6),@n_err)+': Execute dbo.ispUnallocate_TMLoadPlan_Wrapper Failed. (lsp_Unallocation_Wrapper)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
       END                
    END

    IF @n_continue IN(1,2) AND @c_UnallocateFrom = 'UAWAVE'    
    BEGIN
       EXECUTE dbo.ispUnallocate_DynamicWaveAlloc_byWave @c_Storerkey=@c_Storerkey, @c_Wavekey=@c_waveKey 

       SET @n_err =  @@ERROR 
       
       IF @n_err <> 0
       BEGIN
          SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 551804
             SELECT @c_errmsg='NSQL'+CONVERT(char(6),@n_err)+': Execute dbo.ispUnallocate_DynamicWaveAlloc_byWave Failed. (lsp_Unallocation_Wrapper)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
       END                
    END

    IF @n_continue IN(1,2) AND @c_UnallocateFrom = 'UAWAVEBYLOAD'    
    BEGIN
       EXECUTE dbo.ispUnallocate_DynamicWaveAlloc_byLoad @c_Storerkey=@c_Storerkey, @c_Wavekey=@c_WaveKey, @c_Loadkey=@c_Loadkey 

       SET @n_err =  @@ERROR 
       
       IF @n_err <> 0
       BEGIN
          SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 551805
             SELECT @c_errmsg='NSQL'+CONVERT(char(6),@n_err)+': Execute dbo.ispUnallocate_DynamicWaveAlloc_byLoad Failed. (lsp_Unallocation_Wrapper)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
       END                
    END
    
    IF @n_continue IN(1,2) AND @c_UnallocateFrom = 'UAWAVEBYSKU'    
    BEGIN
       EXECUTE dbo.ispUnallocate_DynamicWaveAlloc_bySku @c_Storerkey=@c_Storerkey, @c_Wavekey=@c_WaveKey, @c_Sku=@c_Sku

       SET @n_err =  @@ERROR 
       
       IF @n_err <> 0
       BEGIN
          SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 551806
             SELECT @c_errmsg='NSQL'+CONVERT(char(6),@n_err)+': Execute dbo.ispUnallocate_DynamicWaveAlloc_bySku Failed. (lsp_Unallocation_Wrapper)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
       END                
    END
         
    IF @n_continue IN(1,2) AND ISNULL(@c_UnallocateFrom,'') IN ('','ORDER','UAORDER','UAPICKLINE')
    BEGIN
       DECLARE CUR_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT PD.Pickdetailkey
          FROM   PICKDETAIL PD WITH (NOLOCK)           
          JOIN   ORDERS  OH WITH(NOLOCK) ON OH.Orderkey = PD.Orderkey 
          WHERE  PD.Pickdetailkey = CASE WHEN ISNULL(@c_Pickdetailkey,'') <> '' THEN @c_Pickdetailkey ELSE PD.Pickdetailkey END 
          AND    OH.Orderkey = CASE WHEN ISNULL(@c_Orderkey,'') <> '' THEN @c_Orderkey ELSE OH.Orderkey END
          AND    PD.OrderLineNumber = CASE WHEN ISNULL(@c_OrderLineNumber,'') <> '' THEN @c_OrderLineNumber ELSE PD.OrderLineNumber END
          AND    OH.Loadkey = CASE WHEN ISNULL(@c_Loadkey,'') <> '' THEN @c_Loadkey ELSE OH.Loadkey END
          AND    OH.Userdefine09 = CASE WHEN ISNULL(@c_Wavekey,'') <> '' THEN @c_Wavekey ELSE OH.Userdefine09 END
          AND    OH.Storerkey = CASE WHEN ISNULL(@c_Storerkey,'') <> '' THEN @c_Storerkey ELSE OH.Storerkey END
          AND    PD.Sku = CASE WHEN ISNULL(@c_Sku,'') <> '' THEN @c_Sku ELSE PD.Sku END
          AND    PD.Status <> '9'

       OPEN CUR_PICKDETAIL
       
       FETCH FROM CUR_PICKDETAIL INTO @c_Pickdetailkey
       
       WHILE @@FETCH_STATUS=0 AND @n_continue IN(1,2)
       BEGIN
           DELETE PICKDETAIL
           WHERE Pickdetailkey = @c_Pickdetailkey
 
          SET @n_err =  @@ERROR 

          IF @n_err <> 0
          BEGIN
             SELECT @n_continue = 3  
                SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 551807
                SELECT @c_errmsg='NSQL'+CONVERT(char(6),@n_err)+': All key parameters are empty. (lsp_Unallocation_Wrapper)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
           END           
       
          FETCH FROM CUR_PICKDETAIL INTO @c_Pickdetailkey
       END          
       CLOSE CUR_PICKDETAIL
       DEALLOCATE CUR_PICKDETAIL     
    END    
    
    END TRY  
  
    BEGIN CATCH      
       GOTO EXIT_SP  
    END CATCH -- (SWT01) - End Big Outer Begin try.. end Try Begin Catch.. End Catch  
    
    EXIT_SP: 
    REVERT
    
    IF @n_continue=3  -- Error Occured - Process And Return  
    BEGIN  
       SELECT @b_success = 0  
       IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt  
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
       execute nsp_logerror @n_err, @c_errmsg, 'lsp_Unallocation_Wrapper'  
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
       RETURN  
    END  
    ELSE  
    BEGIN  
       SELECT @b_success = 1  
       WHILE @@TRANCOUNT > @n_starttcnt  
       BEGIN  
          COMMIT TRAN  
       END  
       RETURN  
    END                
END
GO
GRANT EXECUTE ON [WM].[lsp_Unallocation_Wrapper] TO nSQL 
GO
