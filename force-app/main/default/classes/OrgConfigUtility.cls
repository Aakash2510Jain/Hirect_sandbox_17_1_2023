/*
 * Class Description :
 * Author Name :
 * Date :
 * Last Modified By:
 * Last Modified Date :
 * */
public class OrgConfigUtility {

    public static Org_Config__c orgConfig;
    
    static{
        orgConfig = Org_Config__c.getValues('Base Values');
    }
}