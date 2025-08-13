/**
* http batch
*/
global virtual class HttpBatch {
    global Logger log;
    global Logger pro;
    global String name;
    global String lastError;
    global Map<String, Object> values = new Map<String, Object>();
    global List<HttpTask> rollbacks = new List<HttpTask>();
    global Set<HttpTask> ends = new Set<HttpTask>();
    global List<Object> queue = new List<Object>();
    
    /**
    * constructor
    */
    global HttpBatch() { }
    /**
    * constructor
    * @param log the log
    * @param name the name
    */
    global HttpBatch(Logger log, String name) { this.log = log; this.name = name; }
    /**
    * constructor
    * @param log the log
    * @param pro the pro
    * @param name the name
    */
    global HttpBatch(Logger log, Logger pro, String name) { this.log = log; this.pro = pro; this.name = name; }

    //#region values

    /**
    * gets a value
    * @param id the id
    * @return Object
    */
    global Object get(String id) { return values.get(id); }

    //#endregion

    //#region fluent

    /**
    * clear
    * @param name the name
    * @return HttpBatch
    */
    global HttpBatch clear(String name) {
        this.name = name;
        Dml.clear();
        rollbacks.clear();
        ends.clear();
        queue.clear();
        if (name != null) values.clear();
        return this;
    }

    /**
    * clear ends
    * @return HttpBatch
    */
    global HttpBatch clearEnds() { ends.clear(); return this; }

    /**
    * remove ends
    * @param task the task
    * @return HttpBatch
    */
    global HttpBatch removeEnds(HttpTask task) { if (task != null) ends.remove(task); return this; }

    /**
    * remove ends
    * @param task the task
    * @return HttpBatch
    */
    global HttpBatch removeEnds(Integer task) { if (task < ends.size()) ends.remove(new List<HttpTask>(ends)[task]); return this; }

    /**
    * add the task
    * @param task the task
    * @return HttpBatch
    */
    global HttpBatch checkpoint() {
        flush();
        flushEnd(true);
        flushDml();
        rollbacks.clear();
        log?.logInfo(name, '- CHECKPOINT -');
        return this;
    }

    /**
    * add the task
    * @param task the task
    * @return HttpBatch
    */
    global HttpBatch add(HttpTask task) { if (task?.endx != null) ends.add(task); return this; }

    /**
    * logs the information
    * @param msg the msg
    * @return HttpBatch
    */
    global HttpBatch logInformation(String msg) { if (msg != null) queue.add(msg); return this; }

    /**
    * calls the task
    * @param task the task
    * @return HttpBatch
    */
    global HttpBatch call(HttpTask task) { if (task != null) queue.add(new Tuple3(task, null, null)); return add(task); }
    /**
    * calls the task
    * @param task the task
    * @param id the id
    * @param path the path
    * @return HttpBatch
    */
    global HttpBatch call(HttpTask task, Object id, Object path) { if (task != null) queue.add(new Tuple3(task, id, path)); return add(task); }

    /**
    * exception
    * @param e the exception
    * @return HttpBatch
    */
    global virtual HttpBatch exception(Exception e) {
        lastError = e?.getMessage();
        log?.logInfo(name, '- EXCEPTION -');
        log?.logInfo(name, lastError + '\n' + e?.getStackTraceString());
        queue.clear();
        rollback();
        return this;
    }

    /**
    * puts a value
    * @param id the id
    * @param value the value
    * @return HttpBatch
    */
    global HttpBatch put(String id, Object value) { values.put(id, value); return this; }

    //#endregion

    //#region flush

    /**
    * flushes the queue
    * @return HttpBatch
    */
    global virtual HttpBatch flush() {
        if (queue.isEmpty()) return this;
        try {
            for (Object s : queue) {
                if (s instanceof String) { String msg = String.valueOf(ObjectX.mergex(values, (String)s)); SystemX.debug(msg); log?.logInfo(name, msg); }
                else if (s instanceof Tuple3) {
                    Tuple3 t = (Tuple3)s;
                    HttpTask task = (HttpTask)t.item1;
                    Object res = task.bind(values, t.item2, t.item3).result(this);
                    if (task.rollbackx != null) rollbacks.add(task.rollbackx);
                }
            }
        }
        finally { queue.clear(); }
        return this;
    }

    /**
    * flushes the queue
    * @return HttpBatch
    */
    global virtual HttpBatch flushEnd(Boolean success) {
        if (ends.isEmpty()) return this;
        try {
            for (HttpTask s : ends) { String msg = 'endx[' + success + ']: ' + String.valueOf(s.endx).substringBefore(':'); SystemX.debug(msg); s.endx.end(s, this, success); }
        }
        finally { ends.clear(); }
        return this;
    }

    /**
    * flushDml
    */
    global virtual HttpBatch flushDml() { Dml.flush(); return this; }

    //#endregion

    //#region actions

    /**
    * rollback handler
    */
    global virtual void rollback() {
        if (rollbacks.isEmpty()) return;
        SystemX.debug('- ROLLBACK -');
        log?.logInfo(name, '- ROLLBACK -');
        for (Integer i = rollbacks.size() - 1; i >= 0; i--) {
            HttpTask s = rollbacks[i];
            SystemX.debug('roll:' + String.valueOf(s.request).substringBefore(':'));
            try { s.bind(values, null, null).result(this); }
            catch (Exception e) { System.debug(e.getMessage()); }
        }
        rollbacks.clear();
    }

    /**
    * end
    * @param success the success
    */
    global virtual void end(Boolean success) {
        flush();
        flushEnd(success);
        flushDml();
        String msg = '- END (' + success + ') -'; SystemX.debug(msg); log?.logInfo(name, msg);
        clear(null);
    }

    //#endregion
}
