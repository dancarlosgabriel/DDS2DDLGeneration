# DDS2DDLGeneration: Convert DDS-based files to SQL DDL

## Requirements for building from Git Repo
- IBM i operating system 7.3 or higher (57xx-SS1 opt base,1,3)
- ILE RPG compiler (57xx-WDS opt 31)
- QShell (57xx-SS1 opt 30)
- PASE (57xx-SS1 opt 33)
- YUM https://tinyurl.com/ibmiyum
- GNU Make (`yum install make-gnu`)
- Git (`yum install git`)

## To Build with GNU Make
- it is assumed that you have installed the above requirements, and have the yum packages directory in your path
- it is assumed that you are logged on and at a PASE shell
- clone this repo (you may use the following command, or whichever method you prefer 
```
git clone https://github.com/dancarlosgabriel/DDS2DDLGeneration.git
``` 
- run `make` to build the repo. There is a LIBRARY parameter to specify the library you'd like to build into. For example to build into the DDS2DDL library:
```
make LIBRRARY=dds2ddl
``` 
- there are more detailed instructions in the comments at the top of the `Makefile`

## Utility Features
- Enables automatic generation and optionally conversion of existing IBMi PF files in DDS form into SQL DDL source and object.  PF-files are converted into SQL-table, LF-files into SQL Views, Index.  Keyed Files, Join Files and Files with select/omit constraints are handled automatically.
- With option to generate DDL source and object from a single file, or from list of files, or from all files of a given library, or from PF-objects only (LF's excluded).  Pre-defined 'Custom-Codes' are provided to allow that.  See parameter rules below.
- With option to 'filter' or exclude files from the specified library, by entering the file names to exclude in file GENFILTER having FFILTER = 'E' (for exclude). This filtering is not applied on custom-run.
- With option to generate the SQL DDL source (and the object) into a nominated library (or schema).  Target library is created automatically if not existing.
- With option to generate the DDL source into new or existing sourcePF and/or library.  The target sourcePF or Library will be created automatically if not existing. 
- Optional parameter/s is provided for the ability to (or not to) generate SQL object from the generated DDL source.  Meaning, you can opt to just generate SQL DDL source alone.
- Audit logs are created in GENLOGPF file during SQL DDL source creation and Object creation.  The logs can be useful for point-of-failure investigation and quick query reporting. 

## Parameters and its Rules
- ObjLib(10A) - required, valid Library name must be passed.  This is the Library containing the files to convert from DDS into SQL DDL. 
- SrcPF(10A) - required, any or non-existing name can be passed.  Non-existing name will be created automatically.  This is the target source-PF to store the generated DDL. 
- SrcLib(10A) - required, any or non-existing name can be passed.  Non-existing name will be created automatically.  This is the target library to store the generated DDL src.
- DDLObjLib(10A) - optional, any or non-existing library name may be passed.  Non-existing name will be created automatically.  This is the target library used in the DDL source and will be the target library of the SQL object if the optional Object creation is dictated (see SkipGenObj parameter).  Optional as the utility can be run solely for DDL source generation. 
- CustomCode(20A) - optional, this is used for Pre-Defined codes designed for specific 	purpose.  Known Values:  
"CUSTOM-RUN" - pass this value if you want to generate DDL source from selected/list of files (of any type) that's entered in file GENFILTER having FFILTER = "I" (for include).  For this one, i recommend to simply pass the library name entered in GENFILTER in the parm ObjLib to get around ObjLib validation.
"FILE={XXX}"  - pass this value if you want the run for specific file, replace XXX with the specific file that you desired, it must be a valid object PF or LF in the library specified in ObjLib.  Note that for LF object, ensure that dependent-on PF exists in the target library if Object creation is chosen (ie parm SkipGenObj <> 'Y')
"PF-ONLY" - pass this value if you want the run to only generate DDL for PF-objects only that's present in specified library in ObjLib (ie excluding existing LFs, Views, Index objects). 
- SkipGenObj(1A) - optional, can be blank, a value of 'Y' would mean to skip the process of creating the SQL object from the generated DDL source.   

By the way, just want to mention my appreciation to these people whose articles have been very useful to me during my development of this utility: Scott Klement, Jon Paris, Barbara Morris, Bob Cozzi, Simon Hutchinson, David Andruchuk, Birgitta Hauser. 
