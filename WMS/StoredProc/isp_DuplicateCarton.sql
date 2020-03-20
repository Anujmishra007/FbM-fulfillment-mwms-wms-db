if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_DuplicateCarton]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_DuplicateCarton]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Stored Procedure: isp_DuplicateCarton                                */
/* Creation Date: 06-Jan-2015                                           */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: 320446 - Duplicate packing carton                           */
/*                                                                      */
/* Called By:                                                           */ 
/*                                                                      */
/* Parameters:                                                          */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author Ver.  Purposes                                   */
/* 13-MAY-2106  Wan01  1.1   Specify SP parameters                      */  
/************************************************************************/

CREATE PROC isp_DuplicateCarton
         @c_PickSlipNo       NVARCHAR(10),
         @n_FromCartonNo     INT,
         @n_ToNumberOfCarton INT = 1,
         @n_NewCartonNoFrom  INT OUTPUT,
         @n_NewCartonNoTo    INT OUTPUT,
         @b_Success          INT       OUTPUT,
         @n_err              INT       OUTPUT,
         @c_errmsg           NVARCHAR(255) OUTPUT
AS
BEGIN
   SET NOCOUNT ON   
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @n_starttcnt INT,
           @n_continue INT,
           @n_cnt INT,
           @n_NewCartonNo INT,
           @c_NewLabelNo NVARCHAR(20)
   
   SELECT @n_starttcnt=@@TRANCOUNT, @n_continue=1, @b_success=0, @n_err=0, @c_errmsg='', @n_cnt = 0, @n_NewCartonNo = 0
   
   IF EXISTS (SELECT 1
              FROM PACKHEADER (NOLOCK)
              WHERE Pickslipno = @c_Pickslipno
              AND ISNULL(PACKHEADER.Orderkey,'') <> '')  
   BEGIN
        IF EXISTS ( SELECT 1 FROM
                      (SELECT PKD.Storerkey, PKD.Sku, SUM(PD.Qty) AS PickedQty,
                              ISNULL((SELECT SUM(PACKDETAIL.Qty)   
                                       FROM PACKDETAIL(NOLOCK)   
                                       WHERE PACKDETAIL.PickSlipNo = PKH.Pickslipno   
                                       AND PACKDETAIL.Storerkey = PKD.Storerkey     
                                       AND PACKDETAIL.SKU = PKD.SKU), 0) AS PackedQty,
                               PKD.Qty AS QtyPerCarton   
                     FROM PACKHEADER PKH (NOLOCK)
                     JOIN PACKDETAIL PKD (NOLOCK) ON PKH.Pickslipno = PKD.Pickslipno
                     JOIN PICKDETAIL PD (NOLOCK) ON PKD.Storerkey = PD.Storerkey AND PKD.Sku = PD.Sku AND PKH.Orderkey = PD.Orderkey
                     WHERE PKH.Pickslipno = @c_Pickslipno
                     AND PKD.CartonNo = @n_FromCartonNo
                     GROUP BY PKH.Pickslipno, PKD.Storerkey, PKD.Sku, PKD.Qty) AS T 
                  WHERE T.PickedQty < (T.PackedQty + (T.QtyPerCarton * @n_ToNumberOfCarton)) )        
      BEGIN
         SELECT @n_continue = 3 
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=61900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Pack qty to duplicate exceeded pickded qty. (isp_DuplicateCarton)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
      END
   END
   ELSE
   BEGIN
        IF EXISTS ( SELECT 1 FROM
                       (SELECT PKD.Storerkey, PKD.Sku, SUM(PD.Qty) AS PickedQty,
                               ISNULL((SELECT SUM(PACKDETAIL.Qty)   
                                        FROM PACKDETAIL(NOLOCK)   
                                        WHERE PACKDETAIL.PickSlipNo = PKH.Pickslipno   
                                        AND PACKDETAIL.Storerkey = PKD.Storerkey     
                                        AND PACKDETAIL.SKU = PKD.SKU), 0) AS PackedQty,
                             PKD.Qty AS QtyPerCarton                             
                        FROM PACKHEADER PKH (NOLOCK)
                      JOIN PACKDETAIL PKD (NOLOCK) ON PKH.Pickslipno = PKD.Pickslipno
                      JOIN LOADPLANDETAIL LPD (NOLOCK) ON PKH.LoadKey = LPD.LoadKey
                      JOIN PICKDETAIL PD (NOLOCK) ON PKD.Storerkey = PD.Storerkey AND PKD.Sku = PD.Sku AND LPD.Orderkey = PD.Orderkey
                      WHERE PKH.Pickslipno = @c_Pickslipno
                      AND PKD.CartonNo = @n_FromCartonNo
                      GROUP BY PKH.Pickslipno, PKD.Storerkey, PKD.Sku, PKD.Qty) AS T  
                  WHERE T.PickedQty < (T.PackedQty + (T.QtyPerCarton * @n_ToNumberOfCarton)) )        
      BEGIN
         SELECT @n_continue = 3 
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=61910   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Pack qty to duplicate exceeded pickded qty. (isp_DuplicateCarton)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
      END
   END
   
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
        SELECT @n_NewCartonNo = ISNULL(MAX(Cartonno),0) + 1
        FROM PACKDETAIL (NOLOCK)
        WHERE Pickslipno = @c_Pickslipno
        
        SELECT @n_NewCartonNoFrom = @n_NewCartonNo
        
        SELECT Storerkey, LabelLine, Sku, Qty, Refno, RefNo2, DropID, UPC, ExpQty
        INTO #TMP_PACKDETAIL
        FROM PACKDETAIL (NOLOCK)
        WHERE Pickslipno = @c_Pickslipno
        AND CartonNo = @n_FromCartonNo
        
        WHILE @n_cnt < @n_ToNumberOfCarton
        BEGIN
           EXECUTE isp_GenUCCLabelNo_Std
            @cPickslipNo = @c_PickSlipNo,          --(Wan01)
            @cLabelNo    = @c_NewLabelNo  OUTPUT,  --(Wan01)
            @b_success   = @b_success     OUTPUT,  --(Wan01)
            @n_err       = @n_err         OUTPUT,  --(Wan01)
            @c_errmsg    = @c_errmsg      OUTPUT   --(Wan01)
                           
           IF @b_success <> 1
           BEGIN
              SELECT @n_continue = 3
              SELECT @c_errmsg = 'isp_GenUCCLabelNo_Std ' + RTRIM(ISNULL(@c_errmsg,''))
            GOTO EXIT_SP 
           END        
         
          INSERT INTO PACKDETAIL (Pickslipno, Cartonno, Labelno, LabelLine, Storerkey, Sku, Qty, Refno, RefNo2, DropID, UPC, ExpQty)
          SELECT Pickslipno, 
                 @n_NewCartonNo, 
                 @c_NewLabelNo, 
                 LabelLine, 
                 Storerkey, 
                 Sku, 
                 Qty, 
                 Refno, 
                 RefNo2, 
                 DropID, 
                 UPC, 
                 ExpQty
           FROM PACKDETAIL (NOLOCK)
           WHERE Pickslipno = @c_Pickslipno
           AND CartonNo = @n_FromCartonNo

         IF @@ERROR <> 0 
         BEGIN
             SELECT @n_continue = 3 
             SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=61920   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
             SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert PackDetail Failed. (isp_DuplicateCarton)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
             GOTO EXIT_SP 
         END
         
         IF EXISTS (SELECT 1 FROM PACKINFO(NOLOCK) WHERE Pickslipno = @c_Pickslipno AND Cartonno = @n_NewCartonNo)         
         BEGIN
              DELETE FROM PACKINFO WHERE Pickslipno = @c_Pickslipno AND Cartonno = @n_NewCartonNo
         END

         INSERT INTO PACKINFO (Pickslipno, Cartonno, Weight, Cube, Qty, CartonType, Refno)
         SELECT Pickslipno, 
                @n_NewCartonNo, 
                Weight, 
                Cube, 
                Qty, 
                CartonType, 
                Refno
         FROM PACKINFO (NOLOCK)
         WHERE Pickslipno = @c_Pickslipno
         AND CartonNo = @n_FromCartonNo

         IF @@ERROR <> 0 
         BEGIN
             SELECT @n_continue = 3 
             SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=61930   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
             SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert PackInfo Failed. (isp_DuplicateCarton)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
             GOTO EXIT_SP 
         END                  
          
          SELECT @n_cnt = @n_cnt + 1
          SELECT @n_NewCartonNo = @n_NewCartonNo + 1
        END
        
        SELECT @n_NewCartonNoTo = @n_NewCartonNo - 1
   END
   
   EXIT_SP:

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0     
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt 
      BEGIN
          ROLLBACK TRAN
      END
      ELSE BEGIN
          WHILE @@TRANCOUNT > @n_starttcnt 
          BEGIN
              COMMIT TRAN
          END          
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_DuplicateCarton'
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

GRANT EXECUTE ON isp_DuplicateCarton to nSQL
GO
