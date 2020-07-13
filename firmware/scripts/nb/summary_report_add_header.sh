#!/bin/bash
#script attaches header to file

HEADER_DATA="    WNS(ns)      TNS(ns)  TNS Failing Endpoints  TNS Total Endpoints      WHS(ns)      THS(ns)  THS Failing Endpoints  THS Total Endpoints     WPWS(ns)     TPWS(ns)  TPWS Failing Endpoints  TPWS Total Endpoints   Project"
LINE_DATA="----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
printf "%s\n" "$HEADER_DATA" > $1
printf "%s\n" "$LINE_DATA" >> $1
