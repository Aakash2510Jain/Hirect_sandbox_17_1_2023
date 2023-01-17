global class ScheduleBatchToAssignLeadsFromAppIndia implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToAssignLeadsFromAppIndiaQueue batchInstance = new BatchToAssignLeadsFromAppIndiaQueue();
        Database.executeBatch(batchInstance);
    }
}