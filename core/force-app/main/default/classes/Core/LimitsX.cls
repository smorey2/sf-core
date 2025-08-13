/**
* Limits method extensions
*/
global class LimitsX {
    global static Integer AsyncApexBuffer = 100000;

    /**
    * asyncApex
    * @param count the count
    * @param throwOnError the throwOnError
    * @return Boolean
    */
    global static Boolean asyncApex(Integer count, Boolean throwOnError) {
        OrgLimit l = OrgLimits.getMap().get('DailyAsyncApexExecutions');
        Boolean asyncAllowed = l.getValue() + AsyncApexBuffer + count < l.getLimit();
        // System.debug('Usage Value: ' + l.getValue() + '/' + l.getLimit());
        if (!asyncAllowed && throwOnError) throw new LimitException('DailyAsyncApexExecutions limit reached');
        return asyncAllowed;
    }

    /**
    * gets the limits
    * @param names the names
    * @return Map<String, String>
    */
    global static Map<String, Integer> get(List<String> names) {
        if (names == null) return null;
        Map<String, Integer> r = new Map<String, Integer>();
        for (String s : names)
            switch on s {
                when 'aggregateQueries' { r.put(s, Limits.getLimitAggregateQueries() - Limits.getAggregateQueries()); }
                when 'asyncCalls' { r.put(s, Limits.getLimitAsyncCalls() - Limits.getAsyncCalls()); }
                when 'callouts' { r.put(s, Limits.getLimitCallouts() - Limits.getCallouts()); }
                when 'cpuTime' { r.put(s, Limits.getLimitCpuTime() - Limits.getCpuTime()); }
                when 'dmlRows' { r.put(s, Limits.getLimitDMLRows() - Limits.getDMLRows()); }
                when 'dmlStatements' { r.put(s, Limits.getLimitDMLStatements() - Limits.getDMLStatements()); }
                when 'emailInvocations' { r.put(s, Limits.getLimitEmailInvocations() - Limits.getEmailInvocations()); }
                when 'heapSize' { r.put(s, Limits.getLimitHeapSize() - Limits.getHeapSize()); }
                when 'mobilePushApexCalls' { r.put(s, Limits.getLimitMobilePushApexCalls() - Limits.getMobilePushApexCalls()); }
                when 'publishImmediateDML' { r.put(s, Limits.getLimitPublishImmediateDML() - Limits.getPublishImmediateDML()); }
                when 'queries' { r.put(s, Limits.getLimitQueries() - Limits.getQueries()); }
                when 'queryLocatorRows' { r.put(s, Limits.getLimitQueryLocatorRows() - Limits.getQueryLocatorRows()); }
                when 'queryRows' { r.put(s, Limits.getLimitQueryRows() - Limits.getQueryRows()); }
                when 'queueableJobs' { r.put(s, Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()); }
                when 'soslQueries' { r.put(s, Limits.getLimitSoslQueries() - Limits.getSoslQueries()); }
            }
        return r;
    }

    /**
    * reached the limits
    * @param names the names
    * @return Boolean
    */
    global static Boolean reached(List<String> names) {
        if (names == null || names.isEmpty()) return false;
        for (String s : names)
            switch on s {
                when 'aggregateQueries' { if (Limits.getLimitAggregateQueries() - Limits.getAggregateQueries() <= 0) return true; }
                when 'asyncCalls' { if (Limits.getLimitAsyncCalls() - Limits.getAsyncCalls() <= 0) return true; }
                when 'callouts' { if (Limits.getLimitCallouts() - Limits.getCallouts() <= 0) return true; }
                when 'cpuTime' { if (Limits.getLimitCpuTime() - Limits.getCpuTime() <= 0) return true; }
                when 'dmlRows' { if (Limits.getLimitDMLRows() - Limits.getDMLRows() <= 0) return true; }
                when 'dmlStatements' { if (Limits.getLimitDMLStatements() - Limits.getDMLStatements() <= 0) return true; }
                when 'emailInvocations' { if (Limits.getLimitEmailInvocations() - Limits.getEmailInvocations() <= 0) return true; }
                when 'heapSize' { if (Limits.getLimitHeapSize() - Limits.getHeapSize() <= 0) return true; }
                when 'mobilePushApexCalls' { if (Limits.getLimitMobilePushApexCalls() - Limits.getMobilePushApexCalls() <= 0) return true; }
                when 'publishImmediateDML' { if (Limits.getLimitPublishImmediateDML() - Limits.getPublishImmediateDML() <= 0) return true; }
                when 'queries' { if (Limits.getLimitQueries() - Limits.getQueries() <= 0) return true; }
                when 'queryLocatorRows' { if (Limits.getLimitQueryLocatorRows() - Limits.getQueryLocatorRows() <= 0) return true; }
                when 'queryRows' { if (Limits.getLimitQueryRows() - Limits.getQueryRows() <= 0) return true; }
                when 'queueableJobs' { if (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() <= 0) return true; }
                when 'soslQueries' { if (Limits.getLimitSoslQueries() - Limits.getSoslQueries() <= 0) return true; }
            }
        return false;
    }
}