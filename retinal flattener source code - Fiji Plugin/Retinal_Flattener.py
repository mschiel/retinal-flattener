# @matrix data
# @DatasetService datasetService
# @ImageJMATLABService ijmService
# @ImageJ ij
# @OUTPUT ImagePlus outds

from ij.plugin import RGBStackMerge
from jarray import array
from ij import IJ, ImagePlus, ImageStack
import matlabcontrol.extensions.MatlabNumericArray
import net.imagej.Dataset
import net.imagej.display.ImageDisplayService as ImageDisplayService
import net.imagej.display.process.SingleInputPreprocessor
import java.awt.Color
import sys

import org.scijava.Priority;
import org.scijava.convert.AbstractConverter;
import org.scijava.convert.Converter;
import org.scijava.object.ObjectService;
import org.scijava.plugin.Parameter;
import org.scijava.plugin.Plugin;
#import importlib
#import os
#print os.getcwd()



#os.chdir('C:\\Users\\cdcu1\\Desktop\\fiji-win64\\Fiji.app\\jars\\lib')
#print os.getcwd()
#sys.path.append('C:\\Users\\cdcu1\\Desktop\\fiji-win64\\Fiji.app\\jars\\lib\\retinalflattener.jar')
#sys.path.append('C:\\Users\\cdcu1\\Desktop\\fiji-win64\\Fiji.app\\jars\\lib\\javabuilder.jar')
#sys.path.append('C:\\Program Files\\MATLAB\MATLAB Runtime\\v93\\bin\\win64')
#sys.path.append('C:\\Program Files\\MATLAB\MATLAB Runtime\\v93\\runtime\\win64')
#sys.path.append('C:\\Program Files\\MATLAB\\MATLAB Runtime\\v93\\toolbox\\javabuilder\\jar\\javabuilder.jar')
#sys.path.append('C:\\Users\\cdcu1\\Desktop\\fiji-win64\\Fiji.app\\jars\\lib\\getmagic3.jar')
sys.path.append('.')
#print sys.path.__classpath__
#import subprocess
#sp = subprocess.Popen(["java", "-version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
#import com.mathworks.toolbox.javabuilder *
#from com.mathworks.toolbox.javabuilder import *
import retinalflattener.Class1 as Class1
import getmagic

if 1:
     import com.mathworks.toolbox.javabuilder.io.Streams 
     import com.mathworks.toolbox.javabuilder.MWException 
     import com.mathworks.toolbox.javabuilder.MWCtfFileSource 
     import com.mathworks.toolbox.javabuilder.MWCtfStreamSource 
     import com.mathworks.toolbox.javabuilder.MWCtfSource 
     import com.mathworks.toolbox.javabuilder.MWComponentOption 
     import com.mathworks.toolbox.javabuilder.MWApplication 
     import com.mathworks.toolbox.javabuilder.MWCellArray 
     import com.mathworks.toolbox.javabuilder.caching.Cache 
     import com.mathworks.toolbox.javabuilder.caching.BidirectionalHashMap 
     import com.mathworks.toolbox.javabuilder.caching.BidirectionalMap 
     import com.mathworks.toolbox.javabuilder.caching.SoftReferenceCache 
     import com.mathworks.toolbox.javabuilder.MWClassID 
     import com.mathworks.toolbox.javabuilder.MWJavaObjectRef 
     import com.mathworks.toolbox.javabuilder.web.util.ContentEncoding 
     import com.mathworks.toolbox.javabuilder.web.util.ContentType  
     import com.mathworks.toolbox.javabuilder.internal.JBOSSHack 
     import com.mathworks.toolbox.javabuilder.internal.DynamicLibraryUtils 
     import com.mathworks.toolbox.javabuilder.internal.MWArrayUtils 
     import com.mathworks.toolbox.javabuilder.internal.MCRThreadUtilities 
     import com.mathworks.toolbox.javabuilder.internal.MCRConfiguration 
     import com.mathworks.toolbox.javabuilder.internal.PresentFuture 
     import com.mathworks.toolbox.javabuilder.internal.CombinedListIterator 
     import com.mathworks.toolbox.javabuilder.internal.PlatformInfo 
     import com.mathworks.toolbox.javabuilder.internal.MWMCR 
     import com.mathworks.toolbox.javabuilder.internal.MWComponentInstance 
     import com.mathworks.toolbox.javabuilder.internal.MWMCRVersion 
     import com.mathworks.toolbox.javabuilder.internal.MWFunctionSignature 
     import com.mathworks.toolbox.javabuilder.internal.CombinedList 
     import com.mathworks.toolbox.javabuilder.internal.NativePtr 
     import com.mathworks.toolbox.javabuilder.internal.SerializableSubList 
     import com.mathworks.toolbox.javabuilder.internal.NativeMCR 
     import com.mathworks.toolbox.javabuilder.FunctionPtr 
     import com.mathworks.toolbox.javabuilder.MWMCROption 
     import com.mathworks.toolbox.javabuilder.Disposable 
     import com.mathworks.toolbox.javabuilder.services.ServicePeerCreationError 
     import com.mathworks.toolbox.javabuilder.services.StatefulServicePeer 
     import com.mathworks.toolbox.javabuilder.services.StatefulResource 
     import com.mathworks.toolbox.javabuilder.services.StatefulServicePeerAction 
     import com.mathworks.toolbox.javabuilder.services.StatefulServicePeerActionDispatcher 
     import com.mathworks.toolbox.javabuilder.services.ServiceDispatchTargetException 
     import com.mathworks.toolbox.javabuilder.services.StatefulServiceRequest 
     import com.mathworks.toolbox.javabuilder.services.StatefulServiceBinder 
     import com.mathworks.toolbox.javabuilder.services.ServiceResourceMismatchException 
     import com.mathworks.toolbox.javabuilder.services.ServiceException 
     import com.mathworks.toolbox.javabuilder.services.StatefulService 
     import com.mathworks.toolbox.javabuilder.services.StatefulServicePeerCache 
     import com.mathworks.toolbox.javabuilder.statemanager.ImmutableStateManager 
     import com.mathworks.toolbox.javabuilder.statemanager.HashMapStateManager 
     import com.mathworks.toolbox.javabuilder.statemanager.StateManagerException 
     import com.mathworks.toolbox.javabuilder.statemanager.UndefinedScopeException 
     import com.mathworks.toolbox.javabuilder.statemanager.rmi.StateManagerRemoteProxy 
     import com.mathworks.toolbox.javabuilder.statemanager.rmi.StateManagerContextProxy 
     import com.mathworks.toolbox.javabuilder.statemanager.rmi.StateManagerContextRemoteImpl 
     import com.mathworks.toolbox.javabuilder.statemanager.rmi.StateManagerContextRemote 
     import com.mathworks.toolbox.javabuilder.statemanager.rmi.StateManagerRemote 
     import com.mathworks.toolbox.javabuilder.statemanager.StateManagerContext 
     import com.mathworks.toolbox.javabuilder.statemanager.StateManagerStorageException 
     import com.mathworks.toolbox.javabuilder.statemanager.StateManager 
     import com.mathworks.toolbox.javabuilder.statemanager.ObjectNotFoundException 
     import com.mathworks.toolbox.javabuilder.statemanager.HashMapStateManagerContext 
     import com.mathworks.toolbox.javabuilder.statemanager.DefaultStateManagerContext 
     import com.mathworks.toolbox.javabuilder.MWUtil 
     import com.mathworks.toolbox.javabuilder.MWArray 
     import com.mathworks.toolbox.javabuilder.MWFunctionHandle 
     import com.mathworks.toolbox.javabuilder.MWCtfClassLoaderSource 
     import com.mathworks.toolbox.javabuilder.MWComplexity 
     import com.mathworks.toolbox.javabuilder.MWComponentOptions 
     import com.mathworks.toolbox.javabuilder.MWCtfExtractLocation 
     import com.mathworks.toolbox.javabuilder.NativeArray 
     import com.mathworks.toolbox.javabuilder.MWLogicalArray 
     import com.mathworks.toolbox.javabuilder.MWCtfDirectorySource 
     import com.mathworks.toolbox.javabuilder.external.org.json.XML 
     import com.mathworks.toolbox.javabuilder.external.org.json.CookieList 
     import com.mathworks.toolbox.javabuilder.external.org.json.JSONML 
     import com.mathworks.toolbox.javabuilder.external.org.json.JSONArray 
     import com.mathworks.toolbox.javabuilder.external.org.json.Test 
     import com.mathworks.toolbox.javabuilder.external.org.json.JSONString 
     import com.mathworks.toolbox.javabuilder.external.org.json.JSONException 
     import com.mathworks.toolbox.javabuilder.external.org.json.JSONWriter 
     import com.mathworks.toolbox.javabuilder.external.org.json.Cookie 
     import com.mathworks.toolbox.javabuilder.external.org.json.JSONTokener 
     import com.mathworks.toolbox.javabuilder.external.org.json.JSONObject 
     import com.mathworks.toolbox.javabuilder.external.org.json.XMLTokener 
     import com.mathworks.toolbox.javabuilder.external.org.json.JSONStringer 
     import com.mathworks.toolbox.javabuilder.external.org.json.CDL 
     import com.mathworks.toolbox.javabuilder.MWCharArray 
     import com.mathworks.toolbox.javabuilder.Images 
     import com.mathworks.toolbox.javabuilder.webfigures.WebFigure 
     import com.mathworks.toolbox.javabuilder.webfigures.service.WebFigureService 
     import com.mathworks.toolbox.javabuilder.webfigures.service.request.WebFigureResourceRequest 
     import com.mathworks.toolbox.javabuilder.webfigures.service.request.WebFigureJavaScriptRequest 
     import com.mathworks.toolbox.javabuilder.webfigures.service.request.WebFigureServiceRequest 
     import com.mathworks.toolbox.javabuilder.webfigures.service.request.NamedWebFigureServiceRequest 
     import com.mathworks.toolbox.javabuilder.webfigures.service.request.WebFigureRenderRequest 
     import com.mathworks.toolbox.javabuilder.webfigures.service.request.WebFigureGetPropertiesRequest 
     import com.mathworks.toolbox.javabuilder.webfigures.service.request.WebFigureInterfaceRequest 
     import com.mathworks.toolbox.javabuilder.webfigures.service.WebFigureServiceMCRRemote 
     import com.mathworks.toolbox.javabuilder.webfigures.service.ServiceMCRFactory 
     import com.mathworks.toolbox.javabuilder.webfigures.service.WebFigureBinder 
     import com.mathworks.toolbox.javabuilder.webfigures.service.result.WebFigureGetPropertiesResult 
     import com.mathworks.toolbox.javabuilder.webfigures.service.result.WebFigureBinaryResourceResult 
     import com.mathworks.toolbox.javabuilder.webfigures.service.result.WebFigureServiceResult 
     import com.mathworks.toolbox.javabuilder.webfigures.service.result.WebFigureServiceResultVisitor 
     import com.mathworks.toolbox.javabuilder.webfigures.service.WebFigurePeer 
     import com.mathworks.toolbox.javabuilder.webfigures.service.WebFigureServiceFactory 
     import com.mathworks.toolbox.javabuilder.webfigures.service.WebFigureServiceMCR 
     import com.mathworks.toolbox.javabuilder.webfigures.components.ComponentsMCRFactory 
     import com.mathworks.toolbox.javabuilder.webfigures.components.MathWorksLogoRemote 
     import com.mathworks.toolbox.javabuilder.webfigures.components.MathWorksLogo 
     import com.mathworks.toolbox.javabuilder.MWStructArray 
     import com.mathworks.toolbox.javabuilder.remoting.RemoteProxy 
     import com.mathworks.toolbox.javabuilder.remoting.BasicRemoteFactory 
     import com.mathworks.toolbox.javabuilder.remoting.NativeArrayContainer 
     import com.mathworks.toolbox.javabuilder.remoting.AbstractMWArrayVisitor 
     import com.mathworks.toolbox.javabuilder.remoting.MWArrayVisitor 
     import com.mathworks.toolbox.javabuilder.remoting.DisposeListener 
     import com.mathworks.toolbox.javabuilder.remoting.RemoteFactory 
     import com.mathworks.toolbox.javabuilder.remoting.debug.MCRRemote 
     import com.mathworks.toolbox.javabuilder.remoting.debug.MatlabMCRRemote 
     import com.mathworks.toolbox.javabuilder.remoting.debug.DeployedMCRRemote 
     import com.mathworks.toolbox.javabuilder.remoting.debug.MCRRemoteClientMWMCR 
     import com.mathworks.toolbox.javabuilder.MWMatrixRef 
     import com.mathworks.toolbox.javabuilder.MWNumericArray 
     import com.mathworks.toolbox.javabuilder.MWBuiltinArray 
     import com.mathworks.toolbox.javabuilder.pooling.Poolable 
     import com.mathworks.toolbox.javabuilder.logging.MWLogger 
     import com.mathworks.toolbox.javabuilder.remoting.debug.MCRRemote 
     import com.mathworks.toolbox.javabuilder.remoting.debug.MatlabMCRRemote 
     import com.mathworks.toolbox.javabuilder.remoting.debug.DeployedMCRRemote 
     import com.mathworks.toolbox.javabuilder.remoting.debug.MCRRemoteClientMWMCR 
     import com.mathworks.toolbox.javabuilder.MWMatrixRef 
     import com.mathworks.toolbox.javabuilder.MWNumericArray 
     import com.mathworks.toolbox.javabuilder.MWBuiltinArray 
     import com.mathworks.toolbox.javabuilder.pooling.Poolable 
     import com.mathworks.toolbox.javabuilder.logging.MWLogger 

def extractChannel(imp, nChannel, nChannels):
 """ Extract a stack for a specific color channel """
 stack = imp.getImageStack()
 ch = ImageStack(imp.width, imp.height)
 for i in range(1, imp.getNFrames()/nChannels + 1):
   index = (i-1)*nChannels+nChannel
   ch.addSlice(str(i), stack.getProcessor(index))
 return ImagePlus("Channel " + str(nChannel), ch)

#print dir()
#import retinalflattener.Class1 as Class1
#print dir(getmagic)

#gm0=gm()
#print gm
#print dir()
#Class1.loadSliceBrowser2
#importlib.import_module('retinalflattener.Class1')
#import com.mathworks.toolbox.javabuilder.MWNumbericArray
#import inspect

#os.chdir('C:\\Program Files\\MATLAB\\R2016a\\bin\\win64')
#print os.environ['CLASSPATH']
#import matlabruntimeforpython2_7
#import platform
#print platform.architecture()[0]
#import platform
#print platform.python_version()

java.lang.System.out.println('^^^You can ignore warning "console: Failed to install"^^^')
java.lang.System.out.println('Converting active image stack to MATLAB numeric array\nand loading libraries...')
#matrix = ijmService.getArray(ds)

#getmagic.main(data)
theMagic=Class1()
print data.lengths
#dout=data;
java.lang.System.out.println('Starting Browser...')
if data.dimensions == 3:
    [dout]=theMagic.loadSliceBrowser2(1,data.realArray3D)
if data.dimensions == 4:
   [dout]=theMagic.loadSliceBrowser2(1,data.realArray4D)
#dout2=data
#array2=dout2.getRealArray4D()
#array2=dout
# catch width
# create a ramp gradient from left to right
#print len(dout)
#for i in range(len(array2)):
#   array2[i] = 0
#if data.dimensions == 3:
  #  theMagic.loadSliceBrowser2(1,data.realArray3D)
#if data.dimensions == 4:
#    theMagic.loadSliceBrowser2(1,data.realArray4D)
doutMNarray=matlabcontrol.extensions.MatlabNumericArray(dout.toDoubleArray(),dout.toDoubleArray())
#print dir(ij)
outds1 = ijmService.getDataset(doutMNarray)
imp = ij.convert().convert(outds1, ImagePlus)
#outds=ImagePlus("channel1",dout.toDoubleArray())
print imp.getNFrames()
if data.lengths[2]==2:
  outds1 = extractChannel(imp, 1, 2)
  outds2 = extractChannel(imp, 2, 2)
  outds1.setColor(java.awt.Color.RED)
  outds2.setColor(java.awt.Color.GREEN)
  outds = RGBStackMerge.mergeChannels(array([outds1,outds2],ImagePlus),0)
else:
  if data.lengths[2]>2:
    outds1 = extractChannel(imp, 1, 3)
    outds2 = extractChannel(imp, 2, 3)
    outds3 = extractChannel(imp, 3, 3)
    outds1.setColor(java.awt.Color.RED)
    outds2.setColor(java.awt.Color.GREEN)
    outds3.setColor(java.awt.Color.BLUE)
    outds = RGBStackMerge.mergeChannels(array([outds1,outds2,outds3],ImagePlus),0)
  else:
    outds = imp