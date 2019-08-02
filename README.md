# Collidoscope
Collidoscope trajectory method collisional cross section modeling program
Collidoscope: An Improved Tool for Computing Collisional Cross-Sections with the Trajectory Method



CONTENTS:

1)  Installation
2)  Quick-start to Using Collidoscope
3)  Output Files
      a)  Information Output File
      b)  Energy Output File
      c)  Trajectory Output File
4)  Command Line Arguments
5)  Input Files
      a)  Coordinate Input File
      b)  Settings Input File
      c)  Gas Parameter Input File
           i) Spherical Particle Parameter File
          ii) Diatomic Particle Parameter File
      d)  Affinity Input File
      e)  Geometry Input File
6)  Default Parameter Values
7)  Re-Compiling and Editing Code
8)  Charge Placement Algorithm
9)  Collidoscope algorithm notes
10) MPI features and advantages




    1) Installation:
LINUX:
To run Collidoscope, g++ and openmp must be installed on your machine. These can both be installed by using the
following command:

    sudo apt-get install g++

Note that this will only work on personal machines. On supercomputing clusters, ask the network administrators how to
install or load g++ on your node.

Collidoscope must be compiled prior to running, so once you navigate to the "Collidoscope/" directory, the following
chain of commands will install Collidoscope (without MPI):

    cd src/
    make clean install
    cd ..
    chmod +x coll (this gives "coll" permission to be executed, not always required)

Collidoscope should now be ready to run. Section 2 show you how to run the first simulation. If you change any of the
source code in the future, you will need to recompile Collidoscope. The steps to do this are discussed in section 7.

To use Collidoscope with MPI, replace the second command above with

    make clean install_mpi

after following the steps above. This will produce the "coll" executable, but it will have MPI enabled. Note that this
executable can be run with or without MPI, so it is more versatile. To run Collidoscope, use the command

    ./coll

See section 4 to see what command line arguments you should use and when, in order to compute your CCS.

WINDOWS:

Update as of 8/1/2019: To install in Windows, please see the document "Collidoscope installation for Windows.docx", which gives much more detailed instructions than below!

(older, less detailed instructions:)
As prerequisites, Collidoscope requires a c++ compiler and MSMPI. I believe that any compiler will work if you
prefer to use a specific compiler, but we compiled Collidoscope using Microsoft Visual Studio, which you can download
at

https://www.visualstudio.com/downloads/

MSMPI can be installed from

https://msdn.microsoft.com/en-us/library/bb524831(v=vs.85).aspx

Once you download these packages, open "src/Collidoscope.vcxproj". Once this opens, choose which options you would like
to use from the drop-down menus at the top of the screen. The options are MPI vs NoMPI, and x86 (32-bit) vs x64 (64
bit). Then click Build->Build Collidoscope. Now you should have a working executable in the "Collidoscope/" folder,
that you can either run from the command line or from the Visual Studio Integrated Development Environment (IDE).
To enter command line options via the IDE, click debug->Collidoscope Properties->Debugging (on left list)->Command
Arguments. Enter your command line arguments in this box, then run as usual. Because it is tedious to enter command
line arguments through the IDE, we suggest you use the IDE to build Collidoscope, and you run Collidoscope using the
command line. To do so, just use the command

	Collidoscope.exe
	
The syntax for windows is identical to that for linux, with the exception that "./coll" becomes
"Collidoscope.exe". Because we expect most people to use linux, the rest of the readme is written using linux-based
commands. To translate these to Windows commands, simply make the replacement mentioned above.

MAC:
To install Collidoscope on a Mac, please see the file "Installing Collidoscope on a Mac.docx". Because Collidoscope uses OpenMP to parallelize over multiple threads, and Mac OS doesn't support OpenMP, you need to follow the instructions in that document to get a compiler that does just that. The file contains step-by-step instructions with screen shots for how to do this. Once installed, Collidoscope should operate on your Mac essentially identically to its operation in Linux via the command line terminal.

    2) Quick-start to Using Collidoscope:
After installation, the command 

    ./coll

will run Collidoscope and immediately produce data. By default, Collidoscope will read its coordinates from
"coordinateFiles/ondansetron.pdb", which contains the 41-atom drug, ondansetron. Collidoscope should take about 1-5
seconds to complete this computation.

After the computation is complete, Collidoscope will have displayed the location of the "Information output file". This
is where most of the important information is stored regarding the simulation, and by default is set to
"outputFiles/output.info". To access the information in this file (or any other output file), just use any text editor
to open it.



    3) Output Files:
There are 3 output files, which may not all be created on every run. These are:

Information Output File : Contains a basic summary of the input parameters and simulation results. This file is created
                            after ANY simulation.
Energy File             : Contains the details of convergence when using the Charge Placement Algorithm. This file is
                            only created when using the Charge Placement Algorithm.
Trajectory File         : Contains the details for many trajectories during the Collisional Cross Section computation.
                            This file is only created when the Trajectory Output Setting in the Settings Input File is
                            set to "Combined" or "Split".

        3a) Information Output File
This file consists of a header (which contains input parameter information), a body (which contains details about the
energy states analyzed), and a tail (which summarizes the simulation). The cross section and most of the other
important information is found in the tail, at the end of the file. The header contains all of the information
necessary to replicate the simulation, and is reported so that this section can be copied and pasted into a new file
to be used as a Settings Input File. Collidoscope is programmed in such a way that the output is completely determined
by the input parameters, without any random sampling. Therefore, if you use the settings listed in the Information
Output File as the input for another run, you are guaranteed to get the exact same CCS.

        3b) Energy Output File
Every line of this file contains the iteration number and the total apparent affinity calculated at that iteration.
This file is mostly used to make sure that the algorithm properly converged, in addition to analyzing the "absolute"
apparent affinity.

        3c) Trajectory Output File
This file contains LONG lines of coordinates. Each line contains the coordinates of one gas atom, in chronological
order, as it is simulated around the molecule. Therefore, this file can easily become very large, so the "Split" option
was added so that each thread (usually 12 in a simulation) creates its own Trajectory Output File, reducing the size of
each file so that text editors can read it. The coordinates are formatted so that they can be easily imported by
Mathematica as a table.



	4) Command Line Arguments:
All parameters for Collidoscope are initially read from the Settings Input File. However, every option in that file has
a command line override option, to help with automating the input of parameters without making a new input for each
simulation. A description of each command line option and how it affects the simulation follows:

option: Input File Option    (Valid value)               Description
-C    : <Net Charge>         (number)                    Net charge in the simulation system. If the Coordinate Input
                                                             File has a different number of charges, the difference
                                                             will be placed at the center of mass.
-e    : <Energy States>      (integer)                   Number of energy states to use in the simulation.
-eps  : <Epsilon>            (number)                    Value for the relative permittivity of the molecule, used only
                                                             when using the Charge Placement Algorithm.
-fa   : <Affinity File>      (relative path)             Affinity Input File.
-fc   : <Coordinate File>    (relative path)             Coordinate Input File. 
-fg   : <Geometry File>      (relative path)             Geometry Input File.
-fp   : <Gas Parameter File> (relative path)             Gas Parameter Input File.
-fs   :                      (relative path)             Settings Input File, to replace the default of input.txt. 
-m    : <Minimum Energy>     (number)                    Energy (in units of RT) of the lowest-energy energy state.
-mode : <Algorithm>          ("CCS","place","all")       Which algorithms to use:
                                                             CCS   : Only calculate the cross section.
                                                             place : Only use the charge placement algorithm
                                                             all   : Use the charge placement algorithm, then calculate
                                                                     the cross section.
-int  : <Integration Method> ("RK4","Euler")             Integration Method to use in the CCS computation. RK4 is a
                                                             fourth-order method, while Euler is a 1st-order method.
-M    : <Maximum Energy>     (number)                    Energy (in units of RT) of the highest-energy energy state.
-oe   : <Energy Output>      (relative path)             Energy Output File.
-oi   : <Information Output> (relative path)             Information Output File.
-ot   : <Trajectory Output>  (relative path)             Trajectory Output File.
-p    : <Particle Type>      ("Spherical"/"Diatomic")    Identity of collision particle:
                                                             Spherical: Assume spherical symmetry, with a single
                                                                 isotropic polarizability.
                                                             Diatomic: Includes a bond length and an off-axis
                                                                 asymmetric polarizability.
-T    : <Temperature>        (number > 10)               temperature to use when determining the speed of particles
                                                             moving in the system.
-traj : <Trajectory Setting> ("None"/"Split"/"Combined") Determines what trajectory information to output.
                                                             None     : No trajectory information will be saved
                                                             Split    : Each thread will write trajectories to
                                                                 individual files.
                                                             Combined : Every thread's trajectory file will be combined
                                                                 at the end of the simulation.




    5) Input Files:
There are currently 5 types of input files, which should be edited with varying degrees of frequency. In all of these
files, any line beginning with a "#" (and any empty line) is considered a comment. Listed below are the input files in
order of intended frequency of editing:

Coordinate Input File    : Contains the coordinates and other information regarding the molecule being analyzed. This
                               file is used in every simulation, and has 2 possible formats.
Settings Input File      : Contains simulation parameters and other settings used to control most aspects of the
                               simulation. Used in every simulation.
Gas Parameter Input File : Contains Lennard-Jones parameters, mass, and polarizability of the simulation particle. Used
                               only when calculating the Collisional Cross Section.
Affinity Input File      : Contains residue names, affinities, and charge sites. Used only when using the Charge
                               Placement Algorithm.
Geometry Input File      : Contains coordinates of vantage points used in the Collisional Cross Section computation.
                               Used only when computing the Collisional Cross Section.

There is one additional output file when using the Charge Placement Algorithm, which is a pdb file with the optimized
charge configuration included in the file. The location of this file will always be the name of the Coordinate Input
File, with an "_" and the charge appended to the filename before the extension. Therefore, this "output" file will
usually end up in the "CoordinateFiles" folder to be used as the input for another simulation. An option to change the
name and location of this file will be included in the future.

        5a) Coordinate Input File:
Collidoscope accepts 2 formats for coordinate files: pdb and a custom format. If the file has a ".pdb" extension,
Collidoscope will automatically try to read the file in a pdb format. The specific pdb format used can be found at this
website:

http://www.wwpdb.org/documentation/file-format-content/format33/sect9.html#ATOM

Collidoscope will only consider lines in the pdb file that start with "ATOM", so any other lines are considered
comments. The data listed on that page as "x", "y", "z", and "element" are required for any computation using
Collidoscope. In addition, the data listed as "name", "resName", and "chainID" is required to use the Charge Placement
Algorithm. One drawback of using the pdb format, however, is that only integer charges are allowed. Therefore, the
custom format we developed is designed to allow non-integer charges. Any Coordinate Input File without a ".pdb"
extension is considered to have the custom format. This formatting is as follows:

element x y z [charge]

Note that the charge is optional. If no charge is specified, the atom is considered to be neutral. A line formatted in
this way is included for every atom in the molecule. This is an example of the Coordinate Input File, containing water
(with the custom format):

#############
O 0 0 0 -0.67
H 0 1 0 0.33
H 0 0 1 0.33
#############

Regardless of the format, if the "Net Charge" parameter in the Settings Input File does not match the total charge
represented in the Coordinate Input File, the difference will be placed at the center of mass.

There are 2 scripts included that can translate the two formats back and forth. To access these scripts, use one of
the two following commands in the src/ directory, depending on whether you are using MPI:

    make install
    make install_mpi

This will make the scripts "txt2pdb" and "pdb2txt" (as well as the coll executable, with or without MPI). These
scripts are used as

    ./txt2pdb path/to/txt/file
    ./pdb2txt path/to/pdb/file

These will convert any .txt (or .pdb, respectively) into the other format, and swap the extension.

        5b) Settings Input File Format
The Settings Input File was created to be an easy way to set default values for simulation parameters. The file is
intended to be edited relatively infrequently, opting instead to use the command line arguments to change parameters
on a case-by-case basis. The following options are currently recognized in the Settings Input File:

Net Charge        : (number)                    Net charge in the simulation system. If the Coordinate Input
                                                    File has a different number of charges, the difference will be
                                                    placed at the center of mass.
Energy States     : (integer)                   Number of energy states to use in the simulation.
Epsilon           : (number)                    Value for the relative permittivity of the molecule, used only
                                                    when using the Charge Placement Algorithm.
Affinity File     : (relative path)             Affinity Input File.
Coordinate File   : (relative path)             Coordinate Input File. 
Geometry File     : (relative path)             Geometry Input File.
Gas Parameter File: (relative path)             Gas Parameter Input File.
Minimum Energy    : (number)                    Energy (in units of RT) of the lowest-energy energy state.
Algorithm         : ("CCS","place","all")       Which algorithms to use:
                                                    CCS   : Only calculate the cross section.
                                                    place : Only use the charge placement algorithm
                                                    all   : Use the charge placement algorithm, then calculate
                                                            the cross section.
Integration Method: ("RK4","Euler")             Integration method to use for the CCS computation. RK4 is a fourth-
                                                    order method, while Euler is a 1st-order method.
Maximum Energy    : (number)                    Energy (in units of RT) of the highest-energy energy state.
Energy Output     : (relative path)             Energy Output File.
Information Output: (relative path)             Information Output File.
Trajectory Output : (relative path)             Trajectory Output File.
Particle Type     : ("Spherical"/"Diatomic")    Identity of collision particle:
                                                     Spherical: Assume spherical symmetry, with a single isotropic
                                                         polarizability.
                                                     Diatomic: Includes a bond length and an off-axis asymmetric
                                                         polarizability.
Temperature       : (number > 10)               temperature to use when determining the speed of particles
                                                    moving in the system.
Trajectory Setting: ("None"/"Split"/"Combined") Determines what trajectory information to output.
                                                    None     : No trajectory information will be saved
                                                    Split    : Each thread will write trajectories to
                                                        individual files.
                                                    Combined : Every thread's trajectory file will be combined
                                                        at the end of the simulation.

All of these options listed are case-insensitive before the delimiting character. The value for the option is located
after the delimiting character, which is an "=" for numerical values and a ":" for string values. All of these options
have an equivalent command line option, which is discussed in section 4. This is an example of a Settings Input File:

############################################
# The following are needed for both the CCS calulation and charge placement
Net Charge               = 1
Temperature              = 298.15
Coordinate Input File    : CoordinateFiles/ondansetron.pdb
Information Output       : outputFiles/output.info
Algorithm                : all

# The following are needed only for the charge placement algorithm
Epsilon                  = 1
Affinity Input File      : inputFiles/affinity.txt
Energy Output File       : outputFiles/output.enrg

# The following are needed only for the CCS calculation
Minimum Energy           = 0.5
Maximum Energy           = 8
Energy States            = 4
Particle Type            : Spherical
Integration Method       : Euler
Trajectory Setting       : None
Trajectory Output        : outputFiles/output.traj
Geometry Input File      : inputFiles/Geometry.txt
Gas Parameter input file : inputFiles/He.gas
############################################

        5c) Gas Parameter Input File
There is a different format for Spherical particles versus Diatomic particles. For both types, however, Lennard-Jones
parameters must be specified in the following format:

atom | rMin | epsilon | mass

Each line of this formatting corresponds to the Lennard-Jones parameters for one element. Therefore, one line of this
formatting must be included for each element in the ion.

This is the file to change when using a different gas particle in the simulation. Collidoscope currently comes default
with He.gas, N2.gas, and N2_diatomic.gas, which are Gas Parameter Input Files for Spherical Helium, Spherical
Nitrogen, and Diatomic Nitrogen molecules (respectively). These values were extensively optimized to produce accurate
results over a large range of molecule masses and sizes, and should only be edited if you are certain that a change
should be made. However, no publications were made with the diatomic particle physics and parameters, so use at your
own discretion.

            5ci) Spherical Particle Parameter File:

In addition to the Lennard-Jones parameters, this file must have the following lines somewhere in it:

mass = (number)
polarizability = (number)

Below is an example of a Spherical Particle Parameter File:

###########################################
polarizability = 0.204956e-30
mass           = 4.002602

# atom |    rMin     |   epsilon   |  mass
   C   | 3.415653013 | 129.2903507 | 12.0107
   H   | 2.671459675 | 62.71546861 | 1.00794
   N   | 3.415653013 | 129.2903507 | 14.00674
   O   | 3.415653013 | 129.2903507 | 15.9994
   S   | 3.415653013 | 129.2903507 | 32.066
   Na  | 3.415653013 | 129.2903507 | 22.99
   Cl  | 3.415653013 | 129.2903507 | 35.453
###########################################

            5cii) Diatomic Particle Parameter File:

In addition to the Lennard-Jones parameters, this file must have the following lines somewhere in it:

mass = (number)
polarizability (axial) = (number)
polarizability (radial) = (number)
bond length = (number)

Below is an example of a Diatomic Particle Parameter File:

###################################################
polarizability (axial)  = 2.19609742e-30
polarizability (radial) = 1.51148405e-30
# bond length from http://cccbdb.nist.gov/exp2x.asp
bond length             = 1.0977
mass                    = 28.0134

# atom |    rMin     |   epsilon   |  mass
   C   | 3.737798621 | 363.3485576 | 12.0107
   P   | 3.737798621 | 363.3485576 | 12.0107
   H   | 3.434733868 | 148.9147393 | 1.00794
   N   | 3.715349380 | 310.1293550 | 14.00674
   O   | 3.513306211 | 398.5463317 | 15.9994
   S   | 3.833207895 | 686.9324064 | 32.066
   Na  | 3.750000000 | 129.2903507 | 22.99
   Cl  | 3.737798620 | 668.8645820 | 35.453
#################################################

        5d) Affinity Input File
This file contains line in the following format:

residueName | chargedAtom | Affinity

One line of this format should be included for each residue in the molecule. This is an example of the Affinity Input
File, which comes by default with Collidoscope:

##################
HIS | CE1 | 958000
HIP | CE1 | 958000
LYS | NZ  | 937000
ARG | CZ  | 1029000
TRP |  O  | 659714
ALA |  O  | 869714
GLY |  O  | 869714
VAL |  O  | 869714
MET |  O  | 869714
THR |  O  | 869714
LEU |  O  | 869714
ILE |  O  | 869714
SER |  O  | 869714
TYR |  O  | 869714
PHE |  O  | 869714
CYS |  O  | 869714
ASN | OD1 | 869714
ASH | OD1 | 869714
ASP | OD1 | 869714
GLN | OE1 | 869714
GLU | OE1 | 869714
GLH | OE1 | 869714
PRO | N   | 869714
##################

        5e) Geometry Input File
The Geometry Input File has the simplest format of all of the input files:

x y z

One line with this formatting is required for each vantage point vector requested. This vector points to the center of
the plane of origin for a vantage point, so incoming particles approach with a velocity that is anti-parallel to this
vector. Here is an example of the default Geometry Input File (Geometry.txt), which contains the coordinates of a
Rhombic Triacontahedron:

#################################################################
0.	0.	-1.618033988749895
0.	0.	1.618033988749895
0.276393202250021	-0.8506508083520399	1.170820393249937
0.276393202250021	0.85065080835204	1.170820393249937
0.8944271909999159	0.	1.170820393249937
1.170820393249937	-0.8506508083520399	0.723606797749979
1.170820393249937	-0.8506508083520399	-0.276393202250021
1.170820393249937	0.85065080835204	0.723606797749979
1.170820393249937	0.85065080835204	-0.276393202250021
-0.8944271909999159	0.	-1.170820393249937
-0.4472135954999579	-1.3763819204711736	0.723606797749979
-0.4472135954999579	-1.3763819204711736	-0.276393202250021
-0.4472135954999579	1.3763819204711736	0.723606797749979
-0.4472135954999579	1.3763819204711736	-0.276393202250021
0.4472135954999579	-1.3763819204711736	0.276393202250021
0.4472135954999579	-1.3763819204711736	-0.723606797749979
0.4472135954999579	1.3763819204711736	0.276393202250021
0.4472135954999579	1.3763819204711736	-0.723606797749979
-1.4472135954999579	0.	0.723606797749979
-1.4472135954999579	0.	-0.276393202250021
-0.723606797749979	-0.5257311121191336	1.170820393249937
-0.723606797749979	0.5257311121191336	1.170820393249937
0.723606797749979	-0.5257311121191336	-1.170820393249937
0.723606797749979	0.5257311121191336	-1.170820393249937
1.4472135954999579	0.	0.276393202250021
1.4472135954999579	0.	-0.723606797749979
-1.170820393249937	-0.8506508083520399	0.276393202250021
-1.170820393249937	-0.8506508083520399	-0.723606797749979
-1.170820393249937	0.85065080835204	0.276393202250021
-1.170820393249937	0.85065080835204	-0.723606797749979
-0.276393202250021	-0.8506508083520399	-1.170820393249937
-0.276393202250021	0.85065080835204	-1.170820393249937
##################################################################

These vectors are normalized once they are read, so only the direction matters.


    6) Default Parameter Values:
In addition to the pathways to input parameters mentioned previously (sections 4-7), the code has a set of default
parameters hard-coded in. If the program ever notices that one of the parameters is not given in ANY other format, it
will notify the user that it is using one of the defaults listed below:

Net Charge               = 1
Temperature              = 298.15
Coordinate Input File    : CoordinateFiles/ondansetron.pdb
Information Output       : outputFiles/output.info
Algorithm                : all
Epsilon                  = 1
Affinity Input File      : inputFiles/affinity.txt
Energy Output File       : outputFiles/output.enrg
Minimum Energy           = 0.5
Maximum Energy           = 8
Energy States            = 4
Particle Type            : Spherical
Integration Method       : Euler
Trajectory Setting       : None
Trajectory Output        : outputFiles/output.traj
Geometry Input File      : inputFiles/Geometry.txt
Gas Parameter input file : inputFiles/He.gas

These are the parameters that will be used if input.txt contains no parameters (for whatever reason). If any parameters
are not compatible (such as differing minimum and maximum energies, yet only 1 energy state), Collidoscope will attempt
to correct the dispute as best it can, and notify you of the changes it made. If it cannot resolve the issue, it will
quit and notify you of any changes you need to make.



    7) Re-Compiling and Editing Code:
Collidoscope is a code base that can easily be edited and expanded as necessary. All of the code for the program is
included in the src/ directory, with further subdirectories intended to organize code for convenience. Also, the file
titled "Makefile" contains all of the information necessary to compile Collidoscope. If you intend to add or remove
files from the compilation, it can be done in that file. Here are the current compilation options:

    make             : Compiles and links the default configuration of Collidoscope.
    make debug       : Compiles and links Collidoscope with debug flags, to help with debugging.
    make debug_mpi   : Compiles and links Collidoscope with debug flags and MPI capability, to debug the MPI
                         functionality.
    make mpi         : Compiles and links Collidoscope with MPI capabilities. This uses the compiler mpicxx.
    make txt2pdb     : Compiles the txt2pdb script.
    make pdb2txt     : Compiles the pdb2txt script.
    make install     : Compiles txt2pdb and pdb2txt, followed by the default configuration of Collidoscope.
    make install_mpi : Same as make install, but uses mpicxx to add MPI functionality.
    make test        : Not currently useful. Compiles the files in unit_tests/, which are a beginning for the unit test
                         debugging strategy. With many more unit tests, this may eventually be useful.
    make clean       : Deletes all executables and object files. This MUST be done every time a .h file is edited, and
                         when switching into or out of MPI functionality.

For windows, these options cannot be used. It is possible to load specific files used for pdb2txt and txt2pdb into an
IDE and compile them. However, the use of the Makefile is limited to linux operating systems.



    8) Charge Placement Algorithm:
The charge placement algorithm has been incorporated into Collidoscope to be used with proteins and protein complexes.
More information is required to use the charge placement algorithm than when just computing the cross section, so a
".pdb" Coordinate File format is required (more info in section 5). The actual algorithm can be summarized as follows:

	1) Determine possible charge sites
	2) Randomly populate the molecule with the number of requested charges 1000 times, and continue with the
               configuration resulting in the highest apparent affinity.
	3) Randomly move one of the charges to a different (unpopulated) charge site.
	4) Accept the change if it results in a higher affinity, or accept it with some probability if it results in a
               lower affinity
	5) Repeat 3-4 until all of the following criteria have been met:
               - 800000 iterations have been completed
               - Average affinity over the last 1/4 of the iterations is within 0.1 KT of the average affinity of the
                 second-to-last 1/4 of the iterations (affinity is converged)
               - The standard deviation of the affinity over the last 1/4 of the iterations is less than 6 KT

This algorithm is used so that local affinity maxima can be overcome, and the global maximum can be reached. The
optimized charge configuration will be saved in a pdb file format, to be used for future simulations. More information
about this pdb file can be found in section 5.



    9) Collidoscope Algorithm Notes:
Collidoscope's algorithm for calculating cross sections is unique in that no random or Monte Carlo values are used.
Instead, parameters are sampled uniformly. Below is a broad summary of the Collidoscope algorithm:

	1) Generate the Planes of Origin, with a total size and grid spacing based on the molecule used as input.
	2) Populate the planes with particles, with velocities based on the energy states used. Every starting location
               on the plane of origin has one particle for each energy state.
	3) Simulate all particles individually, and record the scattering angle
	4) Use the scattering angle in the calculation of the cross section.

Parts 1 and 2 are parallelized together, and part 3 is parallelized for efficiency. More information can be found in
our paper published on the algorithm and its use.



    10) MPI features and advantages
Collidoscope now has the ability to be parallelized over multiple cores. While openmp allows the parallelization of
a program over multiple threads within a core, MPI (Message Passing Interface) allows a program to be parallelized
over multiple cores (or nodes, on a cluster). Also, these two methods of parallelization can be used in tandem to
drastically improve computation time. Typically, a core will have 8-12 threads over which openmp can parallelize.
Therefore, if MPI is used to parallelize over 20 nodes, then the resulting program can be up to 20*12=240 times faster
than the program in serial. To utilize MPI parallelism, the following command can be used:

mpirun -np 20 ./coll

This will run Collidoscope with 20 nodes. Any command line parameters for Collidoscope can be put at the end of the
command, after "./coll".

Note that because MPI parallelism requires some (relatively slow) communication between nodes, it is far more useful
for computations that require a long computation time. The communication overhead for short computations may even be
longer than the original computation. Thus, we recommend that MPI only be used for ions larger than 500 Da.
