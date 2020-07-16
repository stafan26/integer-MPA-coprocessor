#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    this->setWindowTitle(QString("ProgWriter"));
    srand(time(0));

    int seed = 0;
    rr = new gmp_randclass(gmp_randinit_default);
    rr->seed(time(NULL));


    srand(time(NULL));

    num_of_address_digits = floor(log10(abs(pow(2, ADDR_WIDTH))))+1;

    /////////////////////////
    //   SET SLIDER RANGES //
    /////////////////////////
    ui->a_limb_spin->setMinimum(1);
    ui->a_limb_spin->setMaximum(SRUP_NUM_OF_MAX_LIMBS);
    ui->a_limb_spin->setValue(1);

    ui->b_limb_spin->setMinimum(1);
    ui->b_limb_spin->setMaximum(SRUP_NUM_OF_MAX_LIMBS);
    ui->b_limb_spin->setValue(1);


    ui->instr_list->setSelectionBehavior(QAbstractItemView::SelectRows);


    qstring_model = new QStringListModel();
    qstring_model->setStringList(instr_final);
    ui->instr_list->setModel(qstring_model);

    selection_model = ui->instr_list->selectionModel();
    connect(selection_model, SIGNAL(currentChanged(QModelIndex,QModelIndex)), this, SLOT(instr_selection_changed(QModelIndex,QModelIndex)));


    /////////////////////////////////
    //   NEW INSTRUCTION BUTTONS   //
    /////////////////////////////////
    sm_new_instr_btn = new QSignalMapper(this);
    connect(ui->loada_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->loadb_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->loadab_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->add_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->sub_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->mult_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->shl_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->shr_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->set0_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->set1_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));
    connect(ui->unl_btn, SIGNAL(clicked()), sm_new_instr_btn, SLOT (map()));

    sm_new_instr_btn->setMapping(ui->loada_btn, QString("loada"));
    sm_new_instr_btn->setMapping(ui->loadb_btn, QString("loadb"));
    sm_new_instr_btn->setMapping(ui->loadab_btn, QString("loadab"));
    sm_new_instr_btn->setMapping(ui->add_btn, QString("add"));
    sm_new_instr_btn->setMapping(ui->sub_btn, QString("sub"));
    sm_new_instr_btn->setMapping(ui->mult_btn, QString("mult"));
    sm_new_instr_btn->setMapping(ui->shl_btn, QString("shl"));
    sm_new_instr_btn->setMapping(ui->shr_btn, QString("shr"));
    sm_new_instr_btn->setMapping(ui->set0_btn, QString("set0"));
    sm_new_instr_btn->setMapping(ui->set1_btn, QString("set1"));
    sm_new_instr_btn->setMapping(ui->unl_btn, QString("unl"));

    connect(sm_new_instr_btn, SIGNAL(mapped(QString)), this, SLOT(new_instr_btn_clicked(const QString &)));


    ////////////////////////////
    //   MOVE INSTR BUTTONS   //
    ////////////////////////////
    sm_move_instr_btn = new QSignalMapper(this);
    connect(ui->move_instr_up_btn, SIGNAL(clicked()), sm_move_instr_btn, SLOT (map()));
    connect(ui->move_instr_down_btn, SIGNAL(clicked()), sm_move_instr_btn, SLOT (map()));
    sm_move_instr_btn->setMapping(ui->move_instr_up_btn, QString("move_up_btn"));
    sm_move_instr_btn->setMapping(ui->move_instr_down_btn, QString("move_down_btn"));
    connect(sm_move_instr_btn, SIGNAL(mapped(QString)), this, SLOT(move_instr_btn_clicked(const QString &)));


    /////////////////////////////
    //   REMOVE INSTR BUTTON   //
    /////////////////////////////
    connect(ui->remove_instr_btn, SIGNAL (clicked()),this, SLOT (remove_instr_btn_clicked()));


    ///////////////////////
    //   REG SPINBOXES   //
    ///////////////////////
    sm_reg_spin = new QSignalMapper(this);
    connect(ui->a_reg_spin, SIGNAL(valueChanged(int)), sm_reg_spin, SLOT (map()));
    connect(ui->b_reg_spin, SIGNAL(valueChanged(int)), sm_reg_spin, SLOT (map()));
    connect(ui->r_reg_spin, SIGNAL(valueChanged(int)), sm_reg_spin, SLOT (map()));
    sm_reg_spin->setMapping(ui->a_reg_spin, QString("a"));
    sm_reg_spin->setMapping(ui->b_reg_spin, QString("b"));
    sm_reg_spin->setMapping(ui->r_reg_spin, QString("r"));
    connect(sm_reg_spin, SIGNAL(mapped(QString)), this, SLOT(reg_spin_changed(const QString &)));


    //////////////////////
    //   SIGN BUTTONS   //
    //////////////////////
    sm_sign_btn = new QSignalMapper(this);
    connect(ui->a_sign_btn, SIGNAL(clicked()), sm_sign_btn, SLOT (map()));
    connect(ui->b_sign_btn, SIGNAL(clicked()), sm_sign_btn, SLOT (map()));
    sm_sign_btn->setMapping(ui->a_sign_btn, QString("a_sign_btn"));
    sm_sign_btn->setMapping(ui->b_sign_btn, QString("b_sign_btn"));
    connect(sm_sign_btn, SIGNAL(mapped(QString)), this, SLOT(sign_btn_clicked(const QString &)));


    //////////////////////
    //   LIMB SLIDERS   //
    //////////////////////
    sm_limb_sld = new QSignalMapper(this);
    connect(ui->a_limb_sld, SIGNAL(valueChanged(int)), sm_limb_sld, SLOT (map()));
    connect(ui->b_limb_sld, SIGNAL(valueChanged(int)), sm_limb_sld, SLOT (map()));
    sm_limb_sld->setMapping(ui->a_limb_sld, QString("a_limb"));
    sm_limb_sld->setMapping(ui->b_limb_sld, QString("b_limb"));
    connect(sm_limb_sld, SIGNAL(mapped(QString)), this, SLOT(limb_sld_changed(const QString &)));


    ////////////////////////
    //   LIMB SPINBOXES   //
    ////////////////////////
    sm_limb_spin = new QSignalMapper(this);
    connect(ui->a_limb_spin, SIGNAL(valueChanged(int)), sm_limb_spin, SLOT (map()));
    connect(ui->b_limb_spin, SIGNAL(valueChanged(int)), sm_limb_spin, SLOT (map()));
    sm_limb_spin->setMapping(ui->a_limb_spin, QString("a_limb"));
    sm_limb_spin->setMapping(ui->b_limb_spin, QString("b_limb"));
    connect(sm_limb_spin, SIGNAL(mapped(QString)), this, SLOT(limb_spin_changed(const QString &)));


    //////////////////////////
    //   LIMB RND BUTTONS   //
    //////////////////////////
    sm_limb_rnd_btn = new QSignalMapper(this);
    connect(ui->a_limb_rnd_btn, SIGNAL(clicked()), sm_limb_rnd_btn, SLOT (map()));
    connect(ui->b_limb_rnd_btn, SIGNAL(clicked()), sm_limb_rnd_btn, SLOT (map()));
    sm_limb_rnd_btn->setMapping(ui->a_limb_rnd_btn, QString("a_limb"));
    sm_limb_rnd_btn->setMapping(ui->b_limb_rnd_btn, QString("b_limb"));
    connect(sm_limb_rnd_btn, SIGNAL(mapped(QString)), this, SLOT(limb_rnd_btn_clicked(const QString &)));


    /////////////////////////
    //   NUM RND BUTTONS   //
    /////////////////////////
    sm_num_rnd_btn = new QSignalMapper(this);
    connect(ui->a_num_rnd_btn, SIGNAL(clicked()), sm_num_rnd_btn, SLOT (map()));
    connect(ui->b_num_rnd_btn, SIGNAL(clicked()), sm_num_rnd_btn, SLOT (map()));
    sm_num_rnd_btn->setMapping(ui->a_num_rnd_btn, QString("a"));
    sm_num_rnd_btn->setMapping(ui->b_num_rnd_btn, QString("b"));
    connect(sm_num_rnd_btn, SIGNAL(mapped(QString)), this, SLOT(num_rnd_btn_clicked(const QString &)));

    disable_all();
}



    //////////////////
    //   1) SLOTS   //
    //////////////////

void MainWindow::new_instr_btn_clicked (const QString &this_name) {
    QString this_list_name = "instr_list";
    QListView *this_list = this->findChild<QListView*>(this_list_name);
    int index = this_list->currentIndex().row();
    int index_after = this_list->currentIndex().row()+1;

    if(index < 0 || index >= instr_list.size()) {
        index = instr_list.count();
        index_after = 0;
    }

    new_instruction(index_after,this_name);
    update_instr_view(index_after);
}


void MainWindow::move_instr_btn_clicked (const QString &this_name) {
    QString this_list_name = "instr_list";
    QListView *this_list = this->findChild<QListView*>(this_list_name);

    int index = this_list->currentIndex().row();
    int index_next = this_list->currentIndex().row() + 1;
    int index_prev = this_list->currentIndex().row() - 1;

    if(this_name == "move_up_btn") {
        if(move_instruction_up(index))
            update_instr_view(index_prev);
    } else if(this_name == "move_down_btn") {
        if(move_instruction_down(index))
            update_instr_view(index_next);
    }
}


void MainWindow::remove_instr_btn_clicked () {
    QString this_list_name = "instr_list";
    QListView *this_list = this->findChild<QListView*>(this_list_name);
    int index = this_list->currentIndex().row();
    int index_prev = index - 1;
    int total = instr_list.size();

    // remove item
    remove_instruction(index);

    // update the view
    if(index < total-1) {
        update_instr_view(index);
    } else if (total > 0) {
        update_instr_view(index_prev);
    }
}


void MainWindow::reg_spin_changed (const QString &this_name) {
    int index = ui->instr_list->currentIndex().row();
    if(this_name == "a") {
        instr_rA[index] = 'R' + QString::number(ui->a_reg_spin->value());
    } else if (this_name == "b") {
        instr_rB[index] = 'R' + QString::number(ui->b_reg_spin->value());
    } else if (this_name == "r") {
        instr_rC[index] = 'R' + QString::number(ui->r_reg_spin->value());
    }
    update_instr_view(index);
}


void MainWindow::sign_btn_clicked (const QString &this_name) {
    int index = ui->instr_list->currentIndex().row();

    if(this_name == "a_sign_btn") {
        //instr_bus_A[index] = -1 * instr_bus_A[index];
        mpz_neg(instr_bus_A[index].get_mpz_t(), instr_bus_A[index].get_mpz_t());
    } else if (this_name == "b_sign_btn") {
        instr_bus_B[index] = -1 * instr_bus_B[index];
    }
    update_status();
}


void MainWindow::limb_sld_changed (const QString &this_name) {
    QString this_spin_name = this_name + "_spin";
    QString this_sld_name = this_name + "_sld";
    QSpinBox *this_spin = this->findChild<QSpinBox*>(this_spin_name);
    QSlider *this_sld = this->findChild<QSlider*>(this_sld_name);
    this_spin->setValue(this_sld->value());
}


void MainWindow::limb_spin_changed(const QString &this_name) {
    QString this_spin_name = this_name + "_spin";
    QString this_sld_name = this_name + "_sld";
    QSpinBox *this_spin = this->findChild<QSpinBox*>(this_spin_name);
    QSlider *this_sld = this->findChild<QSlider*>(this_sld_name);
    this_sld->setValue(this_spin->value());
    std::cout << this_spin->value() << "\n";
}


void MainWindow::limb_rnd_btn_clicked(const QString &this_name) {
    QString this_spin_name = this_name + "_spin";
    QString this_sld_name = this_name + "_sld";
    QSpinBox *this_spin = this->findChild<QSpinBox*>(this_spin_name);
    QSlider *this_sld = this->findChild<QSlider*>(this_sld_name);

    int value = (rand() % SRUP_NUM_OF_MAX_LIMBS) + 1;
    this_sld->setValue(value);
    this_spin->setValue(value);
    std::cout << value << "\n";
}


void MainWindow::num_rnd_btn_clicked(const QString &this_name) {
    QString this_spin_name = this_name + "_limb_spin";
    QSpinBox *this_spin = this->findChild<QSpinBox*>(this_spin_name);
    unsigned int limbs = (unsigned) this_spin->value();
    int index = ui->instr_list->currentIndex().row();
    mpz_class mpz_tmp;
    mp_bitcnt_t bit_prec = ((limbs-1)*BUILT_IN_PREC) + (std::rand() % (BUILT_IN_PREC-1)) + 1;

    do {
        mpz_tmp = rr->get_z_bits(bit_prec);
        if(mpz_tmp < 0)
            mpz_tmp = -mpz_tmp;
    } while (mpz_size(mpz_tmp.get_mpz_t()) != limbs);

    if(this_name == "a") {
        if(instr_bus_A[index] < 0)
            mpz_neg(instr_bus_A[index].get_mpz_t(), mpz_tmp.get_mpz_t());
        else
            instr_bus_A[index] = mpz_tmp;

        update_num_A();
    } else if(this_name == "b") {
        instr_bus_B[index] = mpz_tmp;
        update_num_B();
    }

    update_status();
//    relation_update();
}


void MainWindow::instr_selection_changed(const QModelIndex &current_index, const QModelIndex &previous_index) {
    //qDebug() << "changed" << "current" << current_index.row() << "previous" << previous_index.row();
    int index = current_index.row();
    int opcode = map_instr_to_int(instr_list[index]);
    disable_all();
    switch(opcode) {
        case 1: // LOADA
            enable_write_A(index);
            break;

        case 2: // LOADB
            enable_write_A(index);
            break;

        case 3: // LOADAB
            enable_write_A(index);
            enable_write_B(index);
            break;

        case 4: // UNLOAD
            enable_read_A(index);
            break;

        case 5: // SET0
            enable_read_A(index);
            break;

        case 6: // SET1
            enable_read_A(index);
            break;

        case 7: // S2S
            break;

        case 8: // MULT
            enable_read_A(index);
            enable_read_B(index);
            break;

        case 9: // ADD
            enable_read_A(index);
            enable_read_B(index);
            break;

        case 10: // SUB
            enable_read_A(index);
            enable_read_B(index);
            break;

        default: // NOP
            break;
    }

    update_bin_instr(index);
}


    //////////////////////////////
    //   2) UI DISABLE/ENABLE   //
    //////////////////////////////

void MainWindow::disable_all() {
    a_num_status = 0;
    ui->num_a_lab->setDisabled(true);
    ui->a_reg_lab_lab->setDisabled(true);
    ui->a_reg_spin->setDisabled(true);
    ui->a_sign_btn->setDisabled(true);
    ui->a_limb_lab->setDisabled(true);
    ui->a_limb_spin->setDisabled(true);
    ui->a_limb_rnd_btn->setDisabled(true);
    ui->a_limb_sld->setDisabled(true);
    ui->a_num_list->setDisabled(true);
    ui->a_num_rnd_btn->setDisabled(true);
    ui->a_num_rnd_all_btn->setDisabled(true);
    if(a_num_model != NULL)
        a_num_model->removeRows(0, a_num_model->rowCount());
    ui->a_reg_lab->setDisabled(true);
    ui->a_sign_lab->setDisabled(true);
    ui->a_size_lab->setDisabled(true);

    b_num_status = 0;
    ui->num_b_lab->setDisabled(true);
    ui->b_reg_lab_lab->setDisabled(true);
    ui->b_reg_spin->setDisabled(true);
    ui->b_sign_btn->setDisabled(true);
    ui->b_limb_lab->setDisabled(true);
    ui->b_limb_spin->setDisabled(true);
    ui->b_limb_rnd_btn->setDisabled(true);
    ui->b_limb_sld->setDisabled(true);
    ui->b_num_list->setDisabled(true);
    ui->b_num_rnd_btn->setDisabled(true);
    ui->b_num_rnd_all_btn->setDisabled(true);
    if(b_num_model != NULL)
        b_num_model->removeRows(0, b_num_model->rowCount());
    ui->b_reg_lab->setDisabled(true);
    ui->b_sign_lab->setDisabled(true);
    ui->b_size_lab->setDisabled(true);

    ui->a_sign_lab->setDisabled(true);
    ui->b_sign_lab->setDisabled(true);
    ui->relation_lab->setDisabled(true);

    ui->res_sign_lab->setDisabled(true);
    ui->swap_lab->setDisabled(true);

    ui->res_main_lab->setDisabled(true);
    ui->r_reg_name_lab->setDisabled(true);
    ui->r_reg_spin->setDisabled(true);
    ui->r_reg_lab->setDisabled(true);
    ui->r_sign_lab->setDisabled(true);
    ui->r_size_lab->setDisabled(true);

    ui->res_shad_lab->setDisabled(true);
    ui->s_reg_lab->setDisabled(true);
    ui->s_reg_lab->setDisabled(true);
    ui->s_sign_lab->setDisabled(true);
    ui->s_size_lab->setDisabled(true);
}

void MainWindow::enable_read_A(int index) {
    a_num_status = 1;
    ui->num_a_lab->setDisabled(false);
    ui->a_reg_lab_lab->setDisabled(false);
    ui->a_reg_spin->setDisabled(false);
    ui->a_limb_lab->setDisabled(false);
    ui->a_num_list->setDisabled(false);
    ui->a_reg_spin->setValue(instr_rA[index].right(instr_rA[index].size()-1).toInt());
    ui->a_reg_lab->setDisabled(false);
    ui->a_sign_lab->setDisabled(false);
    ui->a_size_lab->setDisabled(false);
    update_status();
}

void MainWindow::enable_write_A(int index) {
    a_num_status = 2;
    ui->num_a_lab->setDisabled(false);
    ui->a_reg_lab_lab->setDisabled(false);
    ui->a_reg_spin->setDisabled(false);
    ui->a_sign_btn->setDisabled(false);
    ui->a_limb_lab->setDisabled(false);
    ui->a_limb_spin->setDisabled(false);
    ui->a_limb_rnd_btn->setDisabled(false);
    ui->a_limb_sld->setDisabled(false);
    ui->a_num_list->setDisabled(false);
    ui->a_num_rnd_btn->setDisabled(false);
    ui->a_num_rnd_all_btn->setDisabled(false);
    ui->a_reg_spin->setValue(instr_rA[index].right(instr_rA[index].size()-1).toInt());

    if(instr_bus_A[index] < 0)
        ui->a_sign_lab->setText("-");
    else
        ui->a_sign_lab->setText("+");

    ui->a_reg_lab->setDisabled(false);
    ui->a_sign_lab->setDisabled(false);
    ui->a_size_lab->setDisabled(false);

    update_num_A();
    update_status();
}

void MainWindow::enable_read_B(int index) {
    b_num_status = 1;
    ui->num_b_lab->setDisabled(false);
    ui->b_reg_lab_lab->setDisabled(false);
    ui->b_reg_spin->setDisabled(false);
    ui->b_limb_lab->setDisabled(false);
    ui->b_num_list->setDisabled(false);
    ui->b_reg_spin->setValue(instr_rB[index].right(instr_rB[index].size()-1).toInt());
    ui->b_reg_lab->setDisabled(false);
    ui->b_sign_lab->setDisabled(false);
    ui->b_size_lab->setDisabled(false);
    update_status();
}

void MainWindow::enable_write_B(int index) {
    b_num_status = 2;
    ui->num_b_lab->setDisabled(false);
    ui->b_reg_lab_lab->setDisabled(false);
    ui->b_reg_spin->setDisabled(false);
    ui->b_sign_btn->setDisabled(false);
    ui->b_limb_lab->setDisabled(false);
    ui->b_limb_spin->setDisabled(false);
    ui->b_limb_rnd_btn->setDisabled(false);
    ui->b_limb_sld->setDisabled(false);
    ui->b_num_list->setDisabled(false);
    ui->b_num_rnd_btn->setDisabled(false);
    ui->b_num_rnd_all_btn->setDisabled(false);
    ui->b_reg_spin->setValue(instr_rB[index].right(instr_rB[index].size()-1).toInt());

    if(instr_bus_A[index] < 0)
        ui->a_sign_lab->setText("-");
    else
        ui->a_sign_lab->setText("+");

    ui->b_reg_lab->setDisabled(false);
    ui->b_sign_lab->setDisabled(false);
    ui->b_size_lab->setDisabled(false);

    update_num_B();
    update_status();
}



    ///////////////////////////////////
    //   3) INSTRUCTION OPERATIONS   //
    ///////////////////////////////////

void MainWindow::new_instruction(int index, QString instr) {
    int opcode = map_instr_to_int(instr);
    QString rA;
    QString sAB;
    QString rB;
    QString sBC;
    QString rC;


    switch(opcode) {
        case 1: // LOADA
                rA = "R0"; sAB = ""; rB = ""; sBC = ""; rC = ""; break;
        case 2: // LOADB
                rA = "R0"; sAB = ""; rB = ""; sBC = ""; rC = ""; break;
        case 3: // LOADAB
                rA = "R0"; sAB = ","; rB = "R1"; sBC = ""; rC = ""; break;
        case 4: // UNLOAD
                rA = "R0"; sAB = ""; rB = ""; sBC = ""; rC = ""; break;
        case 5: // SET0
                rA = "R0"; sAB = ""; rB = ""; sBC = ""; rC = ""; break;
        case 6: // SET1
                rA = "R0"; sAB = ""; rB = ""; sBC = ""; rC = ""; break;
        case 7: // S2S
                rA = "R0"; sAB = ""; rB = ""; sBC = ""; rC = ""; break;
        case 8: // MULT
                rA = "R0"; sAB = "*"; rB = "R1"; sBC = "="; rC = "R2"; break;
        case 9: // ADD
                rA = "R0"; sAB = "+"; rB = "R1"; sBC = "="; rC = "R2"; break;
        case 10: // SUB
                rA = "R0"; sAB = "-"; rB = "R1"; sBC = "="; rC = "R2"; break;
        default: // NOP
                break;
    }

    instr_num.insert(index, "x");
    instr_list.insert(index,instr);
    instr_rA.insert(index, rA);
    instr_sAB.insert(index, sAB);
    instr_rB.insert(index, rB);
    instr_sBC.insert(index, sBC);
    instr_rC.insert(index, rC);

    instr_bus_A.insert(index, c_zero);
    instr_bus_B.insert(index, c_zero);
    renumarateInstrNum();
}

bool MainWindow::move_instruction_up(int index) {
    if(index > 0) {
        instr_num.move(index, index-1);
        instr_list.move(index, index-1);
        instr_rA.move(index, index-1);
        instr_sAB.move(index, index-1);
        instr_rB.move(index, index-1);
        instr_sBC.move(index, index-1);
        instr_rC.move(index, index-1);
        instr_bus_A.move(index, index-1);
        instr_bus_B.move(index, index-1);
        renumarateInstrNum();
        return true;
    }
    return false;
}

bool MainWindow::move_instruction_down(int index) {
    if(index < instr_list.size()-1) {
        instr_num.move(index, index+1);
        instr_list.move(index, index+1);
        instr_rA.move(index, index+1);
        instr_sAB.move(index, index+1);
        instr_rB.move(index, index+1);
        instr_sBC.move(index, index+1);
        instr_rC.move(index, index+1);
        instr_bus_A.move(index, index+1);
        instr_bus_B.move(index, index+1);
        renumarateInstrNum();
        return true;
    }
    return false;
}

void MainWindow::remove_instruction(int index) {
    if(index < instr_list.size()) {
        instr_num.removeAt(index);
        instr_list.removeAt(index);
        instr_rA.removeAt(index);
        instr_sAB.removeAt(index);
        instr_rB.removeAt(index);
        instr_sBC.removeAt(index);
        instr_rC.removeAt(index);
        instr_bus_A.removeAt(index);
        instr_bus_B.removeAt(index);
        renumarateInstrNum();
    }
}


    ///////////////////////////////////
    //   4) UI INSTRUCTION UPDATES   //
    ///////////////////////////////////

void MainWindow::update_instr_view(int index) {
    QString this_list_name = "instr_list";
    QListView *this_list = this->findChild<QListView*>(this_list_name);
    instr_final = formNewInstrModel();

    qstring_model->setStringList(instr_final);
    ui->instr_list->setModel(qstring_model);
    if(index >= 0) {
        this_list->setCurrentIndex(qstring_model->index(index, 0));
    } else {
        this_list->clearSelection();
    }

    ui->num_of_instr->setText(QString::number(instr_list.size()));

    update_bin_instr(index);
}

void MainWindow::update_bin_instr(int index) {
    QString bin_instr = "";
    if(index >= 0) {
        if(index >= 0 && index < instr_list.size()) {
            int two_part_instr = instr_rB[index].size();
            int opcode = map_instr_to_int(instr_list[index]);
            int regA = instr_rA[index].right(instr_rA[index].size()-1).toInt();
            int regB = instr_rB[index].right(instr_rB[index].size()-1).toInt();
            int regC = instr_rC[index].right(instr_rC[index].size()-1).toInt();

            if(two_part_instr) {
                if(instr_rC[index].size() > 0)
                    bin_instr += QString::number(regC, 16);
                else
                    bin_instr += "(0)";
                bin_instr += QString::number(regB, 16) + " ";
            }
            bin_instr += QString::number(regA, 16) + QString::number(opcode, 16);
        }
        ui->bin_instr->setText(bin_instr);
    } else {
        ui->bin_instr->setText(bin_instr);
    }
}

void MainWindow::update_status() {
    int index = ui->instr_list->currentIndex().row();
    size_t limbs;

    switch (a_num_status) {
        case 1:
            break;

        case 2:
            limbs = mpz_size(instr_bus_A[index].get_mpz_t());
            if(limbs <= 0)
                limbs = 1;
            if(instr_bus_A[index] < 0)
                ui->a_sign_lab->setText("-");
            else
                ui->a_sign_lab->setText("+");

            ui->a_size_lab->setText(QString("limbs = ") + QString::number(limbs));

            break;


        default: break;
    }

    switch (b_num_status) {
        case 1:
            break;

        case 2:
            limbs = mpz_size(instr_bus_B[index].get_mpz_t());
            if(limbs <= 0)
                limbs = 1;
            if(instr_bus_B[index] < 0)
                ui->b_sign_lab->setText("-");
            else
                ui->b_sign_lab->setText("+");

            ui->b_size_lab->setText("limbs = " + QString::number(limbs));

            break;

        default: break;
    }

}

    ///////////////////////////
    //   5) NUMBER UPDATES   //
    ///////////////////////////

void MainWindow::update_num_A() {
    int index = ui->instr_list->currentIndex().row();
    a_num_list = print_mpz_num(abs(instr_bus_A[index]));

    if(a_num_model != NULL)
        delete a_num_model;
    a_num_model = new QStringListModel(a_num_list);
    ui->a_num_list->setModel(a_num_model);
}

void MainWindow::update_num_B() {
    int index = ui->instr_list->currentIndex().row();
    b_num_list = print_mpz_num(abs(instr_bus_B[index]));

    if(b_num_model != NULL)
        delete b_num_model;
    b_num_model = new QStringListModel(b_num_list);
    ui->b_num_list->setModel(b_num_model);
}


void MainWindow::relation_update() {
    QLabel *a_sign_lab = this->findChild<QLabel*>(QString("a_sign_lab"));
    QLabel *b_sign_lab = this->findChild<QLabel*>(QString("b_sign_lab"));
    QLabel *relation_lab = this->findChild<QLabel*>(QString("relation_lab"));

    if(mpa_nums[0] < 0) {
        a_sign_lab->setText("|A| < 0");
    } else if(mpa_nums[0] == 0) {
        a_sign_lab->setText("|A| = 0");
    } else if(mpa_nums[0] > 0) {
        a_sign_lab->setText("|A| > 0");
    }

    if(mpa_nums[1] < 0) {
        b_sign_lab->setText("|B| < 0");
    } else if(mpa_nums[0] == 0) {
        b_sign_lab->setText("|B| = 0");
    } else if(mpa_nums[0] > 0) {
        b_sign_lab->setText("|B| > 0");
    }

    if(abs(mpa_nums[0]) < abs(mpa_nums[1])) {
        relation_lab->setText("|A| < |B|");
    } else if(abs(mpa_nums[0]) == abs(mpa_nums[1])) {
        relation_lab->setText("|A| = |B|");
    } else if(abs(mpa_nums[0]) > abs(mpa_nums[1])) {
        relation_lab->setText("|A| > |B|");
    }
}


    ////////////////////////////////
    //   6) LOW LEVEL FUNCTIONS   //
    ////////////////////////////////


void MainWindow::renumarateInstrNum() {
    QString total = QString::number(instr_num.size());
    int width = total.size();

    for(int i=0; i<instr_num.size(); i++)
        instr_num[i] = QString("%1").arg(i, width, 10, QChar('0'));
}


int MainWindow::map_instr_to_int(QString &instr) {
    int instr_int = 0;

    if(instr == "loada")
        instr_int = 1;
    else if(instr == "loadb")
        instr_int = 2;
    else if(instr == "loadab")
        instr_int = 3;
    else if(instr == "unl")
        instr_int = 4;
    else if(instr == "set0")
        instr_int = 5;
    else if(instr == "set1")
        instr_int = 6;
    else if(instr == "s2s")
        instr_int = 7;
    else if(instr == "mult")
        instr_int = 8;
    else if(instr == "add")
        instr_int = 9;
    else if(instr == "sub")
        instr_int = 10;

    return instr_int;
}


QStringList MainWindow::formNewInstrModel() {
    QStringList new_list;
    QString instr_adj;
    int i, j;

    for(i = 0; i<instr_list.size(); i++) {
        instr_adj = instr_list[i];
        for(j=6-instr_adj.size(); j>0; j--)
            instr_adj.insert(0, QChar(' '));
        new_list << instr_num[i] + ": " + instr_adj + " " + instr_rA[i] + " " + instr_sAB[i] + " " + instr_rB[i] + " " + instr_sBC[i] + " " + instr_rC[i];
    }
    return new_list;
}


QStringList MainWindow::print_mpz_num(mpz_class number) {
    QStringList num_list;
    QString tmp_qstr;
    int max_size = number.get_str(16).size();
    int offset = max_size % NUM_OF_HEX_IN_LIMB_PREC;

    tmp_qstr = "";

    for(int i=max_size-1; i >= 0; i--) {       // store the new number
        tmp_qstr.prepend(QChar(number.get_str(16).c_str()[i]));

        if(i % NUM_OF_HEX_IN_LIMB_PREC == offset || i == 0) {
            num_list.append(tmp_qstr);
            tmp_qstr = "";
        }
    }

    for(int i=0; i<num_list.size(); i++) {
        // fill up with heading zeros
        for(int j=NUM_OF_HEX_IN_LIMB_PREC-num_list.at(i).size(); j>0; j--)
            num_list[i].insert(0, QChar('0'));

        // space separation
        num_list[i].insert(NUM_OF_HEX_IN_LIMB_PREC/2, QChar(' '));

        // add address and ":"0x"
        num_list[i].insert(0, QString::number(i) + QString(": 0x"));
        for(int j = num_of_address_digits-QString::number(i).size(); j > 0; j--)
            num_list[i].insert(0, QChar('0'));
    }

    return num_list;
}

MainWindow::~MainWindow()
{
    delete ui;
}
