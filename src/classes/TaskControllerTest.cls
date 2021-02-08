/**
 * Created by Sergey on 07.02.2021.
 */

@IsTest private class TaskControllerTest {

    @TestSetup static void init() {
        Account account = new Account(Name = 'test');
        insert account;
        Contact contact = new Contact(AccountId = account.Id, LastName = 'test contact');
        insert contact;

        Opportunity opportunity = new Opportunity(Name = ' test op', AccountId = account.Id, StageName = 'test', CloseDate = Date.today());
        insert opportunity;
        Task__c task = new Task__c(Name = 'test task', Project__c = opportunity.Id, Consultant__c = contact.Id);
        insert task;

        Task__c taskWithoutTime = new Task__c(Name = 'withoutTimes', Project__c = opportunity.Id, Consultant__c = contact.Id);
        insert taskWithoutTime;

        Billing_Rule__c billingRule = new Billing_Rule__c(Non_billable__c = true, Project__c = opportunity.Id);
        insert billingRule;
        Time__c t = new Time__c(Date__c = Date.newInstance(2021, 02, 07), Time_spend__c = 2,
            Task__c = task.Id, Billing_Rule__c = billingRule.Id);
        insert t;
        Time__c todayTask = new Time__c(Date__c = Date.today(), Time_spend__c = 4,
            Task__c = task.Id, Billing_Rule__c = billingRule.Id);
        insert todayTask;


    }

    @IsTest static void shouldReturnTaskByConsultantById() {
        Test.startTest();
        List<Contact> consultants = [SELECT Id FROM Contact];
        Id consultantId = consultants.get(0).Id;
        List<JsonWrapper> jsonWrappers = TaskController.getTasksByConsultant(consultantId);
        Test.stopTest();

        System.assertEquals(jsonWrappers.size(), 1);
        System.assertEquals(jsonWrappers.get(0).Sun, 2);
    }

    @IsTest static void shouldReturnTaskByDate() {

        Test.startTest();
        List<JsonWrapper> tasks = TaskController.getTasksByDate('2021-02-07');

        Test.stopTest();
        System.assertEquals(1, tasks.size());
        System.assertEquals(2, tasks.get(0).Sun);
    }

    @IsTest static void shouldReturnTodaysTask() {

        Test.startTest();
        List<JsonWrapper> tasks = TaskController.getTasksByDate('');

        Test.stopTest();
        System.assertEquals(1, tasks.size());
        System.assertEquals(4, tasks.get(0).Sun);
    }

    @IsTest static void shouldUpdateTask() {
        Test.startTest();
        List<Task__c> tasks = [SELECT Id FROM Task__c];
        Id taskId = tasks.get(0).Id;
        JsonWrapper wrapper = new JsonWrapper();
        wrapper.Id = taskId;
        wrapper.Sun = 12;

        List<JsonWrapper> wrappers = new List<JsonWrapper>();
        wrappers.add(wrapper);
        TaskController.updateTasks(wrappers);

        List<Task__c> updatedTasks = [
            SELECT Id, (SELECT Time_spend__c FROM Task_Time__r)
            FROM Task__c
        ];
        Test.stopTest();
        Task__c updatedTask = updatedTasks.get(0);
        List<Time__c> updatedTimes = updatedTask.Task_Time__r;

        System.assertEquals(2, updatedTimes.size());
        System.assertEquals(12, updatedTimes.get(1).Time_spend__c);
    }

    @IsTest static void shouldUpdateNewTask() {
        Test.startTest();
        List<Task__c> tasks = [SELECT Id,Name FROM Task__c WHERE Name ='withoutTimes'];
        Task__c taskWithoutTime = tasks.get(0);
        JsonWrapper wrapper = new JsonWrapper();
        wrapper.Id = taskWithoutTime.Id;
        wrapper.Sun = 12;

        List<JsonWrapper> wrappers = new List<JsonWrapper>();
        wrappers.add(wrapper);
        TaskController.updateTasks(wrappers);

        List<Task__c> updatedTasks = [
            SELECT Id,Name, (SELECT Time_spend__c,Date__c FROM Task_Time__r)
            FROM Task__c
            WHERE Name ='withoutTimes'
        ];
            Test.stopTest();
        Task__c updatedTask = updatedTasks.get(0);
        List<Time__c> updatedTimes = updatedTask.Task_Time__r;

        System.assertEquals(7, updatedTimes.size());
        for (Time__c t:updatedTimes){
            if(t.Date__c == Date.today().toStartOfWeek().addDays(6)){
                System.assertEquals(12, t.Time_spend__c);
            }
        }

    }
}
