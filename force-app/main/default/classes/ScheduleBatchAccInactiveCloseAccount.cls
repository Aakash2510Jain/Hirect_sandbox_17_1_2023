global class ScheduleBatchAccInactiveCloseAccount implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchAccountInactiveCloseAccount batchInstance = new BatchAccountInactiveCloseAccount();
        Database.executeBatch(batchInstance);
    }
}