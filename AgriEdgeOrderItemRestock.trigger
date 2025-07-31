trigger AgriEdgeOrderItemRestock on AgriEdge_OrderItem__c (after delete) {
    Map<Id, Integer> productToRestoreQty = new Map<Id, Integer>();

    for (AgriEdge_OrderItem__c item : Trigger.old) {
        if (item.Product__c != null && item.Quantity__c != null) {
            if (!productToRestoreQty.containsKey(item.Product__c)) {
                productToRestoreQty.put(item.Product__c, 0);
            }
            productToRestoreQty.put(item.Product__c, productToRestoreQty.get(item.Product__c) + item.Quantity__c.intValue());
        }
    }

    List<AgriEdge_Inventory__c> inventoriesToUpdate = [
        SELECT Id, Product__c, Stock_Quantity__c
        FROM AgriEdge_Inventory__c
        WHERE Product__c IN :productToRestoreQty.keySet()
    ];

    for (AgriEdge_Inventory__c inventory : inventoriesToUpdate) {
        Integer restoreQty = productToRestoreQty.get(inventory.Product__c);
        inventory.Stock_Quantity__c = (inventory.Stock_Quantity__c != null ? inventory.Stock_Quantity__c : 0) + restoreQty;
    }

    if (!inventoriesToUpdate.isEmpty()) {
        update inventoriesToUpdate;
    }
}