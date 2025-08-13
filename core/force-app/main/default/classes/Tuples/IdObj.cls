/**
* an id and object tuple
*/
global class IdObj {
    global final Id id;
    global final Object obj;
    global IdObj(Id id, Object obj) {
        this.id = id;
        this.obj = obj;
    }
}