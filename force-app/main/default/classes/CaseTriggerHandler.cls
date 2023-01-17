public class CaseTriggerHandler {
    
    public static void CaseAgeTime(map<Id, case> CaseOldMap, map<id, Case> CaseNewMap){
        system.debug('new map ====>  '+ CaseNewMap);
        system.debug('CaseOldMap ====>  '+ CaseOldMap);
        if(!CaseNewMap.isEmpty()){
            for(case Cas : CaseNewMap.values()){
                if(Cas.Status != null && cas.Status != CaseOldMap.get(cas.Id).Status && cas.Status == 'Closed'){
                    system.debug('CaseOldMap ====>  '+ (cas.CreatedDate).millisecond());
                    system.debug('CaseOldMap ====>  '+ system.now().millisecond());
                    cas.Age_of_Case__c = (system.now().millisecond() -(cas.CreatedDate).millisecond())/(60);
                }
            }
        }
        
    }

}