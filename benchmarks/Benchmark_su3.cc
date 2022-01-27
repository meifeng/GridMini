/*************************************************************************************

    Grid physics library, www.github.com/paboyle/Grid 

    Source file: ./benchmarks/Benchmark_su3.cc

    Copyright (C) 2015

Author: Peter Boyle <paboyle@ph.ed.ac.uk>
Author: Peter Boyle <peterboyle@Peters-MacBook-Pro-2.local>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

    See the full license in the file "LICENSE" in the top level distribution directory
    *************************************************************************************/
    /*  END LEGAL */
#include <Grid/GridCore.h>
#include <Grid/GridStd.h>
using namespace std;
using namespace Grid;


#define TILE_SZ 4

#define UNROLL_FACTOR 2

#define TILE
#define UNROLL
//#define OMP_TILE
//#define OMP_UNROLL
int main (int argc, char ** argv)
{
  Grid_init(&argc,&argv);

#define LMAX (64)
#define LMIN (4)
#define LADD (4)
  int64_t Nwarm=50;
  int64_t Nloop=1000;
 
  Coordinate simd_layout = GridDefaultSimd(Nd,vComplex::Nsimd());
  std::cout<<GridLogMessage << "Grid simd_layout" << simd_layout << std::endl;
  Coordinate mpi_layout  = GridDefaultMpi();

  int64_t threads = GridThread::GetThreads();
  std::cout<<GridLogMessage << "Grid is setup to use "<<threads<<" threads"<<std::endl;
  std::cout<<GridLogMessage << "Grid is setup to use "<<Nd<<" dimensions"<<std::endl;

#if 0
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "= Benchmarking SU3xSU3  x= x*y"<<std::endl;
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "  L  "<<"\t\t"<<"bytes"<<"\t\t\t"<<"GB/s\t\t GFlop/s"<<std::endl;
  std::cout<<GridLogMessage << "----------------------------------------------------------"<<std::endl;

  for(int lat=LMIN;lat<=LMAX;lat+=LADD){

      Coordinate latt_size  ({lat*mpi_layout[0],lat*mpi_layout[1],lat*mpi_layout[2],lat*mpi_layout[3]});
      int64_t vol = latt_size[0]*latt_size[1]*latt_size[2]*latt_size[3];
      GridCartesian     Grid(latt_size,simd_layout,mpi_layout);
      GridParallelRNG          pRNG(&Grid);      pRNG.SeedFixedIntegers(std::vector<int>({45,12,81,9}));

      LatticeColourMatrix z(&Grid); random(pRNG,z);
      LatticeColourMatrix x(&Grid); random(pRNG,x);
      LatticeColourMatrix y(&Grid); random(pRNG,y);

      for(int64_t i=0;i<Nwarm;i++){
	x=x*y;
      }
      double start=usecond();
      for(int64_t i=0;i<Nloop;i++){
	x=x*y;
      }
      double stop=usecond();
      double time = (stop-start)/Nloop*1000.0;
      std::cout<<"time: "<<time<<std::endl; 
      double bytes=3.0*vol*Nc*Nc*sizeof(Complex);
      double footprint=2.0*vol*Nc*Nc*sizeof(Complex);
      double flops=Nc*Nc*(6.0+8.0+8.0)*vol;
      std::cout<<GridLogMessage<<std::setprecision(3) << lat<<"\t\t"<<footprint<<"    \t\t"<<bytes/time<<"\t\t" << flops/time<<std::endl;

    }

#endif

  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "= Benchmarking SU3xSU3  z= x*y"<<std::endl;
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "  L  "<<"\t\t"<<"bytes"<<"\t\t\t"<<"GB/s\t\t GFlop/s"<<std::endl;
  std::cout<<GridLogMessage << "----------------------------------------------------------"<<std::endl;

#ifndef DEBUG
//#define DEBUG
#endif

  for(int lat=LMIN;lat<=LMAX;lat+=LADD){

      Coordinate latt_size  ({lat*mpi_layout[0],lat*mpi_layout[1],lat*mpi_layout[2],lat*mpi_layout[3]});
      int64_t vol = latt_size[0]*latt_size[1]*latt_size[2]*latt_size[3];

      GridCartesian     Grid(latt_size,simd_layout,mpi_layout);
      GridParallelRNG          pRNG(&Grid);      pRNG.SeedFixedIntegers(std::vector<int>({45,12,81,9}));

      LatticeColourMatrix z(&Grid); random(pRNG,z);
      LatticeColourMatrix x(&Grid); random(pRNG,x);
      LatticeColourMatrix y(&Grid); random(pRNG,y);

#ifdef DEBUG
      LatticeColourMatrix zref(&Grid); 
      auto xv=x.View();
      auto yv=y.View();
      auto zv=z.View();
      auto zref_v=zref.View();
      
      std::cout<<"DEBUG mode...."<<std::endl;
     
      //CPU calculation
      printf("=====Beginning reference CPU calculations=====\n");
      for(int64_t s=0;s<vol;s++) {
        zref_v[s]=xv[s]*yv[s];
      }
      
      printf("=====End reference CPU calculations=====\n");
     
      
      printf("=====Beginning GPU calculations=====\n");
      //expression template calculation if enabled
      double start=usecond();

      for(int64_t i=0;i<Nloop;i++){
      #pragma omp target teams distribute parallel for

	      
#ifdef UNROLL
	 for(int64_t s=0;s<vol;s+=UNROLL_FACTOR) { 
		 zv[s]=xv[s]*yv[s];
		 zv[s+1]=xv[s+1]*yv[s+1];
	 }
#endif
#ifdef OMP_UNROLL
	  #pragma omp unroll (UNROLL_FACTOR)
	 for(int64_t s=0;s<vol;s++)
		 zv[s]=xv[s]*yv[s];
#endif


#ifdef TILE
	 for(int64_t s=0;s<vol;s+=TILE_SZ) {
          for (int64_t t = s; t< min(s+TILE_SZ, vol); t++)
             zv[t]=xv[t]*yv[t];
	 }
#endif
	      
#ifdef OMP_TILE
	  #pragma omp tile sizes(TILE_SZ)
	 for(int64_t s=0;s<vol;s++)
		 zv[s]=xv[s]*yv[s];
#endif
        }
      }

      double stop=usecond();
      double time = (stop-start)/Nloop*1000.0;

      double bytes=3*vol*Nc*Nc*sizeof(Complex);
      double flops=Nc*Nc*(6+8+8)*vol;
      std::cout<<GridLogMessage<<std::setprecision(3) << lat<<"\t\t"<<bytes<<"    \t\t"<<bytes/time<<"\t\t" << flops/time<<std::endl;

      printf("=====End GPU calculations=====\n");
     //LatticeReal diff(&Grid);
     //auto dv=diff.View();
     for(int64_t s=0;s<1;s++){
       //dv[s]=zv[s]-zref_v[s];
       std::cout<<"s="<<s<<" x[]="<<xv[s]<<std::endl;
       std::cout<<"s="<<s<<" y[]="<<yv[s]<<std::endl;
       std::cout<<"GOT: s="<<s<<" z[]="<<zv[s]<<std::endl;
       std::cout<<"EXPECTED: s="<<s<<"zref[]="<<zref_v[s]<<std::endl;

     }

#else

      for(int64_t i=0;i<Nwarm;i++){
	z=x*y;
      }


      double start=usecond();
      for(int64_t i=0;i<Nloop;i++){
	z=x*y;
      }
      double stop=usecond();
      double time = (stop-start)/Nloop*1000.0;
      
      double bytes=3*vol*Nc*Nc*sizeof(Complex);
      double flops=Nc*Nc*(6+8+8)*vol;
      std::cout<<GridLogMessage<<std::setprecision(3) << lat<<"\t\t"<<bytes<<"    \t\t"<<bytes/time<<"\t\t" << flops/time<<std::endl;
#endif
    }

#if 0
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "= Benchmarking SU3xSU3  mult(z,x,y)"<<std::endl;
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "  L  "<<"\t\t"<<"bytes"<<"\t\t\t"<<"GB/s\t\t GFlop/s"<<std::endl;
  std::cout<<GridLogMessage << "----------------------------------------------------------"<<std::endl;


  for(int lat=LMIN;lat<=LMAX;lat+=LADD){

      Coordinate latt_size  ({lat*mpi_layout[0],lat*mpi_layout[1],lat*mpi_layout[2],lat*mpi_layout[3]});
      int64_t vol = latt_size[0]*latt_size[1]*latt_size[2]*latt_size[3];

      GridCartesian     Grid(latt_size,simd_layout,mpi_layout);
      GridParallelRNG          pRNG(&Grid);      pRNG.SeedFixedIntegers(std::vector<int>({45,12,81,9}));

      LatticeColourMatrix z(&Grid); random(pRNG,z);
      LatticeColourMatrix x(&Grid); random(pRNG,x);
      LatticeColourMatrix y(&Grid); random(pRNG,y);

      for(int64_t i=0;i<Nwarm;i++){
	mult(z,x,y);
      }
      double start=usecond();
      for(int64_t i=0;i<Nloop;i++){
	mult(z,x,y);
	//	mac(z,x,y);
      }
      double stop=usecond();
      double time = (stop-start)/Nloop*1000.0;
      
      double bytes=3*vol*Nc*Nc*sizeof(Complex);
      double flops=Nc*Nc*(6+8+8)*vol;
      std::cout<<GridLogMessage<<std::setprecision(3) << lat<<"\t\t"<<bytes<<"    \t\t"<<bytes/time<<"\t\t" << flops/time<<std::endl;

    }

  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "= Benchmarking SU3xSU3  mac(z,x,y)"<<std::endl;
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "  L  "<<"\t\t"<<"bytes"<<"\t\t\t"<<"GB/s\t\t GFlop/s"<<std::endl;
  std::cout<<GridLogMessage << "----------------------------------------------------------"<<std::endl;

  for(int lat=LMIN;lat<=LMAX;lat+=LADD){

      Coordinate latt_size  ({lat*mpi_layout[0],lat*mpi_layout[1],lat*mpi_layout[2],lat*mpi_layout[3]});
      int64_t vol = latt_size[0]*latt_size[1]*latt_size[2]*latt_size[3];

      GridCartesian     Grid(latt_size,simd_layout,mpi_layout);
      GridParallelRNG          pRNG(&Grid);      pRNG.SeedFixedIntegers(std::vector<int>({45,12,81,9}));

      LatticeColourMatrix z(&Grid); random(pRNG,z);
      LatticeColourMatrix x(&Grid); random(pRNG,x);
      LatticeColourMatrix y(&Grid); random(pRNG,y);

      for(int64_t i=0;i<Nwarm;i++){
	mac(z,x,y);
      }
      double start=usecond();
      for(int64_t i=0;i<Nloop;i++){
	mac(z,x,y);
      }
      double stop=usecond();
      double time = (stop-start)/Nloop*1000.0;
      
      double bytes=4*vol*Nc*Nc*sizeof(Complex);
      double flops=Nc*Nc*(8+8+8)*vol;
      std::cout<<GridLogMessage<<std::setprecision(3) << lat<<"\t\t"<<bytes<<"   \t\t"<<bytes/time<<"\t\t" << flops/time<<std::endl;

    }

#endif 

#if 0
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "= Benchmarking SU3xSU3  CovShiftForward(z,x,y)"<<std::endl;
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "  L  "<<"\t\t"<<"bytes"<<"\t\t\t"<<"GB/s\t\t GFlop/s"<<std::endl;
  std::cout<<GridLogMessage << "----------------------------------------------------------"<<std::endl;

  for(int lat=LMIN;lat<=LMAX;lat+=LADD){

      std::vector<int> latt_size  ({lat*mpi_layout[0],lat*mpi_layout[1],lat*mpi_layout[2],lat*mpi_layout[3]});
      int64_t vol = latt_size[0]*latt_size[1]*latt_size[2]*latt_size[3];

      GridCartesian     Grid(latt_size,simd_layout,mpi_layout);
      GridParallelRNG          pRNG(&Grid);      pRNG.SeedFixedIntegers(std::vector<int>({45,12,81,9}));

      LatticeColourMatrix z(&Grid); random(pRNG,z);
      LatticeColourMatrix x(&Grid); random(pRNG,x);
      LatticeColourMatrix y(&Grid); random(pRNG,y);

      for(int mu=0;mu<4;mu++){
	      double start=usecond();
	      for(int64_t i=0;i<Nloop;i++){
	        z = PeriodicBC::CovShiftForward(x,mu,y);
	    }
	    double stop=usecond();
	    double time = (stop-start)/Nloop*1000.0;
	
	
	    double bytes=3*vol*Nc*Nc*sizeof(Complex);
	    double flops=Nc*Nc*(6+8+8)*vol;
	    std::cout<<GridLogMessage<<std::setprecision(3) << lat<<"\t\t"<<bytes<<"   \t\t"<<bytes/time<<"\t\t" << flops/time<<std::endl;
      }
  }

#endif
#if 0
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "= Benchmarking SU3xSU3  z= x * Cshift(y)"<<std::endl;
  std::cout<<GridLogMessage << "===================================================================================================="<<std::endl;
  std::cout<<GridLogMessage << "  L  "<<"\t\t"<<"bytes"<<"\t\t\t"<<"GB/s\t\t GFlop/s"<<std::endl;
  std::cout<<GridLogMessage << "----------------------------------------------------------"<<std::endl;

  for(int lat=LMIN;lat<=LMAX;lat+=LADD){
      std::vector<int> latt_size  ({lat*mpi_layout[0],lat*mpi_layout[1],lat*mpi_layout[2],lat*mpi_layout[3]});
      int64_t vol = latt_size[0]*latt_size[1]*latt_size[2]*latt_size[3];

      GridCartesian     Grid(latt_size,simd_layout,mpi_layout);
      GridParallelRNG          pRNG(&Grid);      pRNG.SeedFixedIntegers(std::vector<int>({45,12,81,9}));

      LatticeColourMatrix z(&Grid); random(pRNG,z);
      LatticeColourMatrix x(&Grid); random(pRNG,x);
      LatticeColourMatrix y(&Grid); random(pRNG,y);
      LatticeColourMatrix tmp(&Grid);

      for(int mu=0;mu<4;mu++){
	double tshift=0;
	double tmult =0;

	double start=usecond();
	for(int64_t i=0;i<Nloop;i++){
	  tshift-=usecond();
	  tmp = Cshift(y,mu,-1);
	  tshift+=usecond();
	  tmult-=usecond();
	  z   = x*tmp;
	  tmult+=usecond();
	}
	double stop=usecond();
	double time = (stop-start)/Nloop;
	tshift = tshift/Nloop;
	tmult  = tmult /Nloop;
	
	double bytes=3*vol*Nc*Nc*sizeof(Complex);
	double flops=Nc*Nc*(6+8+8)*vol;
	std::cout<<GridLogMessage<<std::setprecision(3) << "total us "<<time<<" shift "<<tshift <<" mult "<<tmult<<std::endl;
	time = time * 1000; // convert to NS for GB/s
	std::cout<<GridLogMessage<<std::setprecision(3) << lat<<"\t\t"<<bytes<<"   \t\t"<<bytes/time<<"\t\t" << flops/time<<std::endl;
      }
    }
#endif
  Grid_finalize();
}
