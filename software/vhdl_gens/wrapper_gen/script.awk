# http://ideone.com/WVJ6YS

BEGIN {
	F_PROCESS_DATA=0;
	SECTION_GENERIC=0;
	SECTION_PORT=0;
	GENERIC_CNT=0;
	PORT_CNT=0;
}


{
	if( match($0, "entity .* is") > 0 ) {
		F_PROCESS_DATA=1;
		MODULE_NAME=$2;

	} else if( match($0, "end.*;") > 0 ) {
		F_PROCESS_DATA=0;
	}

	if(F_PROCESS_DATA == 1) {
		if( match($0, "generic") > 0 && match($0, "\\(") > 0) {
			SECTION_GENERIC = 1;
			SECTION_PORT = 0;
		}
		if( match($0, "port") > 0 && match($0, "\\(") > 0 ) {
			SECTION_GENERIC = 0;
			SECTION_PORT = 1;
		}

		if(SECTION_GENERIC == 1) {
			if(length($0) > 10) {
				LIST_G_NAME[GENERIC_CNT]=$1;
				for(i=2;i<=NF;++i) LIST_G_TYPE[GENERIC_CNT]=LIST_G_TYPE[GENERIC_CNT]$i" ";
				GENERIC_CNT+=1;
			}
		} else if(SECTION_PORT == 1) {
			if(length($0) > 10) {
				LIST_P_NAME[PORT_CNT]=$1;
				LIST_P_DIR[PORT_CNT]=$3;
				for(i=2;i<=NF;++i) LIST_P_TYPE[PORT_CNT]=LIST_P_TYPE[PORT_CNT]$i" ";
				PORT_CNT+=1;
			}
		}


		#print MODULE_NAME"_"F_PROCESS_DATA"_"SECTION_GENERIC"_"SECTION_PORT": "$0;
	}

}



END {
		if(GENERIC_CNT > 0) {
			print "	"toupper(MODULE_NAME)"_INST: entity work."MODULE_NAME" generic map (";
			for(i=0; i<=GENERIC_CNT; i++) {
				if(length(LIST_G_NAME[i]) > 0) {
					print "		"LIST_G_NAME[i]"		=> "LIST_G_NAME[i]",		--"LIST_G_TYPE[i];
				}
			}
			if(PORT_CNT > 0) {
				print "	)";
				print "	port map ("
			} else {
				print ""	");";
			}
		} else {
			print "	"toupper(MODULE_NAME)"_INST: entity work."MODULE_NAME" port map (";
		}

		if(PORT_CNT > 0) {
			for(i=0; i<=PORT_CNT; i++) {
				if(length(LIST_P_NAME[i]) > 0) {
					if(substr(LIST_P_NAME[i],0,2) == "pi" || substr(LIST_P_NAME[i],0,2) == "po") {
						print "		"LIST_P_NAME[i]"		=> "LIST_P_NAME[i]",		--"LIST_P_TYPE[i];
					} else {
						if(LIST_P_DIR[i] == "in") {
							print "		"LIST_P_NAME[i]"		=> pi_"LIST_P_NAME[i]",		--"LIST_P_TYPE[i];
						} else {
							print "		"LIST_P_NAME[i]"		=> po_"LIST_P_NAME[i]",		--"LIST_P_TYPE[i];
						}
					}
				}
			}
			print "	);";
		}

}
