# Petter Strandmark 2011

# You might have to change these to g++-4.5 or something similar if you have several versions installed
COMPILER = g++ -c
LINKER = g++

# Temporary directory to store object files; needs to exist
OBJDIR = ~/obj/submodular/

# Location of Clp if not installed where gcc can find it
CLPLIBDIR = ~/source/coin-Clp/lib/
CLPINCLUDEDIR = ~/source/coin-Clp/include/

# Names of executables
TARGET  = bin/submodular

##################################################################################

SUBMOBJ = $(OBJDIR)PseudoBoolean.o $(OBJDIR)PseudoBoolean_create_g.o $(OBJDIR)PseudoBoolean_heuristic.o $(OBJDIR)PseudoBoolean_minimize.o $(OBJDIR)PseudoBoolean_minimize_lp.o $(OBJDIR)PseudoBoolean_minimize_reduction.o $(OBJDIR)PseudoBoolean_reduce.o $(OBJDIR)PseudoBoolean_complete.o $(OBJDIR)PseudoBoolean_branchandbound.o $(OBJDIR)GeneratorPseudoBoolean.o $(OBJDIR)VertexPacking.o
QPBOOBJ = $(OBJDIR)QPBO.o $(OBJDIR)QPBO_extra.o $(OBJDIR)QPBO_maxflow.o $(OBJDIR)QPBO_postprocessing.o 
MAXFLOWOBJ = $(OBJDIR)graph.o $(OBJDIR)maxflow.o 
LIBDIR = $(OBJDIR)
INCLUDE = -I source/library -I thirdparty/Petter -I thirdparty/HOCR -I thirdparty/QPBO -I thirdparty/maxflow-v3.01.src -I thirdparty/ibfs
OPTIONS = -std=c++0x -O3




all : $(TARGET)

$(TARGET): $(OBJDIR)main_program.o $(OBJDIR)submodular_tests.o  $(OBJDIR)libpetter.a $(QPBOOBJ) $(MAXFLOWOBJ)
	$(LINKER) -L $(LIBDIR) -L $(CLPLIBDIR) $(OBJDIR)main_program.o  $(OBJDIR)submodular_tests.o  $(QPBOOBJ) $(MAXFLOWOBJ) -o $(TARGET) -lpetter -lClp -lCoinUtils 

clean:
	rm -f $(TARGET)
	rm -f $(OBJDIR)*.o
	rm -f $(OBJDIR)*.la
	rm -f $(OBJDIR)*.a
	
test: $(TARGET)
	./$(TARGET)
	
# Main program; compile with -Wall -Werror -pedantic-errors
$(OBJDIR)main_program.o: source/main_program.cpp source/library/PseudoBoolean.h source/library/Posiform.h
	$(COMPILER) $(OPTIONS) -Wall -Werror -pedantic-errors $(INCLUDE) source/main_program.cpp -o $(OBJDIR)main_program.o
$(OBJDIR)submodular_tests.o: source/submodular_tests.cpp source/library/PseudoBoolean.h
	$(COMPILER) $(OPTIONS) -Wall -Werror -pedantic-errors $(INCLUDE) source/submodular_tests.cpp -o $(OBJDIR)submodular_tests.o
#$(OBJDIR)posiform_tests.o: source/posiform_tests.cpp source/library/PseudoBoolean.h source/library/Posiform.h source/library/VertexPacking.h
#	$(COMPILER) $(OPTIONS) -Wall -Werror -pedantic-errors $(INCLUDE) source/posiform_tests.cpp -o $(OBJDIR)posiform_tests.o
# Main program; -pedantic-errors not possible since it includes QPBO.h
$(OBJDIR)image_denoising.o: source/image_denoising.cpp
	$(COMPILER) $(OPTIONS) -Wall -Werror $(INCLUDE) source/image_denoising.cpp -o $(OBJDIR)image_denoising.o 
    
$(LIBDIR)libpetter.a : $(SUBMOBJ) $(OBJDIR)Petter-Color.o
	ar rcs $(LIBDIR)libpetter.a $(OBJDIR)Petter-Color.o $(SUBMOBJ)

# Library; compile with -Wall -Werror -pedantic-errors
$(OBJDIR)Petter-Color.o: thirdparty/Petter/Petter-Color.cc thirdparty/Petter/Petter-Color.h
	$(COMPILER) $(OPTIONS) -Wall -Werror -pedantic-errors $(INCLUDE) thirdparty/Petter/Petter-Color.cc -o $(OBJDIR)Petter-Color.o	

# Library; compile with -Wall -Werror
# -pedantic-errors not possible since it uses QPBO
$(OBJDIR)%.o: source/library/%.cpp source/library/PseudoBoolean.h
	$(COMPILER) $(OPTIONS) -Wall -Werror $(INCLUDE) -I $(CLPINCLUDEDIR)  $< -o $@

# Will generate warnings in g++ 4.5
$(OBJDIR)%.o: thirdparty/QPBO/%.cpp 
	$(COMPILER) $(OPTIONS) $(INCLUDE) $< -o $@

# Will generate warnings in g++ 4.5
$(OBJDIR)%.o: thirdparty/maxflow-v3.01.src/%.cpp 
	$(COMPILER) $(OPTIONS) $(INCLUDE) $< -o $@

	
