retinalflattener MATLAB Java Package

1. Prerequisites for Deployment 

Verify that version 9.3 (R2017b) of the MATLAB Runtime is installed.   

If the MATLAB Runtime is not installed, you can run the MATLAB Runtime installer.
To find its location, enter
  
    >>mcrinstaller
      
at the MATLAB prompt.

Alternatively, download and install the Windows version of the MATLAB Runtime for R2017b 
from the following link on the MathWorks website:

    http://www.mathworks.com/products/compiler/mcr/index.html
   
For more information about the MATLAB Runtime and the MATLAB Runtime installer, see 
Package and Distribute in the MATLAB Compiler SDK documentation  
in the MathWorks Documentation Center.    

NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

 
- Ensure that you have version 1.7 of the Java Development Kit (JDK). 

- retinalflattener.jar must be included in your CLASSPATH.

- javabuilder.jar must be included in your CLASSPATH. javabuilder.jar 
  can be found at: 
  
  <mcr_root>\toolbox\javabuilder\jar\win64\javabuilder.jar

  where <mcr_root> represents the directory where MATLAB or the MATLAB Runtime is 
  installed on the target machine. 
  
2. Files to Deploy and Package

-retinalflattener.jar
-MCRInstaller.exe 
    Note: if end users are unable to download the MATLAB Runtime using the
    instructions in the previous section, include it when building your 
    component by clicking the "Runtime downloaded from web" link in the
    Deployment Tool.
-Javadoc   
   - javadoc for retinalflattener is in the doc directory. When  
     distributing the javadoc, this entire directory should be distributed.
-This readme file


3. Resources

- To learn more about deploying Java applications on the Web, see Web Deployment in the 
  MATLAB Java Package documentation in the MathWorks Documentation Center.   


4. Definitions

For information on deployment terminology, go to
http://www.mathworks.com/help and select MATLAB Compiler >
Getting Started > About Application Deployment >
Deployment Product Terms in the MathWorks Documentation
Center.

5. Appendix 


   For more detailed information about setting the MATLAB Runtime paths, see Package and 
   Distribute in the MATLAB Compiler SDK documentation in the MathWorks Documentation 
   Center.


       
        NOTE: To make these changes persistent after logout on Linux or 
              Mac machines, modify the .cshrc file to include this  
              setenv command.
        NOTE: On Windows, the environment variable syntax utilizes 
              backslashes (\), delimited by semi-colons (;). 
              On Linux or Mac, the environment variable syntax utilizes   
              forward slashes (/), delimited by colons (:).  
        NOTE: Ensure that you are using a 64-bit JVM.
