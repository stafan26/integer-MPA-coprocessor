//#include <QCoreApplication>
#include <cstdlib>
#include <iostream>
#include <sstream>

using namespace std;

class mult {
    int A_size;
    int B_size;
    int A_start_addr;
    int B_start_addr;
    int A_curr_addr;
    int B_curr_addr;
    int smaller;
    int greater;

    int up_cycle;
    int flat_cycle;
    int down_cycle;

public:

    void init(int a, int b) {
        A_size = a;
        B_size = b;
        A_start_addr = -1;
        B_start_addr = 0;
        A_curr_addr = 0;
        B_curr_addr = 0;
        smaller = a;
        greater = b;
        if(smaller > greater) {
            smaller = b;
            greater = a;
        }
        up_cycle = 0;
        flat_cycle = 0;
        down_cycle = 0;
    }

    int get_smaller() {return smaller;}
    int get_greater() {return greater;}

    int get_up_cycle() {return up_cycle;}
    int get_flat_cycle() {return flat_cycle;}
    int get_down_cycle() {return down_cycle;}

    void incr_up_cycle() {up_cycle++;}
    void decr_up_cycle() {up_cycle--;}
    void incr_flat_cycle() {flat_cycle++;}
    void incr_down_cycle() {down_cycle++;}

    void print_line() {cout << "      A" << A_curr_addr << " * B" << B_curr_addr << endl;}

    void modify_addr() {
        A_curr_addr--;
        B_curr_addr++;
    }

    void do_up_cycle() {
        A_start_addr++;
        A_curr_addr = A_start_addr;
        B_curr_addr = B_start_addr;
    }

    void do_flat_cycle() {


        if(A_start_addr < A_size-1) {
            A_start_addr++;
        }

        if(B_start_addr < B_size-1 & B_size >= A_size) {
            B_start_addr++;
        }

        A_curr_addr = A_start_addr;
        B_curr_addr = B_start_addr;

    }

    void do_down_cycle() {
        B_start_addr++;
        A_curr_addr = A_start_addr;
        B_curr_addr = B_start_addr;
    }

};

int main(int argc, char *argv[])
{
    mult m;
    if (argc != 3) {
        cout << "Usage: addressing A_size B_size" << endl;
        exit(0);
    } else {
        m.init(atoi(argv[1]), atoi(argv[2]));
    }

    int cycle_cnt = 1;

    cout << "    ============" << endl;
    cout << "    ==   UP   ==" << endl;
    cout << "    ============" << endl;

    for(int j=0; j < m.get_smaller(); j++) {
        m.do_up_cycle();
        for(int i = 0; i <= m.get_up_cycle(); i++) {
            m.print_line();
            m.modify_addr();
        }
        cout << cycle_cnt << " (" << m.get_up_cycle()+1 << ") --------" << endl << endl;
        cycle_cnt++;
        m.incr_up_cycle();
    }

    cout << "   ==============" << endl;
    cout << "   ==   FLAT   ==" << endl;
    cout << "   ==============" << endl;

    for(int j=m.get_smaller(); j < m.get_greater(); j++) {
        m.do_flat_cycle();
        for(int i = 0; i < m.get_smaller(); i++) {
            m.print_line();
            m.modify_addr();
        }
        cout << cycle_cnt << " (" << m.get_flat_cycle()+1 << ") --------" << endl << endl;
        cycle_cnt++;
        m.incr_flat_cycle();
    }

    cout << "   ==============" << endl;
    cout << "   ==   DOWN   ==" << endl;
    cout << "   ==============" << endl;

    m.decr_up_cycle();
    for(int j=0; j < m.get_smaller()-1; j++) {
        m.do_down_cycle();
        for(int i = 0; i < m.get_up_cycle(); i++) {
            m.print_line();
            m.modify_addr();
        }
        cout << cycle_cnt << " (" << m.get_down_cycle()+1 << ") --------" << endl << endl;
        cycle_cnt++;
        m.incr_down_cycle();
        m.decr_up_cycle();
    } //*/

    return 0;
}
