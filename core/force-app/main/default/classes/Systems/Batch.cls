/**
* Dml process as a Batchable
*/
global virtual class Batch implements Database.Batchable<SObject> {
    //#region Actions

    /**
    * Action
    */
    global abstract class Action {
        global String mergex;
        global abstract void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions);
        global Action mergex(String mergex) { this.mergex = mergex; return this; }
    }

    /**
    * Insert
    */
    global virtual class Insertx extends Action {
        global Type record;
        global Map<String, Object> values;

        /**
        * a database insert action
        * @param record the inserted record type
        * @param values the inserted values
        */
        global Insertx(Type record, Map<String, Object> values) { this.record = record; this.values = values; }
        global override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) {
            LimitsX.asyncApex(0, true);
            List<SObject> scope2 = new List<SObject>();
            for (SObject s : scope) { SObject obj = (SObject)record.newInstance(); for (String field : values.keySet()) SObjectX.put(obj, field, ObjectX.mergex(s, values.get(field))); scope2.add(obj); }
            if (!scope2.isEmpty()) Database.insert(scope2, allOrNone);
        }
    }

    /**
    * Update
    */
    global virtual class Updatex extends Action {
        global Map<String, Object> values;

        /**
        * a database update action
        * @param values the updated values
        */
        global Updatex(Map<String, Object> values) { this.values = values; }
        global override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) {
            LimitsX.asyncApex(0, true);
            for (SObject s : scope) for (String field : values.keySet()) SObjectX.put(s, field, ObjectX.mergex(s, values.get(field)));
            if (!scope.isEmpty()) DatabaseX.updatex(mergex, scope, allOrNone);
        }
    }

    /**
    * Delete
    */
    global virtual class Deletex extends Action {
        /**
        * a database delete action
        */
        global Deletex() { }
        global override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) {
            LimitsX.asyncApex(0, true);
            Set<Id> scope2 = new Set<Id>();
            for (SObject s : scope) scope2.add(s.Id);
            if (!scope2.isEmpty()) Database.delete(new List<Id>(scope2), allOrNone);
        }
    }

    /**
    * Flow
    */
    global virtual class Flow extends Action {
        global String flowField;
        global Map<String, Object> values;

        /**
        * a database flow action
        * @param flowField the flow field
        */
        global Flow(String flowField) { this(flowField, null); }
        /**
        * a database flow and upate action
        * @param flowField the flow field
        * @param values the updated values
        */
        global Flow(String flowField, Map<String, Object> values) { this.flowField = flowField; this.values = values; }
        global override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) {
            LimitsX.asyncApex(0, true);
            List<SObject> scope2 = new List<SObject>();
            String[] flowFields = flowField.split('\\.', 2);
            if (flowFields.size() != 2) throw new HandledException('Invalid flowField format');
            for (SObject s : scope) {
                try { Flow.Interview.createInterview(flowFields[0], new Map<String, Object> { flowFields[1] => s.Id }).start(); }
                catch (Exception e) { SystemX.debug(e); exceptions.add(new ExObj(e, s)); }
                if (values != null) { for (String field : values.keySet()) SObjectX.put(s, field, ObjectX.mergex(s, values.get(field))); scope2.add(s); }
            }
            if (values != null && !scope2.isEmpty()) DatabaseX.updatex(mergex, scope2, allOrNone);
        }
    }

    /**
    * Insert Relative
    */
    global virtual class InsertRel extends Action {
        global Type record;
        global String recordIdField;
        global Map<String, Object> values;

        /**
        * a database related insert action
        * @param record the inserted record type
        * @param recordIdField the related recordId field
        * @param values the inserted values
        */
        global InsertRel(Type record, String recordIdField, Map<String, Object> values) { this.record = record; this.recordIdField = recordIdField; this.values = values; }
        global override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) {
            LimitsX.asyncApex(0, true);
            List<SObject> scope2 = new List<SObject>();
            for (SObject s : scope) {
                Id id = (Id)SObjectX.get(s, recordIdField);
                if (id == null) { SystemX.debug('warning, skipping relative field for record: ' + s.Id); continue; }
                SObject obj = (SObject)record.newInstance(); for (String field : values.keySet()) SObjectX.put(obj, field, ObjectX.mergex(s, values.get(field))); scope2.add(obj);
            }
            if (!scope2.isEmpty()) Database.insert(scope2, allOrNone);
        }
    }

    /**
    * Update Relative
    */
    global virtual class UpdateRel extends Action {
        global Type record;
        global String recordIdField;
        global Map<String, Object> values;

        /**
        * a database related update action
        * @param record the updated record type
        * @param recordIdField the related recordId field
        * @param values the updated values
        */
        global UpdateRel(Type record, String recordIdField, Map<String, Object> values) { this.record = record; this.recordIdField = recordIdField; this.values = values; }
        global override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) {
            LimitsX.asyncApex(0, true);
            List<SObject> scope2 = new List<SObject>();
            for (SObject s : scope) {
                Id id = (Id)SObjectX.get(s, recordIdField);
                if (id == null) { SystemX.debug('warning, skipping relative field for record: ' + s.Id); continue; }
                SObject obj = (SObject)record.newInstance(); obj.Id = id; for (String field : values.keySet()) SObjectX.put(obj, field, ObjectX.mergex(s, values.get(field))); scope2.add(obj);
            }
            if (!scope2.isEmpty()) DatabaseX.updatex(mergex, scope2, allOrNone);
        }
    }

    /**
    * Delete Relative
    */
    global virtual class DeleteRel extends Action {
        global Type record;
        global String recordIdField;

        /**
        * a database related delete action
        * @param record the deleted record type
        * @param recordIdField the related recordId field
        */
        global DeleteRel(Type record, String recordIdField) { this.record = record; this.recordIdField = recordIdField; }
        global override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) {
            LimitsX.asyncApex(0, true);
            Set<Id> scope2 = new Set<Id>();
            for (SObject s : scope) {
                Id id = (Id)SObjectX.get(s, recordIdField);
                if (id == null) { SystemX.debug('warning, skipping relative field for record: ' + s.Id); continue; }
                scope2.add(id);
            }
            if (!scope2.isEmpty()) Database.delete(new List<Id>(scope2), allOrNone);
        }
    }

    /**
    * Flow Relative
    */
    global virtual class FlowRel extends Action {
        global Type record;
        global String recordIdField;
        global String flowField;
        global Map<String, Object> values;

        /**
        * a database related flow action
        * @param record the flow record type
        * @param recordIdField the related recordId field
        * @param flowField the flow field
        */
        global FlowRel(Type record, String recordIdField, String flowField) { this(record, recordIdField, flowField, null); }
        /**
        * a database related flow and update action
        * @param record the flow record type
        * @param recordIdField the related recordId field
        * @param flowField the flow field
        * @param values the updated values
        */
        global FlowRel(Type record, String recordIdField, String flowField, Map<String, Object> values) { this.record = record; this.recordIdField = recordIdField; this.flowField = flowField; this.values = values; }
        global override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) {
            LimitsX.asyncApex(0, true);
            List<SObject> scope2 = new List<SObject>();
            String[] flowFields = flowField.split('\\.', 2);
            if (flowFields.size() != 2) throw new HandledException('Invalid flowField format');
            for (SObject s : scope) {
                Id id = (Id)SObjectX.get(s, recordIdField);
                if (id == null) { SystemX.debug('warning, skipping relative field for record: ' + s.Id); continue; }
                try { Flow.Interview.createInterview(flowFields[0], new Map<String, Object> { flowFields[1] => id }).start(); }
                catch (Exception e) { SystemX.debug(e); exceptions.add(new ExObj(e, s)); }
                SObject obj = (SObject)record.newInstance();
                obj.Id = id;
                if (values != null) {
                    for (String field : values.keySet()) SObjectX.put(obj, field, ObjectX.mergex(s, values.get(field)));
                    scope2.add(obj);
                }
            }
            if (values != null && !scope2.isEmpty()) DatabaseX.updatex(mergex, scope2, allOrNone);
        }
    }

    //#endregion

    //#region Runners

    global String query;
    global Action action;
    global Integer batchSize;
    global Boolean allOrNone = true;
    global final List<ExObj> exceptions = new List<ExObj>();

    /**
    * a batchable implementation
    * @param query the query
    * @param action the action
    */
    global Batch(String query, Action action) { this.query = query; this.action = action; this.batchSize = action instanceOf Flow || action instanceOf FlowRel ? 10 : 1000; SystemX.debug('Batch:' + this); }
    /**
    * a batchable implementation
    * @param query the query
    * @param action the action
    * @param batchSize the batch size
    */
    global Batch(String query, Action action, Integer batchSize) { this(query, action); this.batchSize = batchSize; }
    /**
    * a batchable implementation
    * @param query the query
    * @param action the action
    * @param allOrNone specifies if all or nothing
    */
    global Batch(String query, Action action, Boolean allOrNone) { this(query, action); this.allOrNone = allOrNone; }
    /**
    * a batchable implementation
    * @param query the query
    * @param action the action
    * @param batchSize the batch size
    * @param allOrNone specifies if all or nothing
    */
    global Batch(String query, Action action, Integer batchSize, Boolean allOrNone) { this(query, action); this.batchSize = batchSize; this.allOrNone = allOrNone; }

    /**
    * run
    * @return String 
    */
    global String run() { return Database.executeBatch(this, batchSize); }

    /**
    * batchable start
    * @param bc the batchable context
    * @return Database.QueryLocator 
    */
    global Database.QueryLocator start(Database.BatchableContext bc) { return Database.getQueryLocator(query); }

    /**
    * batchable execute
    * @param bc the batchable context
    * @param scope the scope
    */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        action?.execute(bc, scope, allOrNone, exceptions);
        if (!exceptions.isEmpty()) handle(exceptions);
    }

    /**
    * batchable finish
    * @param bc the batchable context
    */
    global void finish(Database.BatchableContext bc) { }

    /**
    * handle exceptions
    * @param scope the scope
    */
    global protected virtual void handle(List<ExObj> scope) { }

    /**
    * Schedule process as a Schedulable
    */
    global virtual class Schedule implements Schedulable {
        global String query;
        global Action action;
        global Integer batchSize;
        global Boolean allOrNone = true;
        global final List<ExObj> exceptions = new List<ExObj>();

        /**
        * a schedulable implementation
        * @param query the query
        * @param action the action
        */
        global Schedule(String query, Action action) { this.query = query; this.action = action; this.batchSize = action instanceOf Flow || action instanceOf FlowRel ? 10 : 1000; SystemX.debug('Batch:' + this); }
        /**
        * a schedulable implementation
        * @param query the query
        * @param action the action
        * @param batchSize the batch size
        */
        global Schedule(String query, Action action, Integer batchSize) { this(query, action); this.batchSize = batchSize; }
        /**
        * a schedulable implementation
        * @param query the query
        * @param action the action
        * @param allOrNone specifies if all or nothing
        */
        global Schedule(String query, Action action, Boolean allOrNone) { this(query, action); this.allOrNone = allOrNone; }
        /**
        * a schedulable implementation
        * @param query the query
        * @param action the action
        * @param batchSize the batch size
        * @param allOrNone specifies if all or nothing
        */
        global Schedule(String query, Action action, Integer batchSize, Boolean allOrNone) { this(query, action); this.batchSize = batchSize; this.allOrNone = allOrNone; }

        /**
        * run
        * @return String 
        */
        global String run() { execute(null); return 'Inline'; }

        /**
        * execute
        * @param sc the schedulable context
        */
        global void execute(SchedulableContext sc) {
            Database.QueryLocatorIterator it = Database.getQueryLocator(query).iterator();
            List<SObject> scope = new List<SObject>();
            while (it.hasNext()) scope.add(it.next());
            action?.execute(sc, scope, allOrNone, exceptions);
            if (!exceptions.isEmpty()) handle(exceptions);
        }

        /**
        * handle exceptions
        * @param scope the scope
        */
        global protected virtual void handle(List<ExObj> scope) { }
    }

    /**
    * Queue process as a Queueable
    */
    global virtual class Queue implements Queueable {
        global String query;
        global Action action;
        global Integer batchSize;
        global Boolean allOrNone = true;
        global final List<ExObj> exceptions = new List<ExObj>();

        /**
        * a queueable implementation
        * @param query the query
        * @param action the action
        */
        global Queue(String query, Action action) { this.query = query; this.action = action; this.batchSize = action instanceOf Flow || action instanceOf FlowRel ? 10 : 1000; SystemX.debug('Batch:' + this); }
        /**
        * a queueable implementation
        * @param query the query
        * @param action the action
        * @param batchSize the batch size
        */
        global Queue(String query, Action action, Integer batchSize) { this(query, action); this.batchSize = batchSize; }
        /**
        * a queueable implementation
        * @param query the query
        * @param action the action
        * @param allOrNone specifies if all or nothing
        */
        global Queue(String query, Action action, Boolean allOrNone) { this(query, action); this.allOrNone = allOrNone; }
        /**
        * a queueable implementation
        * @param query the query
        * @param action the action
        * @param batchSize the batch size
        * @param allOrNone specifies if all or nothing
        */
        global Queue(String query, Action action, Integer batchSize, Boolean allOrNone) { this(query, action); this.batchSize = batchSize; this.allOrNone = allOrNone; }

        /**
        * run
        * @return String 
        */
        global String run() { return System.enqueueJob(this); }

        /**
        * execute
        * @param qc the queueable context
        */
        global void execute(QueueableContext qc) {
            Database.QueryLocatorIterator it = Database.getQueryLocator(query).iterator();
            List<SObject> scope = new List<SObject>();
            while (it.hasNext()) scope.add(it.next());
            action?.execute(qc, scope, this.allOrNone, exceptions);
            if (!exceptions.isEmpty()) handle(exceptions);
        }

        /**
        * handle
        * @param scope the scope
        */
        global protected virtual void handle(List<ExObj> scope) { }
    }

    //#endregion
 }