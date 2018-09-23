Utility Features : 
- Enables automatic generation and optionally conversion of existing IBMi files in DDS form into SQL DDL source and object.  PF-files are converted into SQL-table, LF-files into SQL Views.  Keyed Files, Join Files and Files with select/omit constraints are handled automatically.
- With option to generate DDL source and object from a single file, or from list of files, or from all files of entire library, or from all PF-files of a library.  Pre-defined 'Custom-Codes' are provided to allow that.  See parameter rules below.
- With option to 'filter' or exclude files from the specified library, by entering the file names to exclude in file GENFILTER with field FFILTER set to 'E' (for exclude). This filtering is not applied on custom-run.
	- With option to generate the SQL DDL source (and the object) into whatever library (or 	schema) that you desire.  Target library is created automatically if not existing.
- With option to generate the DDL source into new or existing sourcePF and/or library.  	The target sourcePF or Library will be created automatically if not existing. 
- Optional parameter/s is provided to have the ability to or not to generate SQL object from the generated DDL source.  Meaning, you can opt to just generate SQL DDL source alone.
- Process audit logs are created in GENLOGPF file during SQL DDL source creation and Object creation.  The logs can be useful for point-of-failure investigation and/or quick query reporting. 

Parameter Rules : 
- ObjLib(10A) - required, valid Library name must be passed.  This is the Library 	containing the files to convert from DDS into SQL DDL. 
- SrcPF(10A) - required, any or non-existing name can be passed.  Non-existing name will be created automatically.  This is the target source-PF to store the generated DDL. 
- SrcLib(10A) - required, any or non-existing name can be passed.  Non-existing name will be created automatically.  This is target library to store the generated DDL src.
- DDLObjLib(10A) - optional, any or non-existing library name may be passed.  Non-existing name will be created automatically.  This is the target library used in the DDL source and will be the target library of the SQL object if the optional Object creation is dictated (see SkipGenObj parameter).  This is optional as the utility can be run solely for DDL source generation. 
	 - CustomCode(20A) - optional, this is used for Pre-Defined codes designed for specific 	purpose.  Known Values:  
"CUSTOM-RUN" - pass this value if you want to generate DDL source from selected/list of files (of any type) that's entered in file GENFILTER  where field FFILTER = "I" (for include).  For this one, i recommend to simply pass the library name entered in GENFILTER in the parm ObjLib to get around ObjLib validation.
"FILE={XXX}"  - pass this value if you want the run for specific file, replace XXX with the specific file that you desired, it must be a valid object PF or LF in the library specified in ObjLib.  Note that for LF object, ensure that dependent-on PF exists in the target library if Object creation is chosen (ie parm SkipGenObj <> 'Y')
"PF-ONLY" - pass this value if you want the run to only generate DDL for PF-objects only that's present in specified library in ObjLib (ie excluding existing LFs, Views, Index objects). 
- SkipGenObj(1A) - optional, can be blank, a value of 'Y' would mean to skip the process 	 of creating the SQL object from the generated DDL source.   
