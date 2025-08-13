/**
* an exception and object tuple
*/
global class ExObj {
    global final Exception ex;
    global final Object obj;
    global ExObj(Exception ex, Object obj) {
        this.ex = ex;
        this.obj = obj;
    }
}