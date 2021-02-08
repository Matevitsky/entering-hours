/**
 * Created by Sergey on 30.01.2021.
 */


public class TaskController {
    @AuraEnabled(Cacheable=true)
    public static List<JsonWrapper> getTasksByConsultant(Id consultantId) {
        System.debug('task for Consultant ' + consultantId);

        List<Task__c> times = [

            SELECT Id,
                Name,
                Project__r.Name,
                Billing_Rule__r.Non_billable__c, (
                SELECT Time_spend__c, Date__c
                FROM Task_Time__r
            )
            FROM Task__c
            WHERE Consultant__c = :consultantId
        ];

        return JsonWrapper.mapToJson(times);
    }

    @AuraEnabled(Cacheable=true)
    public static List<JsonWrapper> getTasksByDate(String taskDate) {

        Date weekDate;

        if (taskDate == '') {
            weekDate = Date.today();
        } else {
            weekDate = Date.valueOf(taskDate);
        }

        Date startOfWeekDate = weekDate.toStartOfWeek();
        Date endOfWeekDate = startOfWeekDate.addDays(7);

        List<Task__c> tasks = getAllTasks();
        List<Task__c> tasksByDate = getTasksByDate(tasks, startOfWeekDate, endOfWeekDate);

        return JsonWrapper.mapToJson(tasksByDate);

    }

    @AuraEnabled
    public static String updateTasks(List<JsonWrapper> data) {

        validateWrappers(data);

        List<Task__c> tasksForUpdate = getTasksForUpdate(data);

        System.debug('Tasks to update '+tasksForUpdate);

        Map<Task__c, JsonWrapper> taskMap = mapTasksToWrappers(data, tasksForUpdate);

        try {
            List<Time__c> times = new List<Time__c>();
            for (Task__c task : taskMap.keySet()) {
                List<Time__c> t = task.Task_Time__r;
                if (t.isEmpty()) {
                    t = TimeService.createWeekTimes(task);
                }

                TimeService.updateTime(t, taskMap.get(task));
                times.addAll(t);

            }
            System.debug('Times for update '+times);
            upsert times;
            return 'Success: Account(s) updated successfully';
        } catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    private static  void validateWrappers(List<JsonWrapper> wrappers){
        for(JsonWrapper wrapper:wrappers){
            if(wrapper.Mon < 1 || wrapper.Mon > 12){
                throw new ValidateException('Time should be between 1 and 12');
            }
            if(wrapper.Thu < 1 || wrapper.Thu > 12){
                throw new ValidateException('Time should be between 1 and 12');
            }
            if(wrapper.Wed < 1 || wrapper.Wed > 12){
                throw new ValidateException('Time should be between 1 and 12');
            }
            if(wrapper.Tue < 1 || wrapper.Thu > 12){
                throw new ValidateException('Time should be between 1 and 12');
            }
            if(wrapper.Fri < 1 || wrapper.Fri > 12){
                throw new ValidateException('Time should be between 1 and 12');
            }
            if(wrapper.Sat < 1 || wrapper.Sat > 12){
                throw new ValidateException('Time should be between 1 and 12');
            }
            if(wrapper.Sun < 1 || wrapper.Sun > 12){
                throw new ValidateException('Time should be between 1 and 12');
            }
        }
    }

    private static Map<Task__c, JsonWrapper> mapTasksToWrappers(List<JsonWrapper> records, List<Task__c> tasksForUpdate) {
        Map<Task__c, JsonWrapper> taskMap = new Map<Task__c, JsonWrapper>();
        for (JsonWrapper wrapper : records) {
            for (Task__c task : tasksForUpdate) {
                if (task.Id == wrapper.Id) {
                    taskMap.put(task, wrapper);
                }
            }
        }
        System.debug('Map size'+taskMap.size());
        return taskMap;
    }

    private static List<Task__c> getTasksForUpdate(List<JsonWrapper> records) {

        List<Id> taskIds = new List<Id>();
        for (JsonWrapper wrapper : records) {
            taskIds.add(wrapper.Id);
        }

        List<Task__c> tasks = [
            SELECT Id,
                Name,
                Project__r.Name,
                Billing_Rule__r.Non_billable__c, (
                SELECT Time_spend__c, Date__c
                FROM Task_Time__r
            )
            FROM Task__c
            WHERE Id IN :taskIds
        ];

        return tasks;
    }



    private static List<Task__c> getTasksByDate(List<Task__c> tasks, Date startOfWeekDate, Date endOfWeekDate) {
        List<Task__c> tasksByDate = new List<Task__c>();
        for (Task__c task : tasks) {
            List<Time__c> times = task.Task_Time__r;
            for (Time__c t : times) {
                if (t.Date__c >= startOfWeekDate && t.Date__c <= endOfWeekDate) {
                    tasksByDate.add(task);
                    break;
                }
            }
        }
        return tasksByDate;
    }

    private static List<Task__c> getAllTasks() {
        List<Task__c> tasks = [
            SELECT Id,
                Name,
                Project__r.Name,
                Billing_Rule__r.Non_billable__c, (
                SELECT Time_spend__c, Date__c
                FROM Task_Time__r
            )
            FROM Task__c
        ];
        return tasks;
    }

}





