public with sharing class FL_LocalFlosumConstants 
{
    // Metatdata API version
    public static final Integer apiversion = 36; 
    
    public static final String NO_TEST_RUN = 'NoTestRun';
    public static final String RUN_LOCAL_TEST = 'RunLocalTests';
    public static final String RUN_ALL_TEST_IN_ORG = 'RunAllTestsInOrg';
    public static final String RUN_SPECIFIC_TEST = 'RunSpecifiedTests';
    public static final String NO_SPECIFIC_TEST = 'NoSpecificTests';
    
    public static final String GOVT_ORG_PICK_VAL = 'Government cloud org';
    
    public static final String REGISTER_BRANCH_MESSAGE = 'Please Register a Branch first on settings tab.';
    public static final String REGISTER_FLOSUM_ORG_MESSAGE = 'Please register Flosum org first on settings tab.';
    
    public static final Map<String,String> runTestParamPatchMap = new Map<String,String>{NO_TEST_RUN => 'Do not run any tests',
                                                                                    RUN_LOCAL_TEST => 'Run local tests, ignore test from managed packages',
                                                                                    RUN_ALL_TEST_IN_ORG => 'Run all tests',
                                                                                    RUN_SPECIFIC_TEST => 'Run Specified test'
                                                                                    };
    public static final String SAFE_TO_COMMIT = 'Safe To Commit';
    public static final String NOT_TO_COMMIT = 'Not To Commit';
    
    public static final String SYNC_TYPE_UPLOAD = 'Upload';
    public static final String SYNC_TYPE_DOWNLOAD = 'Download';
    
    public static final String FLOSUM_ORG_NAMESPACE = '';
}