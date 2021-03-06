module mathOps
contains
  attributes(global) subroutine saxpy_cudafortran(x, y, a, n)
    implicit none
    real :: x(n), y(n)
    real, value :: a
    integer, value :: n
    integer :: i

    i = blockDim%x * (blockIdx%x - 1) + threadIdx%x
	 ! Generate out of bounds access to test cuda-memcheck
    if (i <= n) y(i+1000) = y(i) + a*x(i)

  end subroutine saxpy_cudafortran
end module mathOps

subroutine testsaxpy_cudafortran
  use mathOps
  use cudafor
  use omp_lib

  implicit none
  integer, parameter :: N = ishft(1,21)
  real, allocatable :: x(:), y(:)
  real ::  a
  real, device :: x_d(N), y_d(N)
  type(dim3) :: grid, tBlock

  tBlock = dim3(256,1,1)
  grid = dim3(ceiling(real(N)/tBlock%x),1,1)

  allocate(x(N), y(N))

  x = 1.0; y = 2.0; a = 2.0
  x_d = x
  y_d = y
  call saxpy_cudafortran<<<grid, tBlock>>>(x_d, y_d, a, N)
  y = y_d
  write(*,*) 'Ran CUDA FORTRAN kernel.  Max error: ', maxval(abs(y-4.0))
end subroutine testsaxpy_cudafortran
