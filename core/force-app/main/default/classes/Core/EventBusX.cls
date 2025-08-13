/**
* EventBus method extensions
*/
global class EventBusX {
    /**
    * publishes events
    * @param sobjects the events
    * @return Boolean
    */
    global static Boolean publish(List<SObject> sobjects) {
        if (sobjects == null || sobjects.isEmpty()) return true;
        Boolean r = true;
        for (Database.SaveResult s : EventBus.publish(sobjects))
            if (s.isSuccess()) SystemX.debug('Successfully published event.');
            else { r = false; for (Database.Error e : s.getErrors()) SystemX.debug('Error: [' + e.getStatusCode() + ']' + e.getMessage()); }
        return r;
    }
}