program simple_bcast
   use mpi
   use openacc
   implicit none
   integer, parameter :: n = 2
   integer :: v(n)
   integer :: i, ierr, myrank, nranks

   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, myrank, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, nranks, ierr)

   call acc_set_device_num(myrank, ACC_DEVICE_NVIDIA)

   call print_array(v, "a. Before bcast, outside data")

   !$acc data copy(v)
   
   !$acc kernels present(v)
   if (myrank == 0) then
      v = 1
   endif
   !$acc end kernels

   call print_array(v, "b. Before bcast, in data")

   !$acc update host(v)
   call MPI_Bcast(v, n, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
   !$acc update device(v)

   call print_array(v, "c. After bcast, in data")

   !$acc end data

   call print_array(v, "d. After bcast, outside data")

   call MPI_Finalize(ierr)
   
   contains
       subroutine print_array(array, label)
          implicit none
          integer, dimension(:), intent(in) :: array
          character(*), intent(in) :: label
          integer :: myrank, nranks, ierr

          call MPI_Comm_rank(MPI_COMM_WORLD, myrank, ierr)
          call MPI_Comm_size(MPI_COMM_WORLD, nranks, ierr)

          do i = 0, nranks-1
            if (myrank == i) then
               write (6,*)  label,  myrank, ":" , array
               call flush(6)
            endif
            call MPI_Barrier(MPI_COMM_WORLD, ierr)
          enddo
       end subroutine

end program
