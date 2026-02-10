UPDATE SCE_DLWebApiConfig SET URL = '/sceapi/SCEBILL/GenericRequest/SCE_DL_Generic_GLOWMS'
WHERE OperationType = 'SCE_DL_LB_CLIENT_MASTER' AND Application = 'BILLING'