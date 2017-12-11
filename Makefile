FC = mpif90
FFLAGS = -acc -Minfo=accel -ta=tesla:cc70,cuda9.0
OBJ = simple_bcast_gpudirect olcf_gpudirect simple_bcast_host

all: $(OBJ)

%: %.f90
	$(FC) $(FFLAGS) $^ -o $@

clean:
	rm -f $(OBJ)
