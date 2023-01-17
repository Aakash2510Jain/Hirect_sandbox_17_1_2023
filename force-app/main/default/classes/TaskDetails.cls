public with sharing class TaskDetails {
  
    public String WhoId;
    public String OwnerId;
    public Datetime callStartTime;
    public Datetime callEndTime;
    public String callDuration;
    public String callStatus;
    public String status;
    public String callType;
    public String CallSID;
    public String Phone;
    public String Subject;
    public static TaskDetails parse(String json){
        return (TaskDetails) System.JSON.deserialize(json, TaskDetails.class);
    }
}