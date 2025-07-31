trigger AgriEdgeOrderItemStockValidator on AgriEdge_OrderItem__c (before insert, before update) {
    Set<Id> productIds = new Set<Id>();

    for (AgriEdge_OrderItem__c item : Trigger.new) {
        if (item.Product__c != null) {
            productIds.add(item.Product__c);
        }
    }

    // Query AgriEdge_Inventory__c to get stock quantities for each product
    Map<Id, AgriEdge_Inventory__c> productToInventory = new Map<Id, AgriEdge_Inventory__c>();
    for (AgriEdge_Inventory__c inv : [
        SELECT Id, Product__c, Stock_Quantity__c
        FROM AgriEdge_Inventory__c
        WHERE Product__c IN :productIds
    ]) {
        productToInventory.put(inv.Product__c, inv);
    }

    // Validate each order item against stock availability
    for (AgriEdge_OrderItem__c item : Trigger.new) {
        if (item.Product__c != null && item.Quantity__c != null) {
            AgriEdge_Inventory__c inventory = productToInventory.get(item.Product__c);

            if (inventory != null) {
                Integer available = inventory.Stock_Quantity__c != null ? inventory.Stock_Quantity__c.intValue() : 0;
                Integer requested = item.Quantity__c.intValue();

                if (requested > available) {
                    item.addError('Only ' + available + ' units available in stock for this product. Please reduce quantity.');
                }
            } else {
                item.addError('Inventory record not found for the selected product.');
            }
        }
    }
}
