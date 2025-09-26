/**
* Account trigger should do the following:
* 1. Set the account type to prospect.
* 2. Copy the shipping address to the billing address.
* 3. Set the account rating to hot.
* 4. Create a contact for each account inserted.
*/

trigger AccountTrigger on Account (before insert, after insert) {

    if ( Trigger.isBefore && Trigger.isInsert){
        AccountTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    
    if ( Trigger.isAfter && Trigger.isInsert){
            AccountTriggerHandler.handleAfterInsert(Trigger.new);
    }
}