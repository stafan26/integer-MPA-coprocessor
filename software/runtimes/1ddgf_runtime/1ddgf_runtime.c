/*
 ============================================================================
 Name        : 1ddgf_test.c
 Author      :
 Version     :
 Copyright   :
 Description : Test of 1d dgf formula
 ============================================================================
 */
#include "1ddgf.h"

//#define FDTD_E_TEST
//#define FDTD_H_TEST
//#define DGF_E_TEST_CFLF1
//#define DGF_H_TEST_CFLF1
//#define DGFJG_E_TEST
//#define DGFJG_H_TEST
//#define DGFZ_E_TEST
//#define FDTD_SINE_TEST
//#define DGFJG_SINE_TEST
#define SRUP_EVAL

#define N_ARG	4
#define K_ARG	1

#define COURANTN	0.9

#define PRECMPF	4096

#define SAVEOUT

int main(void) {
//============================================================================
#ifdef FDTD_E_TEST

uint_t t;//time index
uint_t k;//spatial index
uint_t Nsteps=1000;//number of steps
uint_t Nz=10000;//number of cells
uint_t Meask=10;//measurement point

float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps
float_t CFLF=COURANTN;

float_t dt_mu, dt_eps;
float_t dt_mu_dz, dt_eps_dz;
float_t *e_field, *h_field;

clock_t	start, stop;//time measurement
float_t	runtime, throughput;

#ifdef SAVEOUT
float_t tmpval;
FILE *e_fptr, *h_fptr;
#endif

	dt=CFLF*dz/c_const;
	e_field=(float_t*) calloc (Nz,sizeof(float_t));
	h_field=(float_t*) calloc (Nz,sizeof(float_t));
	dt_mu=dt/mu0_const;
	dt_eps=dt/eps0_const;
	dt_mu_dz=dt_mu/dz;
	dt_eps_dz=dt_eps/dz;

#ifdef SAVEOUT
	if( (e_fptr=fopen("e_jdelta_trans.bin","wb"))==NULL) {
		puts("Cannot open e_jdelta_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_jdelta_trans.bin","wb"))==NULL) {
		puts("Cannot open h_jdelta_trans.bin file");
		exit(1);
	}
#endif

	//1d FDTD simulation
	start=clock();//start timer
	for(t=0; t<Nsteps; t++) {

		//E update
		for(k=1; k<Nz-1; k++) {
			e_field[k]-=dt_eps_dz*(h_field[k]-h_field[k-1]);
		}

		//add excitation
		if(t==1)
			e_field[Nz/2]=-dt_eps;

		//H update
		for(k=1; k<Nz-1; k++) {
			h_field[k]-=dt_mu_dz*(e_field[k+1]-e_field[k]);
		}

		//data saving
#ifdef SAVEOUT
		tmpval=e_field[Nz/2+Meask];
		fwrite(&tmpval, sizeof(float_t), 1, e_fptr);
		tmpval=h_field[Nz/2+Meask];
		fwrite(&tmpval, sizeof(float_t), 1, h_fptr);
#endif

		fprintf(stdout,"Iteration: %d\r",t);
	}
	stop=clock();//stop timer

	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	throughput=Nz/runtime/1e6*Nsteps;
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
    printf("Throughput: %f Mcells/sec\n", throughput);
	printf("\n");

	free(e_field);
	free(h_field);
#ifdef SAVEOUT
	fclose(e_fptr);
	fclose(h_fptr);
#endif
	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef FDTD_H_TEST

uint_t t;//time index
uint_t k;//spatial index
uint_t Nsteps=1000;//number of steps
uint_t Nz=10000;//number of cells
uint_t Meask=10;//measurement point

float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps
float_t CFLF=COURANTN;

float_t dt_mu, dt_eps;
float_t dt_mu_dz, dt_eps_dz;
float_t *e_field, *h_field;

clock_t	start, stop;//time measurement
float_t	runtime, throughput;

#ifdef SAVEOUT
float_t tmpval;
FILE *e_fptr, *h_fptr;
#endif

	dt=CFLF*dz/c_const;
	e_field=(float_t*) calloc (Nz,sizeof(float_t));
	h_field=(float_t*) calloc (Nz,sizeof(float_t));
	dt_mu=dt/mu0_const;
	dt_eps=dt/eps0_const;
	dt_mu_dz=dt_mu/dz;
	dt_eps_dz=dt_eps/dz;

#ifdef SAVEOUT
	if( (e_fptr=fopen("e_mdelta_trans.bin","wb"))==NULL) {
		puts("Cannot open e_mdelta_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_mdelta_trans.bin","wb"))==NULL) {
		puts("Cannot open h_mdelta_trans.bin file");
		exit(1);
	}
#endif

	//1d FDTD simulation
	start=clock();//start timer
	for(t=0; t<Nsteps; t++) {

		//E update
		for(k=1; k<Nz-1; k++) {
			e_field[k]-=dt_eps_dz*(h_field[k]-h_field[k-1]);
		}

		//H update
		for(k=1; k<Nz-1; k++) {
			h_field[k]-=dt_mu_dz*(e_field[k+1]-e_field[k]);
		}

		//add excitation
		if(t==0)
			h_field[Nz/2]=-dt_mu;

		//data saving
#ifdef SAVEOUT
		tmpval=e_field[Nz/2+Meask];
		fwrite(&tmpval, sizeof(float_t), 1, e_fptr);
		tmpval=h_field[Nz/2+Meask];
		fwrite(&tmpval, sizeof(float_t), 1, h_fptr);
#endif

		fprintf(stdout,"Iteration: %d\r",t);
	}
	stop=clock();//stop timer

	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	throughput=Nz/runtime/1e6*Nsteps;
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
    printf("Throughput: %f Mcells/sec\n", throughput);
	printf("\n");

	free(e_field);
	free(h_field);
#ifdef SAVEOUT
	fclose(e_fptr);
	fclose(h_fptr);
#endif
	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef DGF_E_TEST_CFLF1

uint_t t;//time index
uint_t Nsteps=1000;//number of steps
uint_t Meask=10;//measurement point

float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps

float_t *e_field, *h_field;

clock_t	start, stop;//time measurement
float_t	runtime;

#ifdef SAVEOUT
FILE *e_fptr, *h_fptr;
#endif

	dt=dz/c_const;
	e_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	h_field=(float_t*) calloc (Nsteps,sizeof(float_t));

	//1d DGF-FDTD simulation
	start=clock();//start timer
	for(t=0; t<Nsteps; t++) {

		//E update
		e_field[t]=dgf_ee_cflf1(t, Meask, dt, dz);

		//H update
		h_field[t]=dgf_he_cflf1(t, Meask, dt, dz);

		fprintf(stdout,"Iteration: %d\r",t);
	}
	stop=clock();//stop timer

	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
	printf("\n");

	//data saving
#ifdef SAVEOUT
	if( (e_fptr=fopen("e_jdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open e_jdelta_dgf_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_jdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open h_jdelta_dgf_trans.bin file");
		exit(1);
	}

	fwrite(e_field, sizeof(float_t), Nsteps, e_fptr);
	fwrite(h_field, sizeof(float_t), Nsteps, h_fptr);

	fclose(e_fptr);
	fclose(h_fptr);
#endif
	free(e_field);
	free(h_field);

	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef DGF_H_TEST_CFLF1

uint_t t;//time index
uint_t Nsteps=1000;//number of steps
uint_t Meask=10;//measurement point

float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps

float_t *e_field, *h_field;

clock_t	start, stop;//time measurement
float_t	runtime;

#ifdef SAVEOUT
FILE *e_fptr, *h_fptr;
#endif

	dt=dz/c_const;
	e_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	h_field=(float_t*) calloc (Nsteps,sizeof(float_t));

	//1d DGF-FDTD simulation
	start=clock();//start timer
	for(t=0; t<Nsteps; t++) {

		//E update
		e_field[t]=dgf_eh_cflf1(t, Meask, dt, dz);

		//H update
		h_field[t]=dgf_hh_cflf1(t, Meask, dt, dz);

		fprintf(stdout,"Iteration: %d\r",t);
	}
	stop=clock();//stop timer

	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
	printf("\n");

	//data saving
#ifdef SAVEOUT
	if( (e_fptr=fopen("e_mdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open e_mdelta_dgf_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_mdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open h_mdelta_dgf_trans.bin file");
		exit(1);
	}

	fwrite(e_field, sizeof(float_t), Nsteps, e_fptr);
	fwrite(h_field, sizeof(float_t), Nsteps, h_fptr);

	fclose(e_fptr);
	fclose(h_fptr);
#endif
	free(e_field);
	free(h_field);

	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef DGFJG_E_TEST

uint_t t;//time index
uint_t Nsteps=1000;//number of steps
uint_t Meask=10;//measurement point

float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps

float_t *e_field, *ekp1_field, *h_field;
float_t *g_nk, *g_nkp1;

clock_t	start, stop;//time measurement
float_t	runtime;

#ifdef SAVEOUT
FILE *e_fptr, *h_fptr;
#endif

	dt= COURANTN * dz/c_const;
	e_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	ekp1_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	h_field=(float_t*) calloc (Nsteps,sizeof(float_t));

	g_nk=(float_t*) calloc (Nsteps,sizeof(float_t));
	g_nkp1=(float_t*) calloc (Nsteps,sizeof(float_t));

	//1d DGF-FDTD simulation based on JG approach
	start=clock();//start timer
	dgfjg_ee(Nsteps-1, Meask, COURANTN, dt, e_field);
	dgfjg_ee(Nsteps-1, Meask+1, COURANTN, dt, ekp1_field);
	//g_nk & g_nkp1 generation
	g_nk[0]=-eps0_const/dt*e_field[0];
	g_nkp1[0]=-eps0_const/dt*ekp1_field[0];
	h_field[0]=dz*COURANTN*COURANTN*(g_nkp1[0]-g_nk[0]);
	for(t=1; t<Nsteps; t++) {
		g_nk[t]=-eps0_const/dt*e_field[t] + g_nk[t-1];
		g_nkp1[t]=-eps0_const/dt*ekp1_field[t] + g_nkp1[t-1];
		h_field[t]=dz*COURANTN*COURANTN*(g_nkp1[t]-g_nk[t]);
	}
	stop=clock();//stop timer

	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
	printf("\n");

	//data saving
#ifdef SAVEOUT
	if( (e_fptr=fopen("e_jdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open e_jdelta_dgf_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_jdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open h_jdelta_dgf_trans.bin file");
		exit(1);
	}

	fwrite(e_field, sizeof(float_t), Nsteps, e_fptr);
	fwrite(h_field, sizeof(float_t), Nsteps, h_fptr);

	fclose(e_fptr);
	fclose(h_fptr);
#endif
	free(e_field);
	free(ekp1_field);
	free(h_field);

	free(g_nk);
	free(g_nkp1);

	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef DGFJG_H_TEST

uint_t t;//time index
uint_t Nsteps=1000;//number of steps
uint_t Meask=10;//measurement point

float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps

float_t *e_field, *ek_field, *ekm1_field, *h_field;
float_t *g_nk, *g_nkm1;

clock_t	start, stop;//time measurement
float_t	runtime;

#ifdef SAVEOUT
FILE *e_fptr, *h_fptr;
#endif

	dt= COURANTN * dz/c_const;
	e_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	ek_field=(float_t*) calloc (Nsteps+1,sizeof(float_t));
	ekm1_field=(float_t*) calloc (Nsteps+1,sizeof(float_t));
	h_field=(float_t*) calloc (Nsteps,sizeof(float_t));

	g_nk=(float_t*) calloc (Nsteps,sizeof(float_t));
	g_nkm1=(float_t*) calloc (Nsteps,sizeof(float_t));

	//1d DGF-FDTD simulation based on JG approach
	start=clock();//start timer
	dgfjg_ee(Nsteps, Meask, COURANTN, dt, ek_field);
	dgfjg_ee(Nsteps, Meask-1, COURANTN, dt, ekm1_field);
	//g_nk & g_nkp1 generation
	g_nk[0]=-eps0_const/dt*ek_field[0];
	g_nkm1[0]=-eps0_const/dt*ekm1_field[0];
	for(t=1; t<(Nsteps+1); t++) {
		g_nk[t]=-eps0_const/dt*ek_field[t] + g_nk[t-1];
		g_nkm1[t]=-eps0_const/dt*ekm1_field[t] + g_nkm1[t-1];
	}
	for(t=0; t<Nsteps; t++) {
		e_field[t]=dz*COURANTN*COURANTN*(g_nk[t]-g_nkm1[t]);
		h_field[t]=-dt/mu0_const*(g_nk[t+1]-g_nk[t]);
	}
	stop=clock();//stop timer

	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
	printf("\n");

	//data saving
#ifdef SAVEOUT
	if( (e_fptr=fopen("e_mdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open e_mdelta_dgf_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_mdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open h_mdelta_dgf_trans.bin file");
		exit(1);
	}

	fwrite(e_field, sizeof(float_t), Nsteps, e_fptr);
	fwrite(h_field, sizeof(float_t), Nsteps, h_fptr);

	fclose(e_fptr);
	fclose(h_fptr);
#endif
	free(e_field);
	free(ek_field);
	free(ekm1_field);
	free(h_field);

	free(g_nk);
	free(g_nkm1);

	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef DGFZ_E_TEST

uint_t t;//time index
uint_t Nsteps=1000;//number of steps
uint_t Meask=10;//measurement point

float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps

float_t *e_field, *h_field;

clock_t	start, stop;//time measurement
float_t	runtime;

#ifdef SAVEOUT
FILE *e_fptr, *h_fptr;
#endif

	mpf_set_default_prec (PRECMPF);

	dt = COURANTN * dz/c_const;
	e_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	h_field=(float_t*) calloc (Nsteps,sizeof(float_t));

	//1d DGF-FDTD simulation
	start=clock();//start timer
	for(t=0; t<Nsteps; t++) {

		//E update
		e_field[t]=dgf_ee_z(t, Meask, dt, dz);

		//H update
		h_field[t]=dgf_he_z(t, Meask, dt, dz);

		fprintf(stdout,"Iteration: %d\r",t);
	}
	stop=clock();//stop timer

	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
	printf("\n");

	//data saving
#ifdef SAVEOUT
	if( (e_fptr=fopen("e_jdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open e_jdelta_dgf_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_jdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open h_jdelta_dgf_trans.bin file");
		exit(1);
	}

	fwrite(e_field, sizeof(float_t), Nsteps, e_fptr);
	fwrite(h_field, sizeof(float_t), Nsteps, h_fptr);

	fclose(e_fptr);
	fclose(h_fptr);
#endif
	free(e_field);
	free(h_field);

	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef FDTD_SINE_TEST

uint_t t;//time index
uint_t k;//spatial index
uint_t Nsteps=1000;//number of steps
uint_t Nz=10000;//number of cells
uint_t Meask=10;//measurement point

float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps
float_t CFLF=COURANTN;

float_t dt_mu, dt_eps;
float_t dt_mu_dz, dt_eps_dz;
float_t *e_field, *h_field;

clock_t	start, stop;//time measurement
float_t	runtime, throughput;

float_t simtime;
float_t excitation;
float_t frequency=3.175e9;
float_t omega=((float_t)(2*pi_const*frequency));
float_t ramp=((float_t)(2.0/frequency));

#ifdef SAVEOUT
float_t tmpval;
FILE *e_fptr, *h_fptr;
#endif

	dt=CFLF*dz/c_const;
	e_field=(float_t*) calloc (Nz,sizeof(float_t));
	h_field=(float_t*) calloc (Nz,sizeof(float_t));
	dt_mu=dt/mu0_const;
	dt_eps=dt/eps0_const;
	dt_mu_dz=dt_mu/dz;
	dt_eps_dz=dt_eps/dz;

#ifdef SAVEOUT
	if( (e_fptr=fopen("e_jdelta_trans.bin","wb"))==NULL) {
		puts("Cannot open e_jdelta_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_jdelta_trans.bin","wb"))==NULL) {
		puts("Cannot open h_jdelta_trans.bin file");
		exit(1);
	}
#endif

	//1d FDTD simulation
	start=clock();//start timer
	for(t=0; t<Nsteps; t++) {
		simtime = t*dt;

		//E update
		for(k=1; k<Nz-1; k++) {
			e_field[k]-=dt_eps_dz*(h_field[k]-h_field[k-1]);
		}

		//add excitation
		if (simtime<ramp) {
			excitation = ((float_t)(0.5
				*sin(omega*simtime)
				*(1.0-cos(simtime*pi_const/ramp))));
		} else {
			excitation = ((float_t)(sin(omega*simtime)));
		}
		if(t!=0)
			e_field[Nz/2]+=-dt_eps * excitation;
			//e_field[Nz/2]=- excitation;

		//H update
		for(k=1; k<Nz-1; k++) {
			h_field[k]-=dt_mu_dz*(e_field[k+1]-e_field[k]);
		}

		//data saving
#ifdef SAVEOUT
		tmpval=e_field[Nz/2+Meask];
		fwrite(&tmpval, sizeof(float_t), 1, e_fptr);
		tmpval=h_field[Nz/2+Meask];
		fwrite(&tmpval, sizeof(float_t), 1, h_fptr);
#endif

		fprintf(stdout,"Iteration: %d\r",t);
	}
	stop=clock();//stop timer

	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	throughput=Nz/runtime/1e6*Nsteps;
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
    printf("Throughput: %f Mcells/sec\n", throughput);
	printf("\n");

	free(e_field);
	free(h_field);
#ifdef SAVEOUT
	fclose(e_fptr);
	fclose(h_fptr);
#endif
	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef DGFJG_SINE_TEST

uint_t t;//time index
uint_t Nsteps=1000;//number of steps
uint_t Meask=10;//measurement point

float_t simtime;
float_t dt;//time-step size
float_t dz=(float_t)0.001;//spatial steps
//float_t dt_eps;

float_t *e_field, *ekp1_field, *h_field;
float_t *e_out_field, *h_out_field;
float_t *g_nk, *g_nkp1;
float_t *excitation;

clock_t	start, stop;//time measurement
float_t	runtime;

float_t frequency=3.175e9;
float_t omega=((float_t)(2*pi_const*frequency));
float_t ramp=((float_t)(2.0/frequency));

#ifdef SAVEOUT
FILE *e_fptr, *h_fptr;
#endif

	dt= COURANTN * dz/c_const;
	//dt_eps=dt/eps0_const;
	e_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	ekp1_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	h_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	e_out_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	h_out_field=(float_t*) calloc (Nsteps,sizeof(float_t));
	excitation=(float_t*) calloc (Nsteps,sizeof(float_t));

	g_nk=(float_t*) calloc (Nsteps,sizeof(float_t));
	g_nkp1=(float_t*) calloc (Nsteps,sizeof(float_t));

	//1d DGF-FDTD simulation based on JG approach
	start=clock();//start timer
	dgfjg_ee(Nsteps-1, Meask, COURANTN, dt, e_field);
	dgfjg_ee(Nsteps-1, Meask+1, COURANTN, dt, ekp1_field);
	//g_nk & g_nkp1 generation
	g_nk[0]=-eps0_const/dt*e_field[0];
	g_nkp1[0]=-eps0_const/dt*ekp1_field[0];
	h_field[0]=dz*COURANTN*COURANTN*(g_nkp1[0]-g_nk[0]);
	for(t=1; t<Nsteps; t++) {
		g_nk[t]=-eps0_const/dt*e_field[t] + g_nk[t-1];
		g_nkp1[t]=-eps0_const/dt*ekp1_field[t] + g_nkp1[t-1];
		h_field[t]=dz*COURANTN*COURANTN*(g_nkp1[t]-g_nk[t]);
	}
	stop=clock();//stop timer

	//generate excitation
	for(t=1; t<Nsteps; t++) {
		simtime = t*dt;
		if (simtime<ramp) {
			excitation[t] = ((float_t)(0.5
				*sin(omega*simtime)
				*(1.0-cos(simtime*pi_const/ramp))));
		} else {
			excitation[t] = ((float_t)(sin(omega*simtime)));
		}
	}

	DgfCpuConvolutionOffline(	e_out_field, Nsteps,
										e_field, Nsteps,
										excitation, Nsteps,
										1,
										1,
										Meask+1);

	DgfCpuConvolutionOffline(	h_out_field, Nsteps,
										h_field, Nsteps,
										excitation, Nsteps,
										1,
										1,
										Meask+1);


	runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC));
	printf("\n");
    printf("Runtime: %f sec\n", runtime);
	printf("\n");

	//data saving
#ifdef SAVEOUT
	if( (e_fptr=fopen("e_jdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open e_jdelta_dgf_trans.bin file");
		exit(1);
	}
	if( (h_fptr=fopen("h_jdelta_dgf_trans.bin","wb"))==NULL) {
		puts("Cannot open h_jdelta_dgf_trans.bin file");
		exit(1);
	}

	fwrite(e_out_field, sizeof(float_t), Nsteps, e_fptr);
	fwrite(h_out_field, sizeof(float_t), Nsteps, h_fptr);

	fclose(e_fptr);
	fclose(h_fptr);
#endif
	free(e_field);
	free(ekp1_field);
	free(h_field);
	free(e_out_field);
	free(h_out_field);
	free(excitation);

	free(g_nk);
	free(g_nkp1);

	puts("Finito!");
	//puts("Press any key...");
	//getchar();
	return 0;
#endif
//============================================================================
#ifdef SRUP_EVAL

/** Speed test parameters **/
#define REPF	10
#define N_MIN	100
#define N_MAX	2000
#define N_STEP	100

uint_t i, j, p;
uint_t n, k;
mpz_t result;
mpz_t *tab1, *tab2;

clock_t	start, stop;//time measurement
float_t	runtime;

	//k must be less than N_MIN
	k = 99;

	printf("//============================================================================\n");
	printf("Argument\t\tAverage Runtime (sec)\n");
	for(n=N_MIN; n<=N_MAX; n+=N_STEP) {
		mpz_init (result);
		j=n-k;
		tab1=malloc(j*sizeof(mpz_t));
		tab2=malloc(j*sizeof(mpz_t));
		for(i=0; i<j; i++) {
			mpz_init (tab1[i]);
			mpz_init (tab2[i]);
		}

		table_gen_cflf1_mpamem(n, k, tab1, tab2);

		start=clock();//start timer

		for(p=0; p<REPF; p++) {
			scalar_dgf_cflf1_mpamem(n, k, tab1, tab2, result);
			printf(".");
			gmp_printf ("%Zd\n", result);
		}
		stop=clock();//stop timer
	    //printf("\n");
		runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC))/((float_t)(REPF));
		printf("%d\t\t\t%f\n", n, runtime);

		//test last result
		if ((n+k)%2 == 0) {//even
			if ( mpz_get_ui (result) != 0) {
				fprintf(stderr, "Error in code 1\n");
				exit(1);
			}
		} else if ((n+k)%2 == 1) {//odd
			if ( mpz_get_ui (result) != 1) {
				fprintf(stderr, "Error in code 2\n");
				exit(1);
			}
		} else {//:-)
			fprintf(stderr, "Error in code 3\n");
			exit(1);
		}

		mpz_clear (result);
		for(i=0; i<j; i++) {
			mpz_clear (tab1[i]);
			mpz_clear (tab2[i]);
		}
	}
	printf("//============================================================================\n");
	free(tab1);
	free(tab2);
	return 0;
#endif
//============================================================================
}
