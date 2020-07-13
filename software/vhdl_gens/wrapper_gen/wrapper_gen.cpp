//============================================================================
// Name        : kaminst.cpp
// Author      : Tomasz Stefanski
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <stdlib.h>

using namespace std;

#define SCRIPTNAME	"instantiation.sh "
#define TMPFILENAME	"tmp.txt"
#define RMCOM		"rm"

//============================================================================
//Function taken from stackoverflow.com .
bool file_exists (const std::string& name) {

    ifstream f(name.c_str());
    return f.good();
}
//============================================================================
int main(int argc, char *argv[]) {

	string			this_prog_path;
	string			file_in_name;
	string			file_out_name;
	stringstream	file_in;
	stringstream	file_tmp;
	stringstream	file_out;
	ifstream		file_in_stream;
	ofstream		file_out_stream;

	size_t			found1, found2, found3, found4, found5;

	string			buffer, tmp, atmp, aatmp;
	string			header, signals, entities, process;

	//check correctness of function call
	if (argc != 3) {
		cout << "Wrong number of arguments" << endl;
		cout << "Correct usage: wrapper_gen file_in.vhd file_out.vhd" << endl;
		return 1;
	} else {
		file_in_name = argv[1];
		file_out_name = argv[2];
	}

	if (! file_exists (file_in_name) ) {
		cout << "Input file does not exist" << endl;
		return 2;
	}

	//open and read the input file
	file_in_stream.open(file_in_name.c_str());
	file_in << file_in_stream.rdbuf();
	file_in_stream.close();
	buffer = file_in.str();

	//execute content copying [PKAM_1]
	found1 = buffer.find("architecture");
	header = buffer.substr (0,found1);
	found2 = buffer.find("\n", found1);
	header += buffer.substr (found1, found2-found1+1);
/*
	//[PKAM_1a_1b]
	found1 = header.find("port");
	found2 = header.find("\n", found1);
	do {
		found1 = header.find("\n", found2+1);
		if (found1 != string::npos) {
			buffer = header.substr (found2+1, found1-found2);//get new line
			found3 = buffer.find(":");
			if (found3 != string::npos) {
				found4 = buffer.find_first_not_of(" \t");
				atmp = buffer.substr (found4, 2);
				if (!( (atmp.compare("pi") == 0) || (atmp.compare("po") == 0))) {
					found5 = buffer.find_first_not_of(" \t", found3+1);
					atmp = buffer.substr (found5, 3);
					if (atmp.compare("in ") == 0) {
						header.insert( found2+found4+1, "pi_");
					} else if (atmp.compare("out") == 0) {
						header.insert( found2+found4+1, "po_");
					} else {
						cout << "Wrong format of input file" << endl;
						return 3;
					}
				}
			}
			found2 = found1;
		}
	} while (found1 != string::npos);
	//cout << header << endl << endl;
*/
	//pi_clk -> pi_clk_ext and pi_rst -> pi_rst_ext  [PKAM_2]
	found2 = 0;
	do {
		found1 = header.find("pi_clk", found2+1);
		if (found1 != string::npos) {
			header.insert(found1 + 6, "_ext");
			found2 = found1;
		}
	} while (found1 != string::npos);

	found2 = 0;
	do {
		found1 = header.find("pi_rst", found2+1);
		if (found1 != string::npos) {
			header.insert(found1 + 6, "_ext");
			found2 = found1;
		}
	} while (found1 != string::npos);

	//add postfix  [PKAM_3]
	found1 = header.find("entity");
	found2 = header.find(" ", found1+7);
	found3 = found2 - (found1+7);
	tmp = header.substr (found1+7, found3);

	found2 = 0;
	do {
		found1 = header.find(tmp, found2+1);
		if (found1 != string::npos) {
			header.insert(found1 + found3, "_wrapper");
			found2 = found1;
		}
	} while (found1 != string::npos);

	//entities section  [PKAM_5]
	entities  = "	MY_PLL_INST: entity work.my_pll port map (\n";
	entities += "		pi_clk_ext		=> pi_clk_ext,		--: in std_logic;\n";
	entities += "		pi_rst_ext		=> pi_rst_ext,		--: in std_logic;\n";
	entities += "		po_clk			=> s_clk,			--: out std_logic;\n";
	entities += "		po_rst			=> s_rst,			--: out std_logic;\n";
	entities += "		po_clk_div		=> open				--: out std_logic\n";
	entities += "	);\n\n";

	//call a script and process output  [PKAM_6]
	this_prog_path = argv[0];
	this_prog_path = this_prog_path.substr(0, this_prog_path.find_last_of("/")+1);

    tmp = this_prog_path;
	tmp += SCRIPTNAME;
	tmp += file_in_name.c_str();
	system(tmp.c_str());

	file_in_stream.open(TMPFILENAME);
	file_tmp << file_in_stream.rdbuf();
	file_in_stream.close();
	tmp = file_tmp.str();
	tmp += "\n\n";
	//cout << tmp << endl << endl;

	//pi_clk->s_clk, pi_rst -> s_rst  [PKAM_8]
	found2 = 0;
	do {
		found1 = tmp.find("pi_clk", found2+1);
		if (found1 != string::npos) {
			if (tmp[found1 + 6] == ',') {
				tmp.replace(found1, 2, "s");
			}
			found2 = found1;
		}
	} while (found1 != string::npos);

	found2 = 0;
	do {
		found1 = tmp.find("pi_rst", found2+1);
		if (found1 != string::npos) {
			if (tmp[found1 + 6] == ',') {
				tmp.replace(found1, 2, "s");
			}
			found2 = found1;
		}
	} while (found1 != string::npos);

	//=> p->s [PKAM_9]
	found2 = 0;
	do {
		found1 = tmp.find("=>", found2+1);
		if (found1 != string::npos) {
			if (tmp[found1 + 3] == 'p') {
				tmp.replace(found1+3, 1, "s");
			}
			found2 = found1;
		}
	} while (found1 != string::npos);

	//remove ","  [PKAM_7]
	atmp.clear();
	buffer.clear();
	found2 = 0;
	do {
		found1 = tmp.find("\n", found2+1);
		if (found1 != string::npos) {
			buffer = tmp.substr (found2+1, found1-found2);//get new line
			found3 = buffer.find("=>");
			if (found3 == string::npos) {//line without "=>"
				found4 = atmp.find("=>");//if previous line with "=>"
				if (found4 != string::npos) {
					found4 = atmp.find(',');//must be a comma
					tmp.erase(found1-buffer.length()-atmp.length()+found4+1, 1);//erase it
				}
			}
			atmp = buffer;//copy to previous line
			found2 = found1;
		}
	} while (found1 != string::npos);

	//add to entities [PKAM_10]
	entities += tmp;

	//[PKAM_11]
	found1 = tmp.find("port");
	found2 = tmp.find("map", found1);
	found3 = tmp.find("(", found2);
	found4 = tmp.find("\n", found3);
	atmp = tmp.substr (found4+1, string::npos);
	found2 = 0;
	do {
		found1 = atmp.find("\n", found2+1);
		if (found1 != string::npos) {
			buffer = atmp.substr (found2+1, found1-found2);//get new line
			found3 = buffer.find("=>");
			if (found3 != string::npos) {
				//found4 = buffer.find("p");
				found4 = buffer.find_first_not_of(" \t");
				buffer.replace(found4, found3-found4+2, "signal");
				found4 = buffer.find(",");
				if (found4 != string::npos)
					buffer.erase(found4, 1);
				found3 = buffer.find("--");
				if (found3 != string::npos)
					buffer.erase(found3, 2);
				found4 = buffer.find("std_logic");
				if (found4 != string::npos)
					buffer.erase(found3+2, found4 - (found3+2));
				found3 = buffer.find(";");
				if (found3 == string::npos)
					buffer.insert(buffer.length()-1, ";");
				signals += buffer;
			}
			found2 = found1;
		}
	} while (found1 != string::npos);

	//signals section  [PKAM_4]
	found1 = signals.find("s_clk");
	if (found1 == string::npos)
		signals.insert(0, "	signal s_clk			: std_logic;\n");
	found1 = signals.find("s_rst");
	if (found1 == string::npos)
		signals.insert(0, "	signal s_rst			: std_logic;\n\n");

	//add to process section [PKAM_12]
	process =  "IN_OUT_REGS: process(s_clk)\n";
	process += "begin\n";
	process += "	if(rising_edge(s_clk)) then\n";

	//add signals to process section [PKAM_13]
	found2 = 0;
	do {
		found1 = atmp.find("\n", found2+1);
		if (found1 != string::npos) {
			buffer = atmp.substr (found2+1, found1-found2);//get new line
			//skip lines with clk and rst
			found3 = buffer.find("clk");
			found4 = buffer.find("rst");
			if (found3 == string::npos && found4 == string::npos) {
				found3 = buffer.find("=>");
				if (found3 != string::npos) {
					buffer.replace(found3, 2, "<=");
					found4 = buffer.find("s", found3);
					found3 = buffer.find(",", found4);
					if (found3 != string::npos)
						buffer.replace(found3, string::npos, ";\n");
					else {
						found3 = buffer.find("\t", found4);
						if (found3 != string::npos)
							buffer.replace(found3, string::npos, ";\n");
						else {
							found3 = buffer.find(" ", found4);
							if (found3 != string::npos)
								buffer.replace(found3, string::npos, ";\n");
						}
					}

					//reverse direction of connection if necessary
					/*
					found3 = buffer.find("pi");
					found4 = buffer.find("si");
					if (found3 != string::npos && found4 != string::npos)
						if (found3 < found4) {
							buffer.replace(found3, 1, "s");
							buffer.replace(found4, 1, "p");
						}
					*/
					found3 = buffer.find("<=");
					found4 = buffer.find("si_", found3);
					if (found4 != string::npos) {//change the order
						tmp = buffer.substr (found4, buffer.find(";")-found4);
						found3 = buffer.find_first_not_of(" \t");
						found5 = buffer.find_first_of (" \t<=", found3+1);
						aatmp = buffer.substr (found3, found5-found3);
						buffer.replace (found3, found5-found3, tmp);

						found3 = buffer.find("<=");
						found4 = buffer.find_first_not_of(" \t", found3+2);
						found5 = buffer.find(";", found4);
						buffer.replace (found4, found5-found4, aatmp);
					}

					//add line to process
					process += buffer;
				}
			}
			found2 = found1;
		}
	} while (found1 != string::npos);

	//remove tmp.txt file
	//tmp  = RMCOM;
	//tmp += " ";
    //tmp += this_prog_path;
	//tmp += TMPFILENAME;
	//system(tmp.c_str());

	//add to process section [PKAM_14]
	process += "			end if;\n";
	process += "		end process;\n";

	//create output file [PKAM_15]
	/*
	file_out_name = file_in_name;
	found1 = file_out_name.find(".vhd");
	if (found1 != string::npos)
		file_out_name.insert(found1, "_wrapper");
	else
		file_out_name += "_wrapper";
	*/
	tmp = header;
	tmp += signals;
	tmp += "begin\n";
	tmp += entities;
	tmp += process;
	tmp += "end architecture;\n";

	file_out_stream.open (file_out_name.c_str());
	file_out_stream << tmp;
	file_out_stream.close();

	//cout << tmp << endl << endl;
	return 0;
}
