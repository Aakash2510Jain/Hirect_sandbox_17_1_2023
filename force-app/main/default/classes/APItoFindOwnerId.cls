/**
 * @author Dinesh
 * @create date 2022-06-01 19:40:38
 * @modify date 2022-06-01 19:40:38
 */
@RestResource(urlMapping='/findLeadOwnerId/*')
global class APItoFindOwnerId {
      
    @HttpPost
    global Static responseWrapper findOwnerId(){
        responseWrapper responseJSON = new responseWrapper();
        
        try{
            System.debug('LeadList : '+RestContext.request.requestBody.toString());
            LeadDetails_client leadRec = LeadDetails_client.parse(RestContext.request.requestBody.tostring());
            System.debug('leadRec :'+leadRec.Phone);
            List<Lead> leadList = new List<Lead>();
            if(!String.isBlank(leadRec.Phone)){
                leadList = [SELECT Id, OwnerId,Phone, Email,Owner.Email,owner.UserName FROM Lead WHERE Phone =: leadRec.phone limit 1];
                System.debug('leadList---> '+leadList);
                if(!leadList.isEmpty()){
                    for(Lead Ld : leadList){
                        responseJSON.Message = 'Lead Found';
                        responseJSON.OwnerId = Ld.OwnerId;
                        responseJSON.Email = Ld.owner.UserName;
                        responseJSON.LeadId = Ld.Id;
                        responseJSON.success = true;
                    }
                }else{
                    responseJSON.Message = 'New Lead Created';
                    Lead leadRecInstance = new Lead(lastname='--',Company='--',Phone=leadRec.phone);
                    insert leadRecInstance;
                    responseJSON.OwnerId = UserInfo.getUserId();
                    responseJSON.Email = UserInfo.getUserName();
                    responseJSON.LeadId = leadRecInstance.Id;
                    responseJSON.success = true;
                    //responseJSON.success = false;
                }
                
            } else{
                responseJSON.Message = 'Please Provide Mobile No.';
                responseJSON.success = false;
            }
        }catch(Exception e){
            System.debug('The Error Message is : '+e.getMessage());
        }
        return responseJSON;
    }
    global class responseWrapper{
        global String Message;
        global String OwnerId;
        global String Email;
        global String Leadid;
        global boolean success;
    }
}

/* @@@ Request Body
{
"Phone": "982126511"
}

*/