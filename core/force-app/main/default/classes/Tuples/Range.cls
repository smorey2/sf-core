/**
* a range tuple
*/
global class Range {
    global final Integer start;
    global final Integer endx;
    global Range(Integer start, Integer endx) {
        this.start = start;
        this.endx = endx;
    }
    global override String toString() { return start + '-' + endx; }
}