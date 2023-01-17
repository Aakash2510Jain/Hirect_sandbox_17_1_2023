global class ScheduleBatchToAssignLeadsToManager implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToAssignLeadsToSalesManager batchInstance = new BatchToAssignLeadsToSalesManager();
        Database.executeBatch(batchInstance);
    }
}