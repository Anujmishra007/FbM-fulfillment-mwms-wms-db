IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispCTNLBLITF04]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[ispCTNLBLITF04]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  
/************************************************************************/  
/* Stored Procedure: ispCTNLBLITF04                                     */  
/* Creation Date: 18-AUG-2021                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: CSCHONG                                                  */  
/*                                                                      */  
/* Purpose: WMS-17646 - SG - PRSG - ECOM Packing Despatch               */  
/*                                                                      */  
/* Called By: isp_PrintCartonLabel_Interface                            */  
/*                                                                      */  
/* GitLab Version: 1.0                                                  */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Ver   Purposes                                  */  
/* 26-OCT-2021 CSCHONG  1.0   Devops Scripts combine                    */
/************************************************************************/  
CREATE PROCEDURE [dbo].[ispCTNLBLITF04]  
      @c_Pickslipno   NVARCHAR(10)       
  ,   @n_CartonNo_Min INT   
  ,   @n_CartonNo_Max INT   
  ,   @b_Success      INT           OUTPUT    
  ,   @n_Err          INT           OUTPUT    
  ,   @c_ErrMsg       NVARCHAR(255) OUTPUT  
     
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
        
   DECLARE @n_continue        INT  
         , @n_starttcnt       INT  
         , @n_SUMPackQty      INT = 0  
         , @n_SUMPickQty      INT = 0  
         , @c_Orderkey        NVARCHAR(10)  
         , @c_ECOM_S_Flag     NVARCHAR(1)  
         , @c_Storerkey       NVARCHAR(15)  
         , @c_shipperkey      NVARCHAR(45)  
         , @c_trackingno      NVARCHAR(20)  
         , @n_Cartonno        INT  
         , @c_userid          NVARCHAR(30)   
         , @c_PrinterID       NVARCHAR(20)     
         , @c_LabelType       NVARCHAR(30)  
         , @c_Facility        NVARCHAR(10)  
         , @c_Parm01          NVARCHAR(80)   
         , @c_Parm02          NVARCHAR(80)   
         , @c_Parm03          NVARCHAR(80)    
         , @c_Parm04          NVARCHAR(80)   
         , @c_Parm05          NVARCHAR(80)   
         , @c_Parm06          NVARCHAR(80)   
         , @c_Parm07          NVARCHAR(80)   
         , @c_Parm08          NVARCHAR(80)    
         , @c_Parm09          NVARCHAR(80)   
         , @c_Parm10          NVARCHAR(80)  
         , @c_Returnresult    NVARCHAR(20)   
         , @c_key2            NVARCHAR(30)  
         , @c_trmlogkey       NVARCHAR(10)      
     
   DECLARE @c_PrintCartonLabelByITF   NVARCHAR(100)  
         , @c_Option1                 NVARCHAR(255)  
         , @c_Option2                 NVARCHAR(255)  
         , @c_Option3                 NVARCHAR(255)  
                                                                                                 
   SET @n_err = 0  
   SET @b_success = 1  
   SET @c_errmsg = ''  
   SET @n_continue = 1  
   SET @n_starttcnt = @@TRANCOUNT  
  
   SET @c_trackingno = ''  
   SET @n_Cartonno = 1  
  
  SET @c_userid = SUSER_SNAME()  
  SET @c_LabelType ='UCCLBLSG01'  
  
  SET @c_Parm01 = ''  
  SET @c_Parm02 = ''  
  SET @c_Parm03 = ''  
  SET @c_Parm04 = ''  
  SET @c_Parm05 = ''  
  SET @c_Parm06 = ''  
  SET @c_Parm07 = ''  
  SET @c_Parm08 = ''  
  SET @c_Parm09 = ''  
  SET @c_Parm10 = ''  
     
   SELECT TOP 1   
       @c_Facility = DefaultFacility  
      ,@c_PrinterID = DefaultPrinter  
   FROM RDT.RDTUser (NOLOCK)     
   WHERE UserName = @c_userid  
  
   --SELECT @n_SUMPackQty = SUM(PACKDETAIL.Qty)  
   --FROM PACKDETAIL (NOLOCK)  
   --WHERE PACKDETAIL.PickSlipNo = @c_Pickslipno  
  
   --SELECT @n_SUMPickQty = SUM(PD.Qty)  
   --     , @c_Orderkey   = MAX(PH.Orderkey)  
   --FROM PACKHEADER PH (NOLOCK)  
   --JOIN PICKDETAIL PD (NOLOCK) ON PD.OrderKey = PH.Orderkey  
   --WHERE PH.PickSlipNo = @c_Pickslipno  
  
 SELECT  @c_Storerkey = ORDERS.StorerKey  
        , @c_OrderKey = ORDERS.OrderKey   
       -- , @c_ExtOrderkey = ORDERS.ExternOrderKey  
        , @c_Shipperkey = ORDERS.ShipperKey  
         ,@c_ECOM_S_Flag = ORDERS.ECOM_SINGLE_Flag   
   FROM PACKHEADER (NOLOCK)  
   JOIN ORDERS (NOLOCK) ON PACKHEADER.Orderkey = ORDERS.Orderkey  
   WHERE PACKHEADER.PickSlipNo = @c_PickSlipNo   
  
  
     
    IF @n_CartonNo_Min = @n_CartonNo_Max  
    BEGIN  
       SET @n_Cartonno = @n_CartonNo_Min  
    END  
    ELSE  
    BEGIN  
       SELECT @n_CartonNo = MAX(PD.Cartonno)  
       FROM dbo.PackDetail PD WITH (NOLOCK)  
       WHERE PD.PickSlipNo = @c_Pickslipno  
    END  
  
    SELECT TOP 1 @c_trackingno = PIF.Trackingno  
    FROM PACKINFO PIF WITH (NOLOCK)  
    WHERE PIF.PickSlipNo = @c_Pickslipno   
    AND PIF.CartonNo = @n_Cartonno  
     
  
   --IF ISNULL(@n_SUMPackQty, 0) = 0  
   --   SET @n_SUMPackQty = 0  
  
   --IF ISNULL(@n_SUMPickQty, 0) = 0  
   --   SET @n_SUMPickQty = 0  
  
   --SELECT @c_ECOM_S_Flag = OH.ECOM_SINGLE_Flag  
   --     , @c_Storerkey   = OH.StorerKey  
   --     , @c_shipperkey = OH.ShipperKey  
   --FROM ORDERS OH (NOLOCK)  
   --WHERE OH.OrderKey = @c_Orderkey  
  
   EXEC nspGetRight   
      '',    
      @c_StorerKey,                
      '',                      
      'PrintCartonLabelByITF',   
      @b_success               OUTPUT,  
      @c_PrintCartonLabelByITF OUTPUT,  
      @n_err                   OUTPUT,  
      @c_errmsg                OUTPUT,  
      @c_Option1               OUTPUT,  
      @c_Option2               OUTPUT,  
      @c_Option3               OUTPUT  
  
  IF @c_PrintCartonLabelByITF = '1'  
  BEGIN  
     
   --For shipperkey='ninjavan' check if packinfo.trackingno . if packinfo.trackingno is null or blank trigger insert transmitlog2 else print bartender label  
   --For shipperkey <> 'ninjavan' direct print bartender label  
   --Skip insert Transmitlog2 in isp_PrintCartonLabel_Interface  
      
     
     
  IF  @c_shipperkey ='NinjaVan'   
  BEGIN                        
         --IF EXISTS (SELECT 1   
         --           FROM TRANSMITLOG2 T2 (NOLOCK)   
         --           WHERE T2.tablename = @c_Option1  
         --           AND T2.key3 = @c_Storerkey  
         --           AND T2.key1 = SUBSTRING(@c_Pickslipno,2,9)+CONVERT(NVARCHAR(5),@n_Cartonno)) AND @c_trackingno <> ''  
         --BEGIN  
         --         SET @c_key2 = ''  
         --         SELECT @c_key2 =T2.key2  
         --         FROM TRANSMITLOG2 T2 (NOLOCK)   
         --         WHERE T2.tablename = @c_Option1  
         --         AND T2.key3 = @c_Storerkey  
         --         AND T2.key1 = SUBSTRING(@c_Pickslipno,2,9)+CONVERT(NVARCHAR(5),@n_Cartonno)  
  
  
         --         UPDATE TRANSMITLOG2  
         --         SET transmitflag = '0'  
         --            ,key2 = CASE WHEN @c_key2 <> @c_userid THEN @c_userid ELSE key2 END  
         --         WHERE tablename = @c_Option1  
         --         AND key3 = @c_Storerkey  
         --         AND key1 = SUBSTRING(@c_Pickslipno,2,9)+CONVERT(NVARCHAR(5),@n_Cartonno)  
              
  
         --         SET @n_continue = 1        
         --         SET @c_errmsg = ''    
         --END     
         --  
         IF @c_trackingno <> ''  
         BEGIN  
             EXEC isp_BT_GenBartenderCommand            
                   @cPrinterID = @c_PrinterID    
                  ,@c_LabelType = 'UCCLBLSG01'    
                  ,@c_userid = @c_UserId    
                  ,@c_Parm01 = @c_Pickslipno    
                  ,@c_Parm02 = @n_Cartonno    
                  ,@c_Parm03 = @n_Cartonno    
                  ,@c_Parm04 = @c_Parm04    
                  ,@c_Parm05 = @c_Parm05    
                  ,@c_Parm06 = @c_Parm06    
                  ,@c_Parm07 = @c_Parm07    
                  ,@c_Parm08 = @c_Parm08    
                  ,@c_Parm09 = @c_Parm09    
                  ,@c_Parm10 = @c_Parm10    
                  ,@c_Storerkey = @c_Storerkey    
                  ,@c_NoCopy = '1'   
                  ,@c_Returnresult = 'N'     
                  ,@n_err = @n_Err OUTPUT    
                  ,@c_errmsg = @c_ErrMsg OUTPUT        
    
               IF @n_err <> 0    
               BEGIN    
                   SELECT @n_continue = 3      
                   GOTO QUIT_SP    
               END    
               ELSE  
               BEGIN  
                  SET @n_continue = 1        
                  SET @c_errmsg = ''    
               END  
         END  
         ELSE  
         BEGIN  
                  SELECT @b_success = 1      
                   EXECUTE nspg_getkey      
                   'TransmitlogKey2'      
                   , 10      
                   , @c_trmlogkey OUTPUT      
                   , @b_success   OUTPUT      
                   , @n_err       OUTPUT      
                   , @c_errmsg    OUTPUT      
             
                   IF @b_success <> 1      
                   BEGIN      
                     SELECT @n_continue = 3      
                   END      
                   ELSE      
                   BEGIN      
                     INSERT INTO Transmitlog2 (transmitlogkey, tablename, key1, key2, key3, transmitflag, TransmitBatch)      
                     VALUES (@c_trmlogkey, @c_Option1, SUBSTRING(@c_Pickslipno,2,9)+CONVERT(NVARCHAR(5),@n_Cartonno), @c_userid, @c_Storerkey, '0', '')      
                  END    
         END          
  END  
  ELSE    
  BEGIN    
        EXEC isp_BT_GenBartenderCommand            
          @cPrinterID = @c_PrinterID    
         ,@c_LabelType = @c_LabelType    
         ,@c_userid = @c_UserId    
         ,@c_Parm01 = @c_Pickslipno    
         ,@c_Parm02 = @n_Cartonno    
         ,@c_Parm03 = @n_Cartonno    
         ,@c_Parm04 = @c_Parm04    
         ,@c_Parm05 = @c_Parm05    
         ,@c_Parm06 = @c_Parm06    
         ,@c_Parm07 = @c_Parm07    
         ,@c_Parm08 = @c_Parm08    
         ,@c_Parm09 = @c_Parm09    
         ,@c_Parm10 = @c_Parm10    
         ,@c_Storerkey = @c_Storerkey    
         ,@c_NoCopy = '1'   
         ,@c_Returnresult = 'N'     
         ,@n_err = @n_Err OUTPUT    
         ,@c_errmsg = @c_ErrMsg OUTPUT        
    
      IF @n_err <> 0    
      BEGIN    
          SELECT @n_continue = 3      
          GOTO QUIT_SP    
      END    
      ELSE  
      BEGIN  
         SET @n_continue = 1        
         SET @c_errmsg = ''    
      END        
   END    
  
    SET @b_success = 2   
END  
QUIT_SP:  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ispCTNLBLITF04"  
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
GRANT EXECUTE ON ispCTNLBLITF04 TO NSQL
GO
