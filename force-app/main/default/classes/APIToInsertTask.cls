@RestResource(urlMapping='/APIToInsertTask/*')
global class APIToInsertTask {
    @httpPost
    global static responseWrapper TaskCreate(){
        
        responseWrapper responseJSON = new responseWrapper();
        try{
            System.debug('taskList--> '+RestContext.request.requestBody.toString());
            TaskDetails taskdata = TaskDetails.parse(RestContext.request.requestBody.toString());
            if(taskdata != null){
                Task tk = new Task();
                if(taskdata.WhoId != null){
                    tk.WhoId = String.valueOf(taskdata.WhoId);
                }
                if(taskdata.callDuration != null){
                    tk.CallDurationInSeconds = Integer.valueOf(taskdata.callDuration);
                }
                if(taskdata.callEndTime != null){
                    tk.callEndTime__c = (Datetime.valueOf(taskdata.callEndTime)).addMinutes(-330);
                    system.debug('tk.callEndTime__c-->'+tk.callEndTime__c);
                }
                if(taskdata.callStartTime != null){
                    tk.CallStartTime__c = (Datetime.valueOf(taskdata.callEndTime)).addMinutes(-330);
                    system.debug('tk.CallStartTime__c-->'+tk.CallStartTime__c);
                }
                if(taskdata.callType != null){
                    tk.CallType = String.valueOf(taskdata.callType);
                }
                if(taskdata.CallSID != null){
                    tk.CallSID__c = String.valueOf(taskdata.CallSID);
                }
                if(taskdata.callStatus != null){
                    tk.Call_Status__c = String.valueOf(taskdata.callStatus);
                }
                 if(taskdata.status != null){
                    tk.Status = String.valueOf(taskdata.status);
                }
                if(taskdata.Phone != null){
                    tk.Phone__c = String.valueOf(taskdata.Phone);
                }
                if(taskdata.Subject != null){
                    tk.Subject = String.valueOf(taskdata.Subject);
                }
                insert tk;
                responseJSON.Message = 'Task Created Successfully';
                responseJSON.taskId =tk.id;
            } else {
                responseJSON.Message = 'Task Creation Failed';
                
            }
        }catch(Exception e){
            System.debug('Error is occured '+e.getMessage());
            responseJSON.Message= e.getMessage();
        }
        return responseJSON;
    }
    global class responseWrapper {
        global String Message;
        global string taskId;
       
        
    }
}

/* Request Body
 {
"WhoId": "00Q0w0000057VobEAE",
"OwnerId": "0050w000003hD3tAAE",
"callStartTime": "2021-05-14T20:22:46.988+05:30",
"callEndTime": "2021-05-14T20:22:46.988+05:30",
"callDuration": "234",
"callStatus": "closed",
"CallSID": "RAVI623409",
"Subject": "Call",
"Phone": "7567676787"
}
 */