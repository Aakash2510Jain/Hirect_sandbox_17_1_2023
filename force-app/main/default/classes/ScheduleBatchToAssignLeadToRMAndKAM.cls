global class ScheduleBatchToAssignLeadToRMAndKAM implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToAssignLeadToRMAndKAM batchInstance = new BatchToAssignLeadToRMAndKAM();
        Database.executeBatch(batchInstance);
    }
}