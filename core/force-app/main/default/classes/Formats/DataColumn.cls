/**
* a data column
*/
global virtual class DataColumn {
    global String field, displayName;
    global Boolean encode = true;
    global DataColumn() { }
    global DataColumn(String field) { this.field = field; }
    global DataColumn(String field, String displayName) { this.field = field; this.displayName = displayName; }
}
