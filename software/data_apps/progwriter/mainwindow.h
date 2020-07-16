#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#define SRUP_NUM_OF_MAX_LIMBS 512
#define BUILT_IN_PREC 64
#define NUM_OF_HEX_IN_LIMB_PREC (64/4)
#define ADDR_WIDTH 9

#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>

#include <QMainWindow>
#include <QPushButton>
#include <QSignalMapper>
#include <QModelIndex>
#include <QAbstractItemModel>
#include <QItemSelectionModel>
#include <QStringList>
#include <QStringListModel>
#include <QListView>
#include <QAbstractItemView>
#include <QSpinBox>
#include <QDebug>
#include <gmpxx.h>

#include <ctime>    // For time()
#include <cstdlib>  // For srand() and rand()

const mpz_class c_zero = 0;


namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    // 1) SLOTS
    void new_instr_btn_clicked (const QString &this_name);
    void move_instr_btn_clicked (const QString &this_name);
    void remove_instr_btn_clicked ();
    void reg_spin_changed (const QString &this_name);
    void sign_btn_clicked (const QString &this_name);
    void limb_sld_changed (const QString &this_name);
    void limb_spin_changed (const QString &this_name);
    void limb_rnd_btn_clicked (const QString &this_name);
    void num_rnd_btn_clicked (const QString &this_name);
    void instr_selection_changed(const QModelIndex &current_index, const QModelIndex &previous_index);



private:
    Ui::MainWindow *ui;
    gmp_randclass *rr;
    int num_of_address_digits;

    QStringListModel *qstring_model;
    QItemSelectionModel *selection_model;

    QSignalMapper *sm_new_instr_btn;
    QSignalMapper *sm_move_instr_btn;
    QSignalMapper *sm_reg_spin;
    QSignalMapper *sm_sign_btn;
    QSignalMapper *sm_limb_sld;
    QSignalMapper *sm_limb_spin;
    QSignalMapper *sm_limb_rnd_btn;
    QSignalMapper *sm_num_rnd_btn;

    gmp_randstate_t state;
    mpz_class mpa_nums[4];
    mpz_class mpa_abs;
    mpz_class mpa_sign;

    QStringList instr_num;
    QStringList instr_list;
    QStringList instr_rA;
    QStringList instr_sAB;
    QStringList instr_rB;
    QStringList instr_sBC;
    QStringList instr_rC;
    QList<mpz_class> instr_bus_A;
    QList<mpz_class> instr_bus_B;

    QStringList instr_final;

    QAbstractItemModel *a_num_model = NULL;
    QAbstractItemModel *b_num_model = NULL;
    int a_num_status;
    int b_num_status;

    QStringList a_num_list;
    QStringList b_num_list;

    QStringList a_num_rnd;
    QStringList b_num_rnd;


    // 2) UI DISABLE/ENABLE
    void disable_all();
    void enable_read_A(int index);
    void enable_write_A(int index);
    void enable_read_B(int index);
    void enable_write_B(int index);

    // 3) INSTRUCTION OPERATIONS
    void new_instruction(int index, QString instr);
    bool move_instruction_up(int index);
    bool move_instruction_down(int index);
    void remove_instruction(int index);

    // 4) UI INSTRUCTION UPDATES
    void update_instr_view(int index);
    void update_bin_instr(int index);
    void update_status();

    // 5) NUMBER UPDATES
    void update_num_A();
    void update_num_B();
    void relation_update();

    // 6) LOW LEVEL FUNCTIONS
    void renumarateInstrNum();                  // renumerates the instruction numbers
    int map_instr_to_int(QString &instr);       // maps instruction to opcode
    QStringList formNewInstrModel();            // forms full instruction list (based on all fields)
    QStringList print_mpz_num(mpz_class number);// reformat the mpz number to QStringList
};

#endif // MAINWINDOW_H
