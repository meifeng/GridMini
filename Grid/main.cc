#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <iomanip>
#include <cassert>

#include <cstdlib>

//#include <ET.h>

#include "offload.h"
#include <vector>
#include <tuple>
#include "gsuN.h"
#include "allocator/AlignedAllocator.h"
#include "threads/Threads.h"
#include "communicator/Communicator.h"
#include "cartesian/Cartesian.h"
#include "lattice/Lattice.h"



#include <qcd/QCD.h>

//#define OLD

#ifndef GPU
#include <omp.h>
#endif

///////////////////// The Tests /////////////////////
using namespace Grid;
using namespace Grid::QCD;
              
typedef vColourMatrixF Su3f;
typedef vColourMatrixD Su3d;
#define GPU
template<class obj>
void	SetRandom(Lattice<obj> &x, const int vol)
{
  typedef typename obj::vector_type vType;
  typedef typename obj::scalar_type sType;
  typedef typename vType::conv_t    uType;

  constexpr int Nsimd = sizeof(vType)/sizeof(sType);
  constexpr int Nc    = sizeof(x._odata[0]._internal._internal._internal[0])/sizeof(vType);
#ifndef GPU
  const     int	maxThreads = omp_get_max_threads();
#else
  const     int	maxThreads = 1;
#endif

  int sd[maxThreads];

  std::random_device seed;		// Totally random seed coming from memory garbage

  for (int i=0; i<maxThreads; i++)
     sd[i] = seed();	//8746

#ifndef GPU
  #pragma omp parallel default(shared)
  {
    int nThread = omp_get_thread_num();
#else
  {
    int nThread = 0;
#endif

    std::mt19937_64 mt64(sd[nThread]);				// Mersenne-Twister 64 bits, independent per thread
    std::srand(sd[nThread]);				// Mersenne-Twister 64 bits, independent per thread
    std::uniform_real_distribution<float> uni(0.0, 1.0);	// So much for the templates...
#ifndef GPU
    #pragma omp for schedule(static)
#endif
    for (int i=0; i<vol; i++)
      for (int j=0; j<Nc; j++)
	for (int k=0; k<Nc; k++) {
	  uType conv;

	  for (int l=0; l<Nsimd; l++)
	    conv.s[l] = 2.0f*((float) std::rand())/((float) RAND_MAX) - 1.0f;//uni(mt64);

	  x._odata[i]._internal._internal._internal[j][k].v = conv.v;

	}
  }
}
#undef GPU

int main(int argc,char **argv) {

//  using namespace suN;
  constexpr int n = 3;
//  typedef SuN<vComplexF,n> SuNf;

  std::chrono::high_resolution_clock::time_point start, stop;

  int Nloop=100;

  std::cout << "===================================================================================================="<<std::endl;
  std::cout << "DISCLAIMER: THIS IS NOT Grid, but definitely looks like Grid" << std::endl;
  std::cout << "===================================================================================================="<<std::endl;

  std::cout << std::endl;
  std::cout << "===================================================================================================="<<std::endl;
  std::cout << "= Benchmarking SU(" << n << ")xSU(" << n << ")  z = x*y"<<std::endl;
  std::cout << "===================================================================================================="<<std::endl;
  std::cout << "  L  "<<"\t\t"<<"bytes"<<"\t\t\t"<<"GB/s\t\t GFlop/s"<<std::endl;
  std::cout << "----------------------------------------------------------"<<std::endl;

    for (int lat=32;lat>4;lat-=4) {

      int vol = lat*lat*lat*lat;

      /*  Now we use the full fledged GridCartesian instead of our stripped down class */

#ifdef	OLD
      GridBase grid(vol);
#else
      const std::vector<int> nDims(4,lat);
      std::vector<int> nSimd(4,1);

#ifndef	GRID_SIMD_WIDTH
	#if	defined(SSE4)
		#define	GRID_SIMD_WIDTH	16u
	#elif	defined(AVX1) || defined(AVX2)
		#define	GRID_SIMD_WIDTH	32u
	#elif	defined(AVX512)
		#define	GRID_SIMD_WIDTH	64u
	#elif	defined(GEN_SIMD_WIDTH)
		#define	GRID_SIMD_WIDTH	GEN_SIMD_WIDTH
	#else
		#error("No simd width defined")
	#endif
#endif

      int cWidth = GRID_SIMD_WIDTH/8;	// Assuming single precision
      int sLane  = 0;

      while (cWidth != 1) {
	nSimd[3-sLane] *= 2;
	sLane = ((sLane+1)%4);
	cWidth /= 2;
      }

      const std::vector<int> pGrid(4, 1);

      GridCartesian grid(nDims, nSimd, pGrid);
#endif
      Lattice<vColourMatrixF> z(&grid);
      Lattice<vColourMatrixF> x(&grid);
      Lattice<vColourMatrixF> y(&grid);

      SetRandom(x, grid.oSites());
      SetRandom(y, grid.oSites());

      z=x*y;	// Warm up

      #ifdef GPU
      cudaDeviceSynchronize();
      #endif
      start = std::chrono::high_resolution_clock::now();

      for (int i=0;i<Nloop;i++) {
	z=x*y;
      }
      #ifdef GPU
      cudaDeviceSynchronize();
      #endif
      stop = std::chrono::high_resolution_clock::now();

      double time = (std::chrono::duration_cast<std::chrono::microseconds>(stop - start).count())/Nloop*1000.0;
      
      double bytes	= 3.0*grid.oSites()*sizeof(vColourMatrixF);
      double footprint	= 2.0*grid.oSites()*sizeof(vColourMatrixF);
      double flops	= (8.0*n - 2.0)*n*n*vol;

      std::cout << std::setprecision(3) << lat <<"\t\t" << footprint << "    \t\t" << bytes/time << "\t\t" << flops/time << std::endl;
    }
};


