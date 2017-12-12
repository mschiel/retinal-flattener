import matlabcontrol.extensions.MatlabNumericArray;
import net.imagej.Dataset;

import org.scijava.Priority;
import org.scijava.convert.AbstractConverter;
import org.scijava.convert.Converter;
import org.scijava.object.ObjectService;
import org.scijava.plugin.Parameter;
import org.scijava.plugin.Plugin;

import com.mathworks.toolbox.javabuilder.*;
import retinalflattener.*;
import java.util.*;
import java.lang.reflect.*;

public class getmagic
{
   public static void main(MWArray array1)
   {
      System.out.println("Starting Browser");

      Object[] n = null;
      n[0] = array1;
      Object[] result = null;
      List listA = new ArrayList();
      listA.add(array1);
      List listB = new ArrayList();
      listB.add("SliceBrowser");
      Class1 theMagic = null;


      try
      {
        theMagic = new Class1();
//	 	theMagic.loadSliceBrowser2(1,n);
      }
      catch (Exception e)
      {
         System.out.println("Exception: " + e.toString());
      }
      finally
      {

      }

   }

   public static void getmagic(String[] args)
   {
   }

   public static int return5(String[] args)
   {
      return 5;
   }
}