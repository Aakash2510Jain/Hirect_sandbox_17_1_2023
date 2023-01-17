public class LeadQueuableJob implements Queueable{
    
    Private List<lead> updatedLeadList ;
    
    public LeadQueuableJob(List<Lead> leadIdList){
        this.updatedLeadList = leadIdList;
    }
    
    public void execute(QueueableContext context) {
        if(!updatedLeadList.isEmpty()){
            try{
                system.debug('updatedLeadList for last Step'+updatedLeadList);
                update updatedLeadList;  
            }catch(exception e){
                system.debug('Exception'+ e.getMessage() +'@@@@'+e.getLineNumber());
            }
            
        }
    }
    
}