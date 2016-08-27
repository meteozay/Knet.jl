# Full broadcasting index computation is complicated.  I am going to
# handle the case where the input arrays are either the same size as
# the result or vectors (have a single dim > 1).  If the result array
# has size (a1,a2,...) and input array b has size (1,...,bn,...,1), we
# need to find the linear index in b given the linear index in a.  If
# we are at position (i1,i2,...) the answer is just
# i_n=1+div(i-1,stride(a,n)).  So we can just pass in stride(a,n) as
# an argument for each input.  In 0-based indexing this is
# div(i,stride(a,n)).

include("cuda12.jl")

function cuda12src(f, j, ex; BLK=512, THR=256)
"""
__global__ void _$(f)_32_12(int n, float *x, int sx, int nx, float *y, int sy, int ny, float *z) {
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  while (i < n) {
    int xi = (i/sx)%nx;
    int yi = (i/sy)%ny;
    z[i] = $ex;
    i += blockDim.x * gridDim.x;
  }
}
extern "C" {
  void $(f)_32_12(int n, float *x, int sx, int nx, float *y, int sy, int ny, float *z) {
    _$(f)_32_12<<<$BLK,$THR>>>(n,x,sx,nx,y,sy,ny,z);
  }    
}
__global__ void _$(f)_64_12(int n, double *x, int sx, int nx, double *y, int sy, int ny, double *z) {
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  while (i < n) {
    int xi = (i/sx)%nx;
    int yi = (i/sy)%ny;
    z[i] = $ex;
    i += blockDim.x * gridDim.x;
  }
}
extern "C" {
  void $(f)_64_12(int n, double *x, int sx, int nx, double *y, int sy, int ny, double *z) {
    _$(f)_64_12<<<$BLK,$THR>>>(n,x,sx,nx,y,sy,ny,z);
  }    
}
"""
end

for a in cuda12
    isa(a,Tuple) || (a=(a,))
    print(cuda12src(a...))
end
