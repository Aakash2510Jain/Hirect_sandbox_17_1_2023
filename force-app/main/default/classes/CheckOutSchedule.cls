global without sharing class CheckOutSchedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        BuildMaps.makeAllMemberOOF();
        
    }
}