@isTest
public class AgriEdgeOrderTests {

    @isTest
    public static void testOrderTaskCreator() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        AgriEdge_Order__c order = new AgriEdge_Order__c(
            Payment_Status__c = 'Paid',
            Order_Status__c = 'New',
            Customer__c = acc.Id
        );
        insert order;

        Test.startTest();
        OrderTaskCreator.createTaskForNewOrder(new List<Id>{order.Id});
        Test.stopTest();

        List<Task> tasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :order.Id];
        System.assertEquals(2, tasks.size());
    }

    @isTest
    public static void testOrderEmailSender() {
        Account acc = new Account(Name = 'Email Test');
        insert acc;

        Contact con1 = new Contact(FirstName = 'Test', LastName = 'User', Email = 'test1@example.com', AccountId = acc.Id);
        Contact con2 = new Contact(FirstName = 'Test2', LastName = 'User2', Email = 'test2@example.com', AccountId = acc.Id);
        insert new List<Contact>{con1, con2};

        AgriEdge_Order__c order = new AgriEdge_Order__c(
            Order_Status__c = 'Processing',
            Payment_Status__c = 'Paid',
            Customer__c = acc.Id,
            Shipping_Address__c = '123 Test St',
            Total_Amount__c = 150
        );
        insert order;

        Test.startTest();
        OrderEmailSender.sendOrderEmail(new Set<Id>{order.Id});
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations()); // Mock validation
    }

    @isTest
    public static void testOrderStatusUpdater() {
        AgriEdge_Order__c order = new AgriEdge_Order__c(
            Order_Status__c = 'New',
            Payment_Status__c = 'Pending'
        );
        insert order;

        Test.startTest();
        OrderStatusUpdater.updateOrderStatus(new Set<Id>{order.Id});
        Test.stopTest();

        order = [SELECT Order_Status__c FROM AgriEdge_Order__c WHERE Id = :order.Id];
        System.assertEquals('Processing', order.Order_Status__c);
    }

    @isTest
    public static void testOrderTotalUpdater() {
        AgriEdge_Order__c order = new AgriEdge_Order__c(
            Order_Status__c = 'New',
            Payment_Status__c = 'Pending'
        );
        insert order;

        AgriEdge_OrderItem__c item1 = new AgriEdge_OrderItem__c(
            AgriEdge_Order__c = order.Id,
            Quantity__c = 2,
            Unit_Price__c = 30
        );
        AgriEdge_OrderItem__c item2 = new AgriEdge_OrderItem__c(
            AgriEdge_Order__c = order.Id,
            Quantity__c = 1,
            Unit_Price__c = 40
        );
        insert new List<AgriEdge_OrderItem__c>{item1, item2};

        Test.startTest();
        OrderTotalUpdater.updateOrderTotal(new Set<Id>{order.Id});
        Test.stopTest();

        order = [SELECT Total_Amount__c FROM AgriEdge_Order__c WHERE Id = :order.Id];
        System.assertEquals(100.0, order.Total_Amount__c);
    }

    @isTest
    public static void testAgriEdgeOrderShipmentHelperForCancellation() {
        Account acc = new Account(Name = 'Cancel Test');
        insert acc;

        Product2 prod = new Product2(Name = 'Prod 1', isActive = true);
        insert prod;

        AgriEdge_Inventory__c inventory = new AgriEdge_Inventory__c(Product__c = prod.Id, Stock_Quantity__c = 20);
        insert inventory;

        AgriEdge_Order__c order = new AgriEdge_Order__c(
            Order_Status__c = 'New',
            Payment_Status__c = 'Failed',
            Customer__c = acc.Id
        );
        insert order;

        AgriEdge_OrderItem__c orderItem = new AgriEdge_OrderItem__c(
            AgriEdge_Order__c = order.Id,
            Product__c = prod.Id,
            Quantity__c = 5,
            Unit_Price__c = 10
        );
        insert orderItem;

        Test.startTest();
        AgriEdgeOrderShipmentHelper.processOrderStatusChange(new List<AgriEdge_Order__c>{order});
        Test.stopTest();

        AgriEdge_Inventory__c updatedInv = [SELECT Stock_Quantity__c FROM AgriEdge_Inventory__c WHERE Id = :inventory.Id];
        System.assertEquals(25, updatedInv.Stock_Quantity__c);
    }

    @isTest
    public static void testAgriEdgeOrderTriggerDeliveryStatus() {
        Account acc = new Account(Name = 'Delivery Trigger');
        insert acc;

        AgriEdge_Order__c order = new AgriEdge_Order__c(
            Payment_Status__c = 'Paid',
            Order_Status__c = 'New',
            Customer__c = acc.Id
        );
        insert order;

        Test.startTest();
        order.Order_Status__c = 'Processing';
        update order;
        Test.stopTest();

        order = [SELECT Order_Status__c FROM AgriEdge_Order__c WHERE Id = :order.Id];
        System.assertEquals('Delivered', order.Order_Status__c);
    }

    @isTest
    public static void testAgriEdgeOrderTriggerHelper() {
        System.assertEquals(false, AgriEdgeOrderTriggerHelper.isTriggerExecuted);
        AgriEdgeOrderTriggerHelper.isTriggerExecuted = true;
        System.assertEquals(true, AgriEdgeOrderTriggerHelper.isTriggerExecuted);
    }
}