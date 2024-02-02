IF NOT EXISTS (SELECT 1 FROM Codelkup  (NOLOCK) WHERE ListName = 'StorerCfg'       --UWP-14379
               AND Code ='ASNStatusCheckByStorer')
BEGIN 
   INSERT INTO CODELKUP (LISTNAME, Code, Description)
   VALUES ( 'StorerCfg', 'ASNStatusCheckByStorer', 'Match Codelkup ''ASNStatChk'' By specific storerkey')
END

